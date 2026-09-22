"""Supabase PostgREST, pgvector RPC, and Storage integration service."""

from typing import Any, Dict, List, Optional
from ..config import get_settings


class SupabaseService:
    """Handles communication with Supabase PostgreSQL, pgvector RPCs, and Storage."""

    def __init__(self):
        self.settings = get_settings()
        self._client = None

        if self.settings.is_supabase_configured:
            try:
                from supabase import create_client
                self._client = create_client(
                    self.settings.supabase_url,
                    self.settings.supabase_service_role_key,
                )
            except Exception as e:
                print(f"[SupabaseService] Failed to initialize live Supabase client: {e}")

        # In-memory store for development/testing when backend is unconfigured
        self._mock_documents: Dict[str, Dict[str, Any]] = {}
        self._mock_chunks: List[Dict[str, Any]] = []

    @property
    def is_live(self) -> bool:
        return self._client is not None

    async def get_document(self, document_id: str) -> Optional[Dict[str, Any]]:
        """Retrieves document record by ID."""
        if self._client:
            try:
                res = self._client.from_("documents").select("*").eq("id", document_id).maybe_single().execute()
                return res.data if res else None
            except Exception as e:
                print(f"[SupabaseService] get_document error: {e}")
        return self._mock_documents.get(document_id)

    async def download_document(self, file_url: str) -> bytes:
        """Downloads document file bytes from Supabase Storage."""
        if self._client:
            try:
                # file_url is stored as 'documents/userId/filename' or 'userId/filename'
                path = file_url.replace("documents/", "", 1) if file_url.startswith("documents/") else file_url
                res = self._client.storage.from_("documents").download(path)
                return res
            except Exception as e:
                print(f"[SupabaseService] download_document error: {e}")
        # Default mock document bytes for testing
        return b"%PDF-1.4 Mock document test content for AI Powered Research Assistant."

    async def insert_document_chunks(self, chunks: List[Dict[str, Any]]) -> None:
        """Inserts text chunks with dense vector embeddings into document_chunks table."""
        if not chunks:
            return

        if self._client:
            try:
                self._client.from_("document_chunks").insert(chunks).execute()
                return
            except Exception as e:
                print(f"[SupabaseService] insert_document_chunks error: {e}")

        self._mock_chunks.extend(chunks)

    async def update_document_status(
        self,
        document_id: str,
        status: str,
        page_count: Optional[int] = None,
        summary: Optional[str] = None,
    ) -> None:
        """Updates document processing status, page count, and summary."""
        payload: Dict[str, Any] = {"processing_status": status}
        if page_count is not None:
            payload["page_count"] = page_count
        if summary is not None:
            payload["summary"] = summary

        if self._client:
            try:
                self._client.from_("documents").update(payload).eq("id", document_id).execute()
                return
            except Exception as e:
                print(f"[SupabaseService] update_document_status error: {e}")

        if document_id in self._mock_documents:
            self._mock_documents[document_id].update(payload)
        else:
            self._mock_documents[document_id] = payload

    async def match_document_chunks(
        self,
        query_embedding: List[float],
        match_threshold: float = 0.3,
        match_count: int = 5,
        filter_document_id: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Executes pgvector cosine similarity search via match_document_chunks RPC."""
        if self._client:
            try:
                params = {
                    "query_embedding": query_embedding,
                    "match_threshold": match_threshold,
                    "match_count": match_count,
                    "filter_document_id": filter_document_id,
                }
                res = self._client.rpc("match_document_chunks", params).execute()
                return res.data if res and res.data else []
            except Exception as e:
                print(f"[SupabaseService] match_document_chunks RPC error: {e}")

        # In-memory cosine similarity matching for mock chunks
        matches = []
        for chunk in self._mock_chunks:
            if filter_document_id and chunk.get("document_id") != filter_document_id:
                continue
            emb = chunk.get("embedding")
            if emb:
                # Dot product (both are unit-normalized)
                sim = sum(a * b for a, b in zip(query_embedding, emb))
                if sim >= match_threshold:
                    matches.append({
                        "id": chunk.get("id", "mock_chunk_id"),
                        "document_id": chunk.get("document_id", filter_document_id or "doc_1"),
                        "chunk_index": chunk.get("chunk_index", 0),
                        "content": chunk.get("content", ""),
                        "page_number": chunk.get("page_number", 1),
                        "similarity": round(sim, 4),
                    })
        matches.sort(key=lambda x: x["similarity"], reverse=True)
        return matches[:match_count]
