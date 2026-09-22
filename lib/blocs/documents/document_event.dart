import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import '../../models/enums/document_status.dart';

sealed class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load or refresh the documents list with optional search and status filter.
class LoadDocuments extends DocumentEvent {
  final String? searchQuery;
  final DocumentStatus? statusFilter;

  const LoadDocuments({
    this.searchQuery,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter];
}

/// Request to upload a new document file.
class UploadDocumentEvent extends DocumentEvent {
  final String filePath;
  final String fileName;
  final int? fileSize;
  final Uint8List? fileBytes;

  const UploadDocumentEvent({
    required this.filePath,
    required this.fileName,
    this.fileSize,
    this.fileBytes,
  });

  @override
  List<Object?> get props => [filePath, fileName, fileSize, fileBytes];
}

/// Request to re-trigger processing for a pending or failed document.
class ProcessDocumentEvent extends DocumentEvent {
  final String documentId;

  const ProcessDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Request to generate an AI executive summary for a document.
class GenerateSummaryEvent extends DocumentEvent {
  final String documentId;

  const GenerateSummaryEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Request to delete a document permanently.
class DeleteDocumentEvent extends DocumentEvent {
  final String documentId;

  const DeleteDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
