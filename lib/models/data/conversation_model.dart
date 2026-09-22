import 'package:equatable/equatable.dart';

import 'chat_message_model.dart';

/// Conversation model — a chat session about a document.
class ConversationModel extends Equatable {
  const ConversationModel({
    required this.id,
    required this.userId,
    this.documentId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.documentName,
  });

  final String id;
  final String userId;

  /// The document this conversation is about (null for multi-doc).
  final String? documentId;

  /// Conversation title (auto-generated from first question or user-set).
  final String title;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Preview of the last message (for conversation list screen).
  final ChatMessageModel? lastMessage;

  /// Document name for display in conversation list.
  final String? documentName;

  /// Whether this conversation is linked to a specific document.
  bool get hasDocument => documentId != null;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      documentId: json['document_id'] as String?,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(
              json['last_message'] as Map<String, dynamic>)
          : null,
      documentName: json['document_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'document_id': documentId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_message': lastMessage?.toJson(),
      'document_name': documentName,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? documentId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChatMessageModel? lastMessage,
    String? documentName,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      documentName: documentName ?? this.documentName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        documentId,
        title,
        createdAt,
        updatedAt,
        lastMessage,
        documentName,
      ];
}
