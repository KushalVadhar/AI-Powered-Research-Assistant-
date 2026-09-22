/// Document repository interface contract.
library;

import 'dart:typed_data';

import '../models/data/document_model.dart';
import '../models/enums/document_status.dart';
import '../network/api_result.dart';

abstract class DocumentRepository {
  /// Fetches all documents with optional search and status filtering.
  Future<ApiResult<List<DocumentModel>>> getDocuments({
    String? searchQuery,
    DocumentStatus? statusFilter,
  });

  /// Retrieves detailed information for a single document by ID.
  Future<ApiResult<DocumentModel>> getDocumentById(String id);

  /// Uploads a new document file.
  Future<ApiResult<DocumentModel>> uploadDocument({
    required String filePath,
    required String fileName,
    int? fileSize,
    Uint8List? fileBytes,
  });

  /// Triggers processing/vector embedding pipeline for a document.
  Future<ApiResult<DocumentModel>> processDocument(String id);

  /// Generates or fetches the AI summary for a document.
  Future<ApiResult<String>> generateSummary(String id);

  /// Compares two documents and extracts similarities and differences.
  Future<ApiResult<Map<String, dynamic>>> compareDocuments({
    required String docId1,
    required String docId2,
  });

  /// Permanently deletes a document.
  Future<ApiResult<void>> deleteDocument(String id);

  /// Optional stream for real-time document status updates.
  Stream<List<DocumentModel>>? watchDocuments({String? userId}) => null;
}
