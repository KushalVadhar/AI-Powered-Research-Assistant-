# AI-Powered Research Assistant

An intelligent, full-stack research copilot built with **Flutter (Clean Architecture & BLoC)**, **FastAPI (Conversational RAG Microservice)**, **Supabase (PostgreSQL, Storage & pgvector)**, and **Google Gemini (1.5 Flash & text-embedding-004)**.

---

## 🌟 Key Features

- **Document Ingestion & Intelligence**: Upload research papers in `.pdf`, `.docx`, or `.txt`. Text is extracted page-by-page and chunked with token-aware sliding windows.
- **pgvector Vector Store**: Computes 768-dimensional dense vector embeddings with Google Gemini `text-embedding-004` and indexes them using HNSW graphs for sub-millisecond similarity search.
- **Grounded Conversational RAG**: Chat with your uploaded documents using Gemini 1.5 Flash. Every claim includes interactive **source citation cards** with exact page numbers and excerpts.
- **Executive Summaries & Comparative Synthesis**: Automatically generate structured briefings or compare methodologies, findings, and trade-offs between two papers.
- **Clean Architecture & Multi-Platform**: Flutter client strictly following Presentation -> BLoC -> Repository -> Network/Service layers.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 FLUTTER CLIENT APPLICATION                  │
│       (15 Screens, Material 3, BLoC/Cubit State Machines)   │
└──────────────┬───────────────────────────────┬──────────────┘
               │ HTTP (Bearer Token)           │ Supabase SDK
               ▼                               ▼
┌──────────────────────────────┐ ┌─────────────────────────────┐
│     FASTAPI MICROSERVICE     │ │      SUPABASE BACKEND       │
│  - Parser (pypdf, docx)      │ │  - Auth & User Profiles     │
│  - Chunker & Embeddings      │ │  - Private Storage Bucket   │
│  - Gemini 1.5 Flash RAG      │ │  - PostgreSQL + pgvector    │
│  - Stored Procedures (RPC)   │ │  - Row-Level Security (RLS) │
└──────────────┬───────────────┘ └─────────────▲───────────────┘
               │ pgvector RPC & Embeddings     │
               └───────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. Backend Setup (FastAPI)
```bash
cd backend
pip install -r requirements.txt
```

Create `backend/.env` with your credentials:
```ini
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
GEMINI_API_KEY=your-gemini-api-key
```

Run the backend server:
```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Interactive OpenAPI documentation will be live at `http://localhost:8000/docs`.

### 2. Frontend Setup (Flutter)
```bash
flutter pub get
```

Run tests:
```bash
flutter test
```

Launch the app:
```bash
# On Android Emulator:
flutter run -d emulator-5554

# On Windows Desktop:
flutter run -d windows
```

---

## 🧪 Testing Suite

- **Flutter Tests**: 65 unit, BLoC, and widget tests passing (`flutter test`).
- **Backend Tests**: 14 integration and RAG pipeline tests passing (`pytest tests`).
