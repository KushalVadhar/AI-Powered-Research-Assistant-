"""Document text extraction and recursive semantic chunking service."""

import io
from typing import Any, Dict, List
import pypdf
import docx


class ParserService:
    """Handles extracting text across formats and chunking for vector ingestion."""

    @staticmethod
    def extract_text_by_pages(file_bytes: bytes, file_type: str) -> List[Dict[str, Any]]:
        """
        Extracts text from binary document data page-by-page.
        Returns a list of dicts: [{'page_number': 1, 'text': '...'}]
        """
        file_type = file_type.lower().lstrip(".")
        pages: List[Dict[str, Any]] = []

        if file_type == "pdf":
            try:
                reader = pypdf.PdfReader(io.BytesIO(file_bytes))
                for idx, page in enumerate(reader.pages):
                    text = page.extract_text() or ""
                    clean_text = text.strip()
                    if clean_text:
                        pages.append({"page_number": idx + 1, "text": clean_text})
            except Exception as e:
                # Fallback if corrupt or empty
                pages.append({"page_number": 1, "text": f"Error parsing PDF: {e}"})

        elif file_type == "docx":
            try:
                doc = docx.Document(io.BytesIO(file_bytes))
                paragraphs = [p.text for p in doc.paragraphs if p.text.strip()]
                # Approximate 400 words / 2000 chars per page
                page_text = []
                page_num = 1
                curr_len = 0
                for p in paragraphs:
                    page_text.append(p)
                    curr_len += len(p)
                    if curr_len >= 2000:
                        pages.append({"page_number": page_num, "text": "\n\n".join(page_text)})
                        page_text = []
                        curr_len = 0
                        page_num += 1
                if page_text:
                    pages.append({"page_number": page_num, "text": "\n\n".join(page_text)})
            except Exception as e:
                pages.append({"page_number": 1, "text": f"Error parsing DOCX: {e}"})

        elif file_type == "txt":
            try:
                text = file_bytes.decode("utf-8", errors="replace").strip()
                pages.append({"page_number": 1, "text": text})
            except Exception as e:
                pages.append({"page_number": 1, "text": f"Error parsing TXT: {e}"})

        else:
            # Default fallback
            text = file_bytes.decode("utf-8", errors="replace").strip()
            pages.append({"page_number": 1, "text": text})

        # Ensure at least one page returned if document is completely empty
        if not pages:
            pages.append({"page_number": 1, "text": "Empty document."})

        return pages

    @staticmethod
    def chunk_document_pages(
        pages: List[Dict[str, Any]],
        chunk_size: int = 800,
        chunk_overlap: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Splits pages into overlapping character/token chunks preserving page references.
        """
        chunks: List[Dict[str, Any]] = []
        chunk_index = 0

        for page in pages:
            page_num = page["page_number"]
            text = page["text"]

            if len(text) <= chunk_size:
                chunks.append({
                    "chunk_index": chunk_index,
                    "content": text,
                    "page_number": page_num,
                    "metadata": {"char_count": len(text)},
                })
                chunk_index += 1
                continue

            # Sliding window chunking with overlap
            start = 0
            while start < len(text):
                end = start + chunk_size
                chunk_text = text[start:end]

                # Try to break at a paragraph or sentence boundary if possible
                if end < len(text):
                    last_newline = chunk_text.rfind("\n")
                    last_period = chunk_text.rfind(". ")
                    boundary = max(last_newline, last_period)
                    if boundary > chunk_size // 2:
                        end = start + boundary + 1
                        chunk_text = text[start:end]

                clean_chunk = chunk_text.strip()
                if clean_chunk:
                    chunks.append({
                        "chunk_index": chunk_index,
                        "content": clean_chunk,
                        "page_number": page_num,
                        "metadata": {"char_count": len(clean_chunk)},
                    })
                    chunk_index += 1

                start = end - chunk_overlap
                if start >= len(text) - chunk_overlap:
                    break

        return chunks
