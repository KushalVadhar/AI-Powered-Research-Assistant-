# AI Research Assistant — FastAPI Python Microservice

High-performance asynchronous backend service powering document parsing, recursive text chunking, Google Gemini vector embeddings, and citation-grounded Conversational RAG.

---

## Features

- **Document Processing**: Extracts text page-by-page from `.pdf` (`pypdf`), `.docx` (`python-docx`), and `.txt` documents.
- **Semantic Chunking**: Splits document pages into overlapping token-aware chunks preserving page numbers.
- **Dense Vector Embeddings**: Generates 768-dimensional embeddings using Google Gemini `text-embedding-004`.
- **pgvector Vector Store**: Inserts chunks and performs cosine distance matching using Supabase stored procedure `match_document_chunks`.
- **Grounded Conversational RAG**: Injects retrieved context into Gemini 1.5 Flash prompts, outputting structured citations.
- **Executive Summarization & Comparison**: Automates paper briefings and comparative synthesis across documents.
- **Dual-Mode Fallback**: Runs smoothly in development/testing mode with realistic fallbacks even before live API credentials are supplied.

---

## Quickstart

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
Copy `.env.example` to `.env` and configure your credentials:
```bash
cp .env.example .env
```

### 3. Run Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Interactive OpenAPI documentation will be available at [http://localhost:8000/docs](http://localhost:8000/docs).

### 4. Run Tests
```bash
pytest tests
```
