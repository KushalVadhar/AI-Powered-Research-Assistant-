import 'package:equatable/equatable.dart';

import '../enums/document_status.dart';
import '../enums/file_type.dart';

/// Document model — represents an uploaded document.
class DocumentModel extends Equatable {
  const DocumentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    this.pageCount,
    required this.status,
    this.summary,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;

  /// Original filename (e.g., "research_paper.pdf").
  final String name;

  /// Supabase Storage URL or path.
  final String fileUrl;

  /// Document type (pdf, docx, txt).
  final FileType fileType;

  /// File size in bytes.
  final int fileSize;

  /// Total pages (null if not yet processed).
  final int? pageCount;

  /// Current processing status.
  final DocumentStatus status;

  /// Cached summary text (null if not yet summarized).
  final String? summary;

  /// Flexible metadata (section titles, author, etc.).
  final Map<String, dynamic>? metadata;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Whether the document has been fully processed and is ready for queries.
  bool get isReady => status == DocumentStatus.ready;

  /// Whether the document is currently being processed.
  bool get isProcessing => status == DocumentStatus.processing;

  /// Whether processing failed.
  bool get hasFailed => status == DocumentStatus.failed;

  /// Whether a summary has been generated.
  bool get hasSummary => summary != null && summary!.isNotEmpty;

  /// Human-readable file size.
  ///
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: FileType.fromExtension(json['file_type'] as String) ??
          FileType.pdf,
      fileSize: json['file_size'] as int,
      pageCount: json['page_count'] as int?,
      status: DocumentStatus.fromJson(json['processing_status'] as String),
      summary: json['summary'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'file_url': fileUrl,
      'file_type': fileType.extension,
      'file_size': fileSize,
      'page_count': pageCount,
      'processing_status': status.toJson(),
      'summary': summary,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DocumentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? fileUrl,
    FileType? fileType,
    int? fileSize,
    int? pageCount,
    DocumentStatus? status,
    String? summary,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        fileUrl,
        fileType,
        fileSize,
        pageCount,
        status,
        summary,
        metadata,
        createdAt,
        updatedAt,
      ];
}
