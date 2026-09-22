import 'package:equatable/equatable.dart';

import '../enums/message_role.dart';
import 'citation_model.dart';

/// Chat message model — a single message in a conversation.
class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.citations = const [],
  });

  final String id;
  final String conversationId;

  /// Who sent this message (user, assistant, or system).
  final MessageRole role;

  /// Message text content.
  final String content;

  final DateTime createdAt;

  /// Source citations (only populated for assistant messages).
  final List<CitationModel> citations;

  /// Whether this message is from the user.
  bool get isUser => role == MessageRole.user;

  /// Whether this message is from the AI assistant.
  bool get isAssistant => role == MessageRole.assistant;

  /// Whether this message has source citations.
  bool get hasCitations => citations.isNotEmpty;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      citations: (json['citations'] as List<dynamic>?)
              ?.map((c) =>
                  CitationModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'citations': citations.map((c) => c.toJson()).toList(),
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
    List<CitationModel>? citations,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      citations: citations ?? this.citations,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        createdAt,
        citations,
      ];
}
