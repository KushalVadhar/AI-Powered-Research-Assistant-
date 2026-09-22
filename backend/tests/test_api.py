"""FastAPI endpoint integration tests."""

import pytest
from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)
auth_headers = {"Authorization": "Bearer mock_test_token"}


def test_api_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"


def test_api_process_document():
    payload = {
        "document_id": "doc_api_test",
        "file_url": "documents/usr_1/sample.txt",
        "file_name": "sample.txt",
        "file_type": "txt",
    }
    res = client.post("/documents/process", json=payload, headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["document_id"] == "doc_api_test"
    assert data["chunk_count"] >= 1


def test_api_summarize_document():
    payload = {"document_id": "doc_api_test"}
    res = client.post("/documents/summarize", json=payload, headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert len(data["summary"]) > 0


def test_api_compare_documents():
    payload = {
        "doc_id_1": "doc_1",
        "doc_id_2": "doc_2",
    }
    res = client.post("/documents/compare", json=payload, headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert len(data["similarities"]) > 0
    assert len(data["differences"]) > 0


def test_api_chat_query():
    payload = {
        "message": "Explain the key advantages of multi-head attention.",
        "document_id": "doc_api_test",
        "history": [],
    }
    res = client.post("/chat/query", json=payload, headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert "answer" in data
    assert len(data["answer"]) > 0
    assert "citations" in data
    assert len(data["citations"]) >= 1
    assert data["model_used"] == "gemini-1.5-flash"
