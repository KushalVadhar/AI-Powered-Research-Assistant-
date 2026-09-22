"""Document management, ingestion, summarization, and comparison router."""

from fastapi import APIRouter, Depends, HTTPException, status
from ..dependencies import UserContext, get_current_user
from ..models.schemas import (
    CompareRequest,
    CompareResponse,
    ProcessDocumentRequest,
    ProcessDocumentResponse,
    SummaryRequest,
    SummaryResponse,
)
from ..services.rag_service import RAGService

router = APIRouter(prefix="/documents", tags=["Documents"])
rag_service = RAGService()


@router.post("/process", response_model=ProcessDocumentResponse)
async def process_document(
    request: ProcessDocumentRequest,
    current_user: UserContext = Depends(get_current_user),
) -> ProcessDocumentResponse:
    """
    Ingests and parses a document, extracts pages, chunks text, generates
    768-dimensional Gemini vector embeddings, and stores them in Supabase.
    """
    try:
        user_id = request.user_id or current_user.user_id
        result = await rag_service.ingest_document(
            document_id=request.document_id,
            file_url=request.file_url,
            file_name=request.file_name,
            file_type=request.file_type,
            user_id=user_id,
        )
        return ProcessDocumentResponse(
            success=True,
            document_id=request.document_id,
            chunk_count=result["chunk_count"],
            page_count=result["page_count"],
            message="Document parsed, chunked, and embedded into vector store successfully.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Document processing failed: {str(e)}",
        )


@router.post("/summarize", response_model=SummaryResponse)
async def summarize_document(
    request: SummaryRequest,
    current_user: UserContext = Depends(get_current_user),
) -> SummaryResponse:
    """Generates an executive research summary for a document."""
    try:
        summary = await rag_service.generate_summary(request.document_id)
        return SummaryResponse(
            success=True,
            document_id=request.document_id,
            summary=summary,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Summarization failed: {str(e)}",
        )


@router.post("/compare", response_model=CompareResponse)
async def compare_documents(
    request: CompareRequest,
    current_user: UserContext = Depends(get_current_user),
) -> CompareResponse:
    """Performs comparative synthesis across two research documents."""
    try:
        comparison = await rag_service.compare_documents(
            doc_id_1=request.doc_id_1,
            doc_id_2=request.doc_id_2,
        )
        return CompareResponse(
            success=True,
            document1=comparison["document1"],
            document2=comparison["document2"],
            similarities=comparison["similarities"],
            differences=comparison["differences"],
            synthesis=comparison["synthesis"],
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Comparison failed: {str(e)}",
        )
