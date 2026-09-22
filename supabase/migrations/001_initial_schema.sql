-- ============================================================================
-- Supabase Schema Migration: AI Powered Research Assistant
-- Migration: 001_initial_schema.sql
-- Description: Sets up pgvector, domain tables, RLS policies, vector match RPC,
--              and storage bucket configuration.
-- ============================================================================

-- 1. Enable Required Extensions
create extension if not exists "uuid-ossp";
create extension if not exists "vector" with schema extensions;

-- Set search path to include public and extensions
set search_path to public, extensions;

-- ============================================================================
-- 2. Profiles Table (Mirrors Supabase auth.users)
-- ============================================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text default '',
  avatar_url text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

comment on table public.profiles is 'Application-specific user profile metadata.';

-- Function to handle auto-creating a profile row on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = coalesce(excluded.full_name, profiles.full_name),
    avatar_url = coalesce(excluded.avatar_url, profiles.avatar_url),
    updated_at = timezone('utc'::text, now());
  return new;
end;
$$;

-- Trigger to execute handle_new_user on auth.users insert
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================================
-- 3. Documents Table
-- ============================================================================
create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  file_url text not null,
  file_type text not null check (file_type in ('pdf', 'docx', 'txt')),
  file_size bigint not null default 0,
  page_count int,
  processing_status text not null default 'pending' check (processing_status in ('pending', 'processing', 'ready', 'failed')),
  summary text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

comment on table public.documents is 'Document records uploaded by researchers.';
create index if not exists idx_documents_user_id on public.documents(user_id);
create index if not exists idx_documents_status on public.documents(processing_status);

-- ============================================================================
-- 4. Document Chunks Table (RAG Vector Storage)
-- ============================================================================
create table if not exists public.document_chunks (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references public.documents(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  chunk_index int not null,
  content text not null,
  embedding vector(768), -- Dimension 768 corresponds to Gemini text-embedding-004
  page_number int not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc'::text, now())
);

comment on table public.document_chunks is 'Extracted text chunks and embedding vectors for RAG.';
create index if not exists idx_document_chunks_document_id on public.document_chunks(document_id);
create index if not exists idx_document_chunks_user_id on public.document_chunks(user_id);

-- HNSW Vector Index for fast cosine similarity search
create index if not exists idx_document_chunks_embedding_hnsw
  on public.document_chunks
  using hnsw (embedding vector_cosine_ops)
  with (m = 16, ef_construction = 64);

-- ============================================================================
-- 5. Conversations Table
-- ============================================================================
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  document_id uuid references public.documents(id) on delete set null,
  title text not null default 'New Research Discussion',
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

comment on table public.conversations is 'Chat threads discussing specific documents or global workspace.';
create index if not exists idx_conversations_user_id on public.conversations(user_id);
create index if not exists idx_conversations_document_id on public.conversations(document_id);

-- ============================================================================
-- 6. Messages Table
-- ============================================================================
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  citations jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc'::text, now())
);

comment on table public.messages is 'Individual chat messages with source citation references.';
create index if not exists idx_messages_conversation_id on public.messages(conversation_id);

-- ============================================================================
-- 7. Row Level Security (RLS) Policies
-- ============================================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.documents enable row level security;
alter table public.document_chunks enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

-- Profiles Policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Documents Policies
create policy "Users can view their own documents"
  on public.documents for select
  using (auth.uid() = user_id);

create policy "Users can insert their own documents"
  on public.documents for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own documents"
  on public.documents for update
  using (auth.uid() = user_id);

create policy "Users can delete their own documents"
  on public.documents for delete
  using (auth.uid() = user_id);

-- Document Chunks Policies
create policy "Users can view their own document chunks"
  on public.document_chunks for select
  using (auth.uid() = user_id);

create policy "Users can insert their own document chunks"
  on public.document_chunks for insert
  with check (auth.uid() = user_id);

create policy "Users can delete their own document chunks"
  on public.document_chunks for delete
  using (auth.uid() = user_id);

-- Conversations Policies
create policy "Users can view their own conversations"
  on public.conversations for select
  using (auth.uid() = user_id);

create policy "Users can insert their own conversations"
  on public.conversations for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own conversations"
  on public.conversations for update
  using (auth.uid() = user_id);

create policy "Users can delete their own conversations"
  on public.conversations for delete
  using (auth.uid() = user_id);

-- Messages Policies (Through conversation ownership)
create policy "Users can view messages in their conversations"
  on public.messages for select
  using (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
      and c.user_id = auth.uid()
    )
  );

create policy "Users can insert messages into their conversations"
  on public.messages for insert
  with check (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
      and c.user_id = auth.uid()
    )
  );

create policy "Users can delete messages in their conversations"
  on public.messages for delete
  using (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
      and c.user_id = auth.uid()
    )
  );

-- ============================================================================
-- 8. Vector Similarity Search Stored Procedure (RAG RPC)
-- ============================================================================
create or replace function public.match_document_chunks (
  query_embedding vector(768),
  match_threshold float default 0.3,
  match_count int default 5,
  filter_document_id uuid default null
)
returns table (
  id uuid,
  document_id uuid,
  chunk_index int,
  content text,
  page_number int,
  similarity float
)
language plpgsql
security definer set search_path = public, extensions
as $$
begin
  return query
  select
    dc.id,
    dc.document_id,
    dc.chunk_index,
    dc.content,
    dc.page_number,
    1 - (dc.embedding <=> query_embedding) as similarity
  from public.document_chunks dc
  where (filter_document_id is null or dc.document_id = filter_document_id)
    and dc.user_id = auth.uid()
    and (1 - (dc.embedding <=> query_embedding)) > match_threshold
  order by dc.embedding <=> query_embedding
  limit match_count;
end;
$$;

comment on function public.match_document_chunks is 'Performs cosine vector search on document chunks for RAG queries with RLS safety.';

-- ============================================================================
-- 9. Storage Bucket & Policies Configuration
-- ============================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'documents',
  'documents',
  false,
  20971520, -- 20 MB max file size
  array[
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain'
  ]
)
on conflict (id) do update
set
  public = false,
  file_size_limit = 20971520,
  allowed_mime_types = array[
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain'
  ];

-- Storage RLS: Allow authenticated users to upload files to their own user folder
create policy "Users can upload documents into their own folder"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Storage RLS: Allow authenticated users to read their own files
create policy "Users can read their own uploaded documents"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Storage RLS: Allow authenticated users to delete their own files
create policy "Users can delete their own uploaded documents"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
