"""FastAPI application entry point, CORS middleware, exception handlers, and routing."""

import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import get_settings
from .routers import chat, documents, health


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle events for startup and shutdown."""
    settings = get_settings()
    print(f"[API] AI Research Assistant API initialized in [{settings.environment}] mode.")
    print(f"[API] LLM Model: {settings.llm_model} | Embeddings: {settings.embedding_model}")
    print(f"[API] Supabase Configured: {settings.is_supabase_configured} | Gemini Configured: {settings.is_gemini_configured}")
    yield
    print("[API] AI Research Assistant API shutting down.")


def create_app() -> FastAPI:
    """Creates and configures the FastAPI application."""
    settings = get_settings()

    app = FastAPI(
        title="AI Research Assistant API",
        description="High-performance backend for Document Intelligence, Gemini Vector Embeddings, and Conversational RAG.",
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    # CORS Middleware allowing Flutter mobile, desktop, and web origins
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Global Exception Handler
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "success": False,
                "error": "InternalServerError",
                "message": str(exc),
            },
        )

    # Mount Routers (both root and /api/v1 prefix for compatibility)
    app.include_router(health.router)
    app.include_router(documents.router)
    app.include_router(chat.router)

    app.include_router(health.router, prefix="/api/v1")
    app.include_router(documents.router, prefix="/api/v1")
    app.include_router(chat.router, prefix="/api/v1")

    return app


app = create_app()

if __name__ == "__main__":
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.environment == "development",
    )
