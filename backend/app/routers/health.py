"""Health check router reporting service status and model configurations."""

from fastapi import APIRouter
from ..config import get_settings
from ..models.schemas import HealthResponse

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Returns application health status, active models, and service states."""
    settings = get_settings()
    return HealthResponse(
        status="healthy",
        environment=settings.environment,
        supabase_configured=settings.is_supabase_configured,
        gemini_configured=settings.is_gemini_configured,
        embedding_model=settings.embedding_model,
        llm_model=settings.llm_model,
    )
