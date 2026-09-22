"""Tests for /health endpoint and configuration."""

import pytest
from fastapi.testclient import TestClient
from backend.app.main import app
from backend.app.config import get_settings


def test_health_check_endpoint():
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["embedding_model"] == "text-embedding-004"
    assert data["llm_model"] == "gemini-1.5-flash"


def test_config_singleton():
    s1 = get_settings()
    s2 = get_settings()
    assert s1 is s2
    assert s1.embedding_dimension == 768
