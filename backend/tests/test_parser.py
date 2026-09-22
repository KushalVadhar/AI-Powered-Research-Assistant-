"""Unit tests for ParserService text extraction and chunking."""

import pytest
from backend.app.services.parser_service import ParserService


def test_extract_text_txt():
    sample_text = b"Attention Is All You Need. A research paper on Transformers."
    pages = ParserService.extract_text_by_pages(sample_text, "txt")
    assert len(pages) == 1
    assert pages[0]["page_number"] == 1
    assert "Transformers" in pages[0]["text"]


def test_chunk_document_pages_small():
    pages = [
        {"page_number": 1, "text": "Short introduction to Generative AI."},
        {"page_number": 2, "text": "Brief discussion on vector databases."},
    ]
    chunks = ParserService.chunk_document_pages(pages, chunk_size=500, chunk_overlap=50)
    assert len(chunks) == 2
    assert chunks[0]["page_number"] == 1
    assert chunks[1]["page_number"] == 2
    assert chunks[0]["chunk_index"] == 0
    assert chunks[1]["chunk_index"] == 1


def test_chunk_document_pages_large_with_overlap():
    long_text = "Word " * 300  # 1500 chars
    pages = [{"page_number": 1, "text": long_text}]
    chunks = ParserService.chunk_document_pages(pages, chunk_size=400, chunk_overlap=50)
    assert len(chunks) > 1
    # Verify continuous indexing and preserved page number
    for idx, c in enumerate(chunks):
        assert c["chunk_index"] == idx
        assert c["page_number"] == 1
        assert len(c["content"]) > 0
