"""Application configuration and environment variables management using Pydantic Settings."""

from functools import lru_cache
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Supabase Credentials
    supabase_url: str = ""
    supabase_service_role_key: str = ""

    # Google Gemini Credentials
    gemini_api_key: str = ""

    # Application Settings
    environment: str = "development"
    host: str = "0.0.0.0"
    port: int = 8000
    log_level: str = "INFO"

    # AI Models
    embedding_model: str = "gemini-embedding-001"
    llm_model: str = "gemini-3.6-flash"
    embedding_dimension: int = 768

    # Chunking & RAG Defaults
    chunk_size: int = 800
    chunk_overlap: int = 100
    vector_match_threshold: float = 0.3
    vector_match_count: int = 5

    @property
    def is_supabase_configured(self) -> bool:
        return bool(self.supabase_url and self.supabase_service_role_key)

    @property
    def is_gemini_configured(self) -> bool:
        return bool(self.gemini_api_key)

    model_config = SettingsConfigDict(
        env_file=(".env", "backend/.env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache()
def get_settings() -> Settings:
    """Returns cached application settings singleton."""
    return Settings()
