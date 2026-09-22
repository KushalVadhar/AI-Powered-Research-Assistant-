import 'package:equatable/equatable.dart';

/// Citation model — a reference to a source document chunk.
class CitationModel extends Equatable {
  const CitationModel({
    required this.chunkId,
    required this.documentId,
    required this.documentName,
    required this.pageNumber,
    required this.contentPreview,
  });

  /// ID of the document chunk that was cited.
  final String chunkId;

  /// ID of the parent document.
  final String documentId;

  /// Document name for display (avoids an extra DB lookup).
  final String documentName;

  /// Page number where this content appears.
  final int pageNumber;

  /// Short preview of the cited text.
  final String contentPreview;

  factory CitationModel.fromJson(Map<String, dynamic> json) {
    return CitationModel(
      chunkId: json['chunk_id'] as String,
      documentId: json['document_id'] as String,
      documentName: json['document_name'] as String,
      pageNumber: json['page_number'] as int,
      contentPreview: (json['content_preview'] ?? json['excerpt'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunk_id': chunkId,
      'document_id': documentId,
      'document_name': documentName,
      'page_number': pageNumber,
      'content_preview': contentPreview,
    };
  }

  @override
  List<Object?> get props => [
        chunkId,
        documentId,
        documentName,
        pageNumber,
        contentPreview,
      ];
}
