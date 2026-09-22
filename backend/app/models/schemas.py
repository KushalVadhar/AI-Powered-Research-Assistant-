"""Pydantic schemas for request validation and structured API responses."""

from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = "healthy"
    environment: str = "development"
    supabase_configured: bool = False
    gemini_configured: bool = False
    embedding_model: str = "text-embedding-004"
    llm_model: str = "gemini-1.5-flash"


class Citation(BaseModel):
    chunk_id: str
    document_id: str
    document_name: str
    page_number: int = 1
    content_preview: str = Field(..., alias="content_preview")
    relevance_score: float = 0.0

    model_config = {
        "populate_by_name": True,
    }


class ProcessDocumentRequest(BaseModel):
    document_id: str
    file_url: str
    file_name: str
    file_type: str = "pdf"
    user_id: Optional[str] = None


class ProcessDocumentResponse(BaseModel):
    success: bool = True
    document_id: str
    chunk_count: int
    page_count: int
    message: str


class SummaryRequest(BaseModel):
    document_id: str
    user_id: Optional[str] = None


class SummaryResponse(BaseModel):
    success: bool = True
    document_id: str
    summary: str


class CompareRequest(BaseModel):
    doc_id_1: str
    doc_id_2: str
    user_id: Optional[str] = None


class CompareResponse(BaseModel):
    success: bool = True
    document1: str
    document2: str
    similarities: List[str]
    differences: List[str]
    synthesis: str


class ChatMessageItem(BaseModel):
    role: str
    content: str


class ChatQueryRequest(BaseModel):
    conversation_id: Optional[str] = None
    document_id: Optional[str] = None
    message: str
    history: List[ChatMessageItem] = Field(default_factory=list)
    user_id: Optional[str] = None


class ChatQueryResponse(BaseModel):
    conversation_id: str
    answer: str
    citations: List[Citation] = Field(default_factory=list)
    model_used: str = "gemini-1.5-flash"
