"""Conversational RAG router generating grounded answers with source citations."""

import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from ..dependencies import UserContext, get_current_user
from ..models.schemas import ChatQueryRequest, ChatQueryResponse
from ..services.rag_service import RAGService

router = APIRouter(prefix="/chat", tags=["Chat"])
rag_service = RAGService()


@router.post("/query", response_model=ChatQueryResponse)
async def chat_query(
    request: ChatQueryRequest,
    current_user: UserContext = Depends(get_current_user),
) -> ChatQueryResponse:
    """
    Executes Conversational RAG:
    - Embeds query with Gemini text-embedding-004
    - Retrieves top matching document chunks via pgvector
    - Generates grounded answer with Gemini 1.5 Flash
    - Returns structured footnote citations
    """
    try:
        user_id = request.user_id or current_user.user_id
        conversation_id = request.conversation_id or str(uuid.uuid4())

        history_payload = [
            {"role": h.role, "content": h.content}
            for h in request.history
        ]

        result = await rag_service.query_rag(
            query=request.message,
            user_id=user_id,
            document_id=request.document_id,
            history=history_payload,
        )

        return ChatQueryResponse(
            conversation_id=conversation_id,
            answer=result["answer"],
            citations=result["citations"],
            model_used=result["model_used"],
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Chat query failed: {str(e)}",
        )
