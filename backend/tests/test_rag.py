"""Unit tests for GeminiService and RAGService."""

import pytest
from backend.app.services.gemini_service import GeminiService
from backend.app.services.rag_service import RAGService
from backend.app.services.supabase_service import SupabaseService


@pytest.mark.asyncio
async def test_gemini_service_embedding_dimension():
    service = GeminiService()
    emb = await service.get_embedding("What is attention?")
    assert len(emb) == 768
    # Test batch embedding
    embs = await service.get_embeddings(["First text", "Second text"])
    assert len(embs) == 2
    assert len(embs[0]) == 768
    assert len(embs[1]) == 768


@pytest.mark.asyncio
async def test_gemini_service_generation():
    service = GeminiService()
    res = await service.generate_response("Explain self-attention in two sentences.")
    assert len(res) > 0
    assert isinstance(res, str)


@pytest.mark.asyncio
async def test_rag_service_ingest_and_query():
    gemini = GeminiService()
    supabase = SupabaseService()
    rag = RAGService(gemini_service=gemini, supabase_service=supabase)

    # 1. Ingest test document
    ingest_res = await rag.ingest_document(
        document_id="doc_test_123",
        file_url="documents/usr_1/test.txt",
        file_name="test.txt",
        file_type="txt",
        user_id="usr_1",
    )
    assert ingest_res["success"] is True
    assert ingest_res["chunk_count"] >= 1

    # 2. Query RAG
    query_res = await rag.query_rag(
        query="What are the key findings?",
        user_id="usr_1",
        document_id="doc_test_123",
    )
    assert len(query_res["answer"]) > 0
    assert len(query_res["citations"]) >= 1
    assert query_res["citations"][0].document_id == "doc_test_123"


@pytest.mark.asyncio
async def test_rag_service_summary_and_compare():
    gemini = GeminiService()
    supabase = SupabaseService()
    rag = RAGService(gemini_service=gemini, supabase_service=supabase)

    summary = await rag.generate_summary("doc_test_123")
    assert "Executive Summary" in summary or len(summary) > 50

    comparison = await rag.compare_documents("doc_A", "doc_B")
    assert "similarities" in comparison
    assert "differences" in comparison
    assert "synthesis" in comparison
