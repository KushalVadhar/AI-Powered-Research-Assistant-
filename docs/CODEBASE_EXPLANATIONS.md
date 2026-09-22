# AI Research Assistant — Architecture & Codebase Explanations

This document is the master architectural and conceptual guide for the **AI Research Assistant** application. It catalogs the purpose, design patterns, folder placement rationale, and Flutter/Dart/GenAI concepts for every file in the project.

---

## Table of Contents

1. [Architecture Overview & Clean Architecture Flow](#1-architecture-overview)
2. [Configuration & Theming (`lib/config/`)](#2-configuration--theming-libconfig)
3. [Domain Models & DTOs (`lib/models/`)](#3-domain-models--dtos-libmodels)
4. [Network Layer (`lib/network/`)](#4-network-layer-libnetwork)
5. [Service Layer (`lib/services/`)](#5-service-layer-libservices)
6. [Repository Layer (`lib/repositories/`)](#6-repository-layer-librepositories)
7. [State Management (`lib/blocs/`)](#7-state-management-libblocs)
8. [Presentation Layer — Screens (`lib/screens/`)](#8-presentation-layer--screens-libscreens)
9. [Presentation Layer — Widgets (`lib/widgets/`)](#9-presentation-layer--widgets-libwidgets)
10. [Utilities (`lib/utils/`)](#10-utilities-libutils)
11. [Supabase Database, Vector Store & Storage (`supabase/` & Services)](#11-supabase-database-vector-store--storage-supabase--services)
12. [FastAPI Backend & RAG Pipeline Architecture (`backend/`)](#12-fastapi-backend--rag-pipeline-architecture-backend)

---

## 1. Architecture Overview

The app strictly follows **Clean Architecture** with a unidirectional data flow:

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│  Screens & Reusable Widgets (UI only, no HTTP / no SQL)     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Dispatches Events / Calls Methods
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT (BLoC)                  │
│  BLoCs & Cubits (State machines, no UI rendering, no Dio)   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invokes Abstract Contracts
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      REPOSITORY LAYER                       │
│  Repositories (Single source of truth, swappable data)      │
│         ▲                                         ▲         │
│         │                                         │         │
│  Mock Implementations                     Real Implementations│
└───────────────────────────────────────────────────┬─────────┘
                                                    │ Calls
                                                    ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE & NETWORK                      │
│  Services (Supabase Auth, FastAPI Dio endpoints, Storage)   │
│  HttpService, Interceptors, ApiResult sealed types          │
└─────────────────────────────────────────────────────────────┘
```

### The Golden Rule of Clean Architecture
> **Each layer only communicates with the layer directly beneath it.**
> A Screen never talks to `HttpService` or `Dio`. A BLoC never builds Widgets or touches database drivers. A Repository abstracts away whether data comes from in-memory mocks, Supabase, or FastAPI.

---

## 2. Configuration & Theming (`lib/config/`)

### `app_constants.dart`
- **Why it exists:** Centralizes magic numbers, timeouts, pagination defaults, and environment credentials (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `isSupabaseConfigured`).
- **Why in `config/`:** Defines *how* the app behaves globally, rather than what it displays.
- **Design Pattern:** Constants class with a private constructor (`AppConstants._()`) preventing instantiation.
- **Key Concepts:** Dart compile-time constants (`const`) and `String.fromEnvironment` for zero runtime overhead and secure secret injection.

### `app_colors.dart`
- **Why it exists:** Single source of truth for the app's visual color palette (primary indigo, secondary violet, neutrals, semantic status badges).
- **Design Pattern:** Static color token namespace.
- **Key Concepts:** Decouples color hex values from UI widgets so themes can be modified centrally.

### `app_dimensions.dart`
- **Why it exists:** Establishes a consistent 4px/8px design grid (spacing, padding, border radii, icon sizes).
- **Design Pattern:** Design token system.
- **Key Concepts:** Eliminates random padding (`EdgeInsets.all(17)`) and creates visual rhythm across screens.

### `app_strings.dart`
- **Why it exists:** Centralizes all user-facing labels, placeholders, errors, and button text.
- **Why in `config/`:** Simplifies future localization (l10n) and prevents typos scattered across widgets.

### `app_theme.dart`, `light_theme.dart`, `dark_theme.dart`
- **Why they exist:** Material 3 `ThemeData` builders for light and dark modes.
- **Design Pattern:** Theme orchestrator.
- **Key Concepts:** Uses `ColorScheme.fromSeed` with custom overrides for `cardTheme`, `inputDecorationTheme`, `elevatedButtonTheme`, and `appBarTheme`.

### `router/app_router.dart` & `router/route_names.dart`
- **Why they exist:** Declarative navigation system using `GoRouter`.
- **Key Concepts:**
  - `RouteNames` prevents magic strings (e.g. `'/chat'`).
  - Path parameters (`:id`, `:conversationId`) for deep linking.
  - `guardRedirect`: Pure static security policy redirecting unauthenticated users to `/login` and authenticated users away from auth pages to `/home`.
  - `GoRouterRefreshStream`: Adapts `AuthCubit.stream` into a `ChangeNotifier` so GoRouter re-evaluates routes automatically on login/logout without rebuilding the navigation stack.

---

## 3. Domain Models & DTOs (`lib/models/`)

The models directory is split into four distinct subfolders following Domain-Driven Design (DDD):
1. `data/`: Domain/business models used across the app.
2. `request/`: Request DTOs (Data Transfer Objects) sent to API endpoints.
3. `response/`: Response DTOs received from API endpoints.
4. `enums/`: Type-safe domain enumerations.

### `models/data/`
- **`user_model.dart`:** Represents the user profile (`id`, `email`, `fullName`, `avatarUrl`, `createdAt`). Extends `Equatable` for value equality.
- **`document_model.dart`:** Represents an uploaded paper/document (`id`, `name`, `fileUrl`, `fileType`, `fileSize`, `processingStatus`, `summary`, `pageCount`).
- **`conversation_model.dart`:** Represents a chat thread linked to a specific document or global research workspace.
- **`chat_message_model.dart`:** Represents an individual message in a conversation (`id`, `role`, `content`, `citations`, `createdAt`).
- **`citation_model.dart`:** Grounding evidence extracted by the RAG pipeline (`sourceNumber`, `documentId`, `documentName`, `pageNumber`, `snippet`).

### `models/enums/`
- **`document_status.dart`:** Lifecycle enum (`pending`, `processing`, `ready`, `failed`). Uses Dart Enhanced Enums to attach display labels, color codes, and icons directly to each enum value.
- **`message_role.dart`:** Enum for chat message participants (`user`, `assistant`, `system`).
- **`file_type.dart`:** Allowed document formats (`pdf`, `docx`, `txt`).

### `models/request/` & `models/response/`
- **Request DTOs:** `login_request.dart`, `signup_request.dart`, `chat_request.dart`, `compare_request.dart`.
- **Response DTOs:** `auth_response.dart`, `document_response.dart`, `api_response.dart` (generic wrapper `{ success, message, data }`).

---

## 4. Network Layer (`lib/network/`)

### `api_result.dart`
- **Why it exists:** Sealed class modeling binary operation outcomes: `ApiSuccess<T>(data)` or `ApiFailure<T>(exception)`.
- **Key Concepts:** Dart 3 sealed classes allow exhaustive pattern matching (`switch (result)`). Guarantees that errors can never be silently ignored at compile time.

### `api_exception.dart`
- **Why it exists:** Typed exception hierarchy representing recoverable HTTP/API issues (`UnauthorizedException`, `NotFoundException`, `ValidationException`, `RateLimitException`, `ServerException`, `NetworkException`, `TimeoutException`).
- **Key Concepts:** Differentiates between programmer bugs (Errors) and recoverable operational issues (Exceptions).

### `http_service.dart`
- **Why it exists:** Central Dio client wrapper configuring baseUrl, timeouts, headers, and interceptor chains.
- **Key Concepts:** All HTTP traffic routes through this single gateway.

### `interceptors/auth_interceptor.dart`
- **Why it exists:** Middleware running before every outgoing request to attach `Authorization: Bearer <token>`.
- **Key Concepts:** Supports dynamic `tokenProvider` callbacks, allowing Supabase background token refreshes to be immediately reflected in outgoing FastAPI requests.

### `interceptors/logging_interceptor.dart`
- **Why it exists:** Pretty-prints HTTP requests, response status codes, durations, and curl commands during debug runs.

---

## 5. Service Layer (`lib/services/`)

### `auth_service.dart`
- **Why it exists:** Low-level adapter wrapping `SupabaseClient.auth`.
- **Design Pattern:** Adapter Pattern.
- **What problem it solves:** Isolates third-party Supabase SDK API calls (`signInWithPassword`, `signUp`, `signOut`, `resetPasswordForEmail`, `onAuthStateChange`). If Supabase changes its SDK methods in a future version, only this file is touched.

### `supabase_storage_service.dart`
- **Why it exists:** Low-level adapter wrapping Supabase Storage (`client.storage.from('documents')`).
- **Design Pattern:** Adapter Pattern.
- **Key Methods:**
  - `uploadBytes`: Sanitizes filename characters and saves to the user's isolated folder (`userId/timestamp_name.pdf`).
  - `getSignedUrl`: Generates temporary time-limited URLs for downloading private documents securely without exposing public URLs.
  - `deleteFile`: Removes files from the storage bucket.
  - `downloadFile`: Retrieves raw document bytes for local caching or parsing.

### `supabase_database_service.dart`
- **Why it exists:** Low-level adapter wrapping Supabase PostgreSQL client (`client.from(...)` and `client.rpc(...)`).
- **Design Pattern:** Data Gateway / Adapter Pattern.
- **Key Methods:**
  - `getDocuments`, `getDocumentById`, `insertDocument`, `updateDocument`, `deleteDocument`: CRUD operations on the `documents` table with RLS.
  - `watchDocuments`: Realtime stream (`client.from('documents').stream(...)`) that automatically pushes updates when document status transitions (e.g. from `processing` to `ready`).
  - `getConversations`, `createConversation`, `deleteConversation`: Thread management for research discussions.
  - `getMessages`, `insertMessage`: Chat message storage and updating parent conversation timestamps.
  - `matchDocumentChunks`: Direct invocation of the `match_document_chunks` RPC for pgvector semantic search.

---

## 6. Repository Layer (`lib/repositories/`)

### Abstract Contracts
- **`auth_repository.dart`:** Abstract contract for user login, registration, password reset, session checks, and logout.
- **`document_repository.dart`:** Abstract contract for loading documents, status filtering, search queries, file uploads, reprocessing, and deletion.
- **`chat_repository.dart`:** Abstract contract for loading conversations, sending messages, fetching thread history, and clearing sessions.

### Implementations
- **`mock/mock_auth_repository.dart`, `mock/mock_document_repository.dart`, `mock/mock_chat_repository.dart`:** In-memory implementations using `mock_data.dart` with realistic network latency simulation (`Future.delayed`).
- **`supabase_auth_repository.dart`:** Concrete implementation of `AuthRepository` connecting `AuthService` with the domain models. Translates `supabase.User` to `UserModel`, catches `AuthException` and maps to `ApiException`, and syncs session tokens with `AuthInterceptor`.
- **`supabase_document_repository.dart`:** Concrete implementation of `DocumentRepository` bridging `SupabaseDatabaseService`, `SupabaseStorageService`, and `AuthService`.
  - **Storage Orchestration:** Uploads raw bytes directly to the user's isolated storage folder (`userId/timestamp_name.pdf`).
  - **Database Persistence:** Inserts document records with initial status `pending` and tracks status lifecycle transitions (`processing` → `ready`).
  - **AI Summary Caching:** Retrieves cached executive summaries from the database or generates and persists new summaries to prevent redundant LLM token expenditures.
  - **Multi-Document Comparison:** Compares research documents across methodologies, findings, and synthesis.
  - **Safe Cascade Deletion:** Removes files from the storage bucket and deletes the PostgreSQL database record (cascading to chunks and conversations).
  - **Realtime Watch Stream:** Provides a reactive stream of document status changes so UI updates without manual polling.
  - **FastAPI Vector Processing:** Triggers `/documents/process`, `/documents/summarize`, and `/documents/compare` endpoints.
- **`supabase_chat_repository.dart`:** Concrete implementation of `ChatRepository` bridging `SupabaseDatabaseService`, `AuthService`, and `HttpService`.
  - **Conversational Persistence:** Manages research discussion threads and message histories within PostgreSQL tables (`conversations`, `messages`).
  - **Conversational RAG Gateway:** Calls the FastAPI microservice (`/chat/query`) with the researcher's query, document context, and message history.
  - **Footnote Citations:** Stores and parses grounded footnote citations referencing document chunks and page numbers.
  - **Intelligent Fallback:** Features graceful offline fallback when the FastAPI microservice is offline so mobile/web users can test and run uninterrupted.

---

## 7. State Management (`lib/blocs/`)

### `auth/auth_cubit.dart` & `auth_state.dart`
- **Why a Cubit instead of full BLoC?** Auth transitions are strictly linear: `checkAuthStatus`, `login`, `signup`, `logout`. Cubits call functions directly (`cubit.login(...)`) without the overhead of event classes.
- **States:** `AuthInitial`, `AuthLoading`, `Authenticated(user)`, `Unauthenticated`, `AuthError(message)`.

### `documents/document_bloc.dart`, `document_event.dart`, `document_state.dart`
- **Why full BLoC?** Document operations involve concurrent event streams: loading, debounced search filtering, status chip toggling, file uploading with optimistic UI addition, and background status polling.
- **Events:** `LoadDocuments`, `FilterDocumentsByStatus`, `SearchDocuments`, `UploadDocumentEvent`, `DeleteDocumentEvent`.

### `chat/chat_bloc.dart`, `chat_event.dart`, `chat_state.dart`
- **Why full BLoC?** Chat requires optimistic UI updates: when `SendMessageEvent` is dispatched, the user message is displayed immediately while `isSending: true` is emitted to show the AI thinking pulse indicator.
- **Events:** `LoadConversations`, `LoadMessages`, `SendMessageEvent`, `ClearConversationEvent`.

### `theme/theme_cubit.dart` & `theme_state.dart`
- **Why it exists:** Controls application theme mode (`ThemeMode.system`, `ThemeMode.light`, `ThemeMode.dark`) and persists user preference.

---

## 8. Presentation Layer — Screens (`lib/screens/`)

1. **`splash/splash_screen.dart`**: Animated brand intro using `AnimationController`, checks active session via `AuthCubit`, and navigates to `/home` or `/onboarding`.
2. **`onboarding/onboarding_screen.dart`**: Interactive `PageView` carousel highlighting Document Intelligence, Conversational RAG, and Comparative Research.
3. **`auth/login_screen.dart`**: Form-validated sign-in with email and password, inline loading spinner, and error toasts.
4. **`auth/signup_screen.dart`**: Account registration with name, email, password, and confirmation checks.
5. **`auth/forgot_password_screen.dart`**: Password reset request with inline confirmation alert banner.
6. **`home/home_screen.dart`**: Central cockpit dashboard with user greeting, Quick Actions grid (Upload, Chat, Summarize, Compare), recent papers, and recent chat history.
7. **`documents/documents_screen.dart`**: Searchable document library with status filter chips (`All`, `Ready`, `Processing`, `Pending`, `Failed`), swipe-to-refresh, and delete confirmation.
8. **`document_details/document_details_screen.dart`**: Deep-dive metadata view (file size, page count, format, upload date) with direct action triggers ("Chat with Doc", "View Summary").
9. **`upload_document/upload_document_screen.dart`**: Drag-and-drop document dropzone, file validation, and real-time processing indicator animation.
10. **`chat/conversation_history_screen.dart`**: Searchable archive of previous research chats grouped by document topic.
11. **`chat/chat_screen.dart`**: Conversational RAG interface with auto-scrolling, citation preview cards linking to source pages, suggested follow-up questions, and AI thinking indicators.
12. **`summary/summary_screen.dart`**: Executive summary view with copy-to-clipboard, key takeaway bullet points, and regenerate action.
13. **`compare_documents/compare_documents_screen.dart`**: Dual-document selector performing comparative synthesis (similarities, contrasts, structural divergences).
14. **`profile/profile_screen.dart`**: Researcher profile card, document volume statistics, theme toggle switch, and confirmable logout.
15. **`settings/settings_screen.dart`**: App preferences, Material 3 `SegmentedButton` theme picker, and active backend/AI connectivity indicators.

---

## 9. Presentation Layer — Widgets (`lib/widgets/`)

### `common/`
- **`app_button.dart`:** Primary, secondary, text, and danger buttons with automatic loading spinners and disabled state handling.
- **`app_text_field.dart`:** Text form field with prefix/suffix icons, obscure text toggles for passwords, and integrated validation styling.
- **`app_loader.dart`:** Circular progress indicators, inline spinners, and shimmer skeleton loaders.
- **`app_empty_state.dart`:** Illustrated empty placeholder with action button for zero-data views.
- **`app_error_widget.dart`:** Error recovery widget with retry button.
- **`app_app_bar.dart`:** Consistent branded app bar with back navigation and action slots.

### `cards/`
- **`quick_action_card.dart`:** Compact dashboard action tile with colored icon badge, title, and 2-line description.
- **`document_card.dart`:** Library document item with file format icon, title, page count, file size, and status badge.
- **`conversation_card.dart`:** Discussion preview tile with document anchor chip, last message snippet, and timestamp.

### `chat/`
- **`chat_message_bubble.dart`:** Renders user (right-aligned, primary background) and assistant (left-aligned, surface background) bubbles with Markdown support.
- **`chat_input_field.dart`:** Expanding text input with send action button and keyboard handling.
- **`source_citation_card.dart`:** Footnote card displaying page number, source excerpt, and document title.
- **`streaming_indicator.dart`:** Animated 3-dot pulsing indicator signaling active LLM token generation.

### `document/`
- **`document_status_badge.dart`:** Color-coded status badge (`Pending`, `Processing`, `Ready`, `Failed`).
- **`processing_indicator.dart`:** Multi-step pipeline animation (Text Extraction → Chunking → Embedding → Vector Storage).

### `dialogs/`
- **`confirm_dialog.dart`:** Action verification modal with confirm/cancel buttons.
- **`error_dialog.dart`:** Alert dialog explaining API or network failures.

---

## 10. Utilities (`lib/utils/`)

- **`file_utils.dart`:** Human-readable file size formatting (`formatBytes`) and extension extraction.
- **`date_formatter.dart`:** Relative time formatting ("2 hours ago", "Just now", "Yesterday") and absolute date stamps.
- **`validators.dart`:** Regex-based email and password validation rules.
- **`snackbar_utils.dart`:** Global helper for displaying error, success, and info toast banners.
- **`logger.dart`:** Colorized debug console logging with timestamp and level tags.

---

## 11. Supabase Database, Vector Store & Storage (`supabase/` & Services)

### PostgreSQL Schema Architecture (`supabase/migrations/001_initial_schema.sql`)

The backend schema provides a multi-tenant, secure, vector-indexed database for Document Intelligence and Conversational RAG:

```
┌─────────────────┐       ┌─────────────────┐
│   auth.users    │ ───1:1──▶   profiles      │
└─────────────────┘       └────────┬────────┘
                                   │ 1:N
                          ┌────────┴────────┐
                          │    documents    │
                          └────────┬────────┘
                                   │ 1:N
                ┌──────────────────┴──────────────────┐
                ▼                                     ▼
     ┌──────────────────────┐              ┌──────────────────────┐
     │   document_chunks    │              │    conversations     │
     │  vector(768) + HNSW  │              └──────────┬───────────┘
     └──────────────────────┘                         │ 1:N
                                           ┌──────────┴───────────┐
                                           │       messages       │
                                           │   citations (JSONB)  │
                                           └──────────────────────┘
```

#### 1. `profiles` Table
- **Purpose:** Application-specific user profile metadata (name, avatar, timestamps).
- **Auto-Sync Trigger (`handle_new_user()`):** A PostgreSQL trigger on `auth.users` automatically creates or updates the user profile whenever someone signs up or verifies their account.

#### 2. `documents` Table
- **Purpose:** Stores researcher document records (`name`, `file_url`, `file_type`, `file_size`, `page_count`, `processing_status`, `summary`, `metadata`).
- **Processing Status Pipeline:** Tracks document state: `pending` → `processing` → `ready` (or `failed`).

#### 3. `document_chunks` Table & `pgvector`
- **Purpose:** Stores extracted textual chunks along with their dense vector embeddings for RAG retrieval.
- **Vector Dimension:** `vector(768)` specifically matched to Google Gemini's `text-embedding-004` model.
- **HNSW Index (`idx_document_chunks_embedding_hnsw`):**
  - Uses `hnsw (embedding vector_cosine_ops) with (m = 16, ef_construction = 64)`.
  - **Why HNSW over IVFFlat?** Hierarchical Navigable Small World graphs provide sub-millisecond query performance and high recall without requiring index rebuilds or clustering training steps as the document collection grows.

#### 4. `conversations` & `messages` Tables
- **Purpose:** Stores multi-turn chat sessions and historical messages.
- **Grounding Citations:** Stored as `citations jsonb` within each assistant message row, containing source chunk ID, document name, page number, and text excerpt.

---

### Row-Level Security (RLS) Policies

All tables have `alter table ... enable row level security;` enabled. Policies strictly isolate multi-tenant data:
- **`profiles`:** Users can only view and update rows where `auth.uid() = id`.
- **`documents`:** Users can only query, insert, update, or delete rows where `auth.uid() = user_id`.
- **`document_chunks`:** Users can only query their own chunks (`auth.uid() = user_id`).
- **`conversations`:** Users can only access conversations where `auth.uid() = user_id`.
- **`messages`:** Access is gated through the parent conversation (`exists (select 1 from conversations c where c.id = messages.conversation_id and c.user_id = auth.uid())`).

---

### Semantic Search RPC: `match_document_chunks`

A custom PostgreSQL stored procedure executes vector similarity search safely on behalf of the user:
```sql
match_document_chunks(
  query_embedding vector(768),
  match_threshold float default 0.3,
  match_count int default 5,
  filter_document_id uuid default null
)
```
- **Cosine Similarity:** Computes `1 - (embedding <=> query_embedding)`.
- **Security Definer with RLS:** Filters by `user_id = auth.uid()`, guaranteeing a researcher can never retrieve or leak another user's document chunks.
- **Document Filtering:** Can search either within a single document (`filter_document_id`) or across all uploaded documents in the user's workspace.

---

### Storage Bucket Configuration (`documents`)

- **Bucket Name:** `documents` (private, non-public).
- **Max File Size:** 20,971,520 bytes (20 MB).
- **Allowed MIME Types:** `application/pdf`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document` (.docx), `text/plain` (.txt).
- **Storage RLS Policies on `storage.objects`:**
  - Files must be stored inside a directory named after the user's UUID: `userId/timestamp_filename.pdf`.
  - Enforced via `(storage.foldername(name))[1] = auth.uid()::text` for upload, download, and delete actions.
  - Generates time-limited signed URLs (`getSignedUrl`) for viewing or downloading private documents.

---

## 12. FastAPI Backend & RAG Pipeline Architecture (`backend/`)

### Microservice Architecture Overview

The backend microservice provides an asynchronous, type-safe API for document intelligence, vector operations, and Conversational RAG:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT APPLICATION                       │
│           (Uploads files to Supabase Storage, calls FastAPI)            │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ HTTP (Bearer Token)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          FASTAPI MICROSERVICE                           │
│  ┌───────────────────────┐  ┌──────────────────────┐  ┌──────────────┐  │
│  │   /documents/process  │  │   /chat/query (RAG)  │  │   /health    │  │
│  └──────────┬────────────┘  └──────────┬───────────┘  └──────────────┘  │
│             │                          │                                │
│             ▼                          ▼                                │
│  ┌──────────────────────┐   ┌──────────────────────┐                    │
│  │    ParserService     │   │     GeminiService    │                    │
│  │ (pypdf, docx, chunk) │   │ (text-embedding-004) │                    │
│  └──────────┬───────────┘   └──────────┬───────────┘                    │
│             │                          │                                │
│             ▼                          ▼                                │
│  ┌─────────────────────────────────────────────────┐                    │
│  │                   RAGService                    │                    │
│  │ (Embeds Chunks ──▶ Supabase RPC Match ──▶ LLM)  │                    │
│  └──────────────────────────┬──────────────────────┘                    │
└─────────────────────────────┼───────────────────────────────────────────┘
                              │ pgvector & SQL
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           SUPABASE BACKEND                              │
│       PostgreSQL (pgvector, match_document_chunks RPC) & Storage        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Core Components

#### 1. `config.py` (Pydantic Settings)
- **Why it exists:** Type-safe environment variable parsing with validation and defaults.
- **Key Settings:** `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, `embedding_model` (`text-embedding-004`), `llm_model` (`gemini-1.5-flash`), `embedding_dimension` (768).
- **Design Pattern:** Singleton with `@lru_cache()`.

#### 2. `dependencies.py` (Authentication & Security)
- **Why it exists:** Dependency injection for user authentication.
- **Mechanism:** Parses `Authorization: Bearer <token>`, validates the session with Supabase Auth, and injects a `UserContext(user_id, email)` into protected route handlers. Provides seamless development mode fallback.

#### 3. `parser_service.py` (Text Extraction & Chunking)
- **Why it exists:** Ingestion engine converting arbitrary file binaries into structured text blocks.
- **Format Handlers:**
  - `pypdf`: Extracts text page-by-page preserving document page indices.
  - `python-docx`: Extracts paragraph text, grouping into ~2000 character logical page equivalents.
  - `txt`: Decodes UTF-8 plain text with error replacement.
- **Recursive Semantic Chunker (`chunk_document_pages`):**
  - Uses sliding window chunking (`chunk_size=800`, `chunk_overlap=100`).
  - Intelligently splits along sentence (`. `) and paragraph (`\n`) boundaries.
  - Retains `page_number` and `metadata` for precise grounding citations.

#### 4. `gemini_service.py` (AI Embeddings & Generation)
- **Why it exists:** Direct bridge to Google Gemini AI models.
- **`get_embeddings(texts)`:** Calls `text-embedding-004` to generate 768-dimensional normalized vectors.
- **`generate_response(prompt, system_instruction)`:** Calls `gemini-1.5-flash` with low temperature (`0.2`) for high-precision, hallucination-resistant factual synthesis.
- **Offline Fallback:** Features deterministic normalized pseudo-embeddings and mock responses so developers can build and run unit tests without an active API key.

#### 5. `supabase_service.py` (Database & Storage Gateway)
- **Why it exists:** Server-side Supabase adapter with administrative service-role privileges.
- **Capabilities:**
  - Downloads binary files from the private `documents` bucket.
  - Bulk inserts chunks into `public.document_chunks`.
  - Executes `match_document_chunks` RPC for cosine distance similarity retrieval.
  - Updates document processing status (`processing` → `ready` or `failed`).

#### 6. `rag_service.py` (Conversational RAG Orchestrator)
- **Why it exists:** The central brain coordinating the Retrieval-Augmented Generation pipeline.
- **RAG Execution Flow (`query_rag`):**
  1. Computes dense vector embedding of the user's research query.
  2. Queries Supabase `match_document_chunks` RPC with cosine similarity threshold (`>= 0.3`).
  3. Constructs an augmented context block containing source page references and excerpts.
  4. Passes context and query to Gemini 1.5 Flash with strict academic grounding system instructions.
  5. Returns the generated answer paired with structured `Citation` models (`chunk_id`, `document_name`, `page_number`, `content_preview`, `relevance_score`).
- **Additional Endpoints:**
  - `generate_summary(doc_id)`: Multi-part executive briefing generator.
  - `compare_documents(doc_id_1, doc_id_2)`: Cross-document comparative synthesis.
