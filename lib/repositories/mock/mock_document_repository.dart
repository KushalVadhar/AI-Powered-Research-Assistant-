/// In-memory mock document repository with realistic data and filtering.
library;

import 'dart:typed_data';

import '../../models/data/document_model.dart';
import '../../models/enums/document_status.dart';
import '../../models/enums/file_type.dart';
import '../../network/api_exception.dart';
import '../../network/api_result.dart';
import '../document_repository.dart';
import 'mock_data.dart';

class MockDocumentRepository implements DocumentRepository {
  final List<DocumentModel> _documents;
  final Duration delay;

  MockDocumentRepository({
    this.delay = const Duration(milliseconds: 400),
    List<DocumentModel>? initialDocuments,
  }) : _documents = List.from(initialDocuments ?? MockData.documents);

  @override
  Future<ApiResult<List<DocumentModel>>> getDocuments({
    String? searchQuery,
    DocumentStatus? statusFilter,
  }) async {
    await Future.delayed(delay);

    var results = List<DocumentModel>.from(_documents);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      results = results.where((doc) => doc.name.toLowerCase().contains(query)).toList();
    }

    if (statusFilter != null) {
      results = results.where((doc) => doc.status == statusFilter).toList();
    }

    // Sort by latest created first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ApiSuccess(results);
  }

  @override
  Future<ApiResult<DocumentModel>> getDocumentById(String id) async {
    await Future.delayed(delay);

    final doc = _documents.cast<DocumentModel?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );

    if (doc == null) {
      return const ApiFailure(NotFoundException(message: 'Document not found'));
    }

    return ApiSuccess(doc);
  }

  @override
  Future<ApiResult<DocumentModel>> uploadDocument({
    required String filePath,
    required String fileName,
    int? fileSize,
    Uint8List? fileBytes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newDoc = DocumentModel(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      userId: MockData.currentUser.id,
      name: fileName,
      fileUrl: 'https://storage.supabase.co/mock/$fileName',
      fileType: FileType.fromExtension(fileName) ?? FileType.pdf,
      fileSize: fileSize ?? (fileBytes != null ? (fileBytes as dynamic).length as int : 1500000),
      pageCount: 8,
      status: DocumentStatus.ready,
      createdAt: DateTime.now(),
    );

    _documents.insert(0, newDoc);
    return ApiSuccess(newDoc);
  }

  @override
  Stream<List<DocumentModel>> watchDocuments({String? userId}) {
    return Stream.value(List.unmodifiable(_documents));
  }

  @override
  Future<ApiResult<DocumentModel>> processDocument(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) {
      return const ApiFailure(NotFoundException(message: 'Document not found'));
    }

    final updated = _documents[index].copyWith(
      status: DocumentStatus.ready,
      pageCount: 12,
      updatedAt: DateTime.now(),
    );
    _documents[index] = updated;

    return ApiSuccess(updated);
  }

  @override
  Future<ApiResult<String>> generateSummary(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) {
      return const ApiFailure(NotFoundException(message: 'Document not found'));
    }

    const mockSummary =
        '### Executive Summary\n'
        'This research document outlines the foundational principles and benchmark findings for modern transformer and neural architectures.\n\n'
        '### Key Findings\n'
        '- **Architectural Efficiency**: Multi-head self-attention mechanisms scale with lower quadratic computational overhead when using flash attention.\n'
        '- **Retrieval Grounding**: Chunk size tuning between 512 and 1024 tokens yielded the optimal retrieval-relevance trade-off for RAG accuracy.\n'
        '- **Evaluation Metrics**: Faithfulness and answer relevance scored above 0.88 across benchmark tests.\n\n'
        '### Conclusion\n'
        'The proposed methods demonstrate significant reductions in inference latency while preserving contextual integrity.';

    _documents[index] = _documents[index].copyWith(summary: mockSummary);
    return const ApiSuccess(mockSummary);
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> compareDocuments({
    required String docId1,
    required String docId2,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final doc1 = _documents.cast<DocumentModel?>().firstWhere((d) => d?.id == docId1, orElse: () => null);
    final doc2 = _documents.cast<DocumentModel?>().firstWhere((d) => d?.id == docId2, orElse: () => null);

    if (doc1 == null || doc2 == null) {
      return const ApiFailure(NotFoundException(message: 'One or both documents not found'));
    }

    final comparisonData = {
      'document1': doc1.name,
      'document2': doc2.name,
      'similarities': [
        'Both papers focus on language model alignment and vector embeddings.',
        'Both utilize benchmark datasets for empirical validation.',
        'Both evaluate inference latency under standard hardware constraints.',
      ],
      'differences': [
        '${doc1.name} proposes fine-tuning strategies, while ${doc2.name} emphasizes zero-shot prompt routing.',
        '${doc1.name} uses cosine similarity metrics, whereas ${doc2.name} leverages dot-product distance.',
        'Evaluation test sizes differ by a factor of 4x.',
      ],
      'synthesis':
          'Combining the retrieval strategy from ${doc1.name} with the indexing pipeline from ${doc2.name} yields an optimal end-to-end architecture.',
    };

    return ApiSuccess(comparisonData);
  }

  @override
  Future<ApiResult<void>> deleteDocument(String id) async {
    await Future.delayed(delay);
    _documents.removeWhere((d) => d.id == id);
    return const ApiSuccess(null);
  }
}
