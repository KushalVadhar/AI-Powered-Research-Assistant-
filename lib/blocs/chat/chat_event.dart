/// Chat event definitions for ChatBloc.
library;

import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load all conversations for the conversation history screen.
class LoadConversations extends ChatEvent {
  const LoadConversations();
}

/// Request to load the message history for a specific conversation.
class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Request to create a new conversation and jump to it.
class CreateConversationEvent extends ChatEvent {
  final String title;
  final String? documentId;

  const CreateConversationEvent({
    required this.title,
    this.documentId,
  });

  @override
  List<Object?> get props => [title, documentId];
}

/// Request to post a user question and await the AI response.
class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String content;

  const SendMessageEvent({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, content];
}

/// Request to delete a conversation thread.
class DeleteConversationEvent extends ChatEvent {
  final String conversationId;

  const DeleteConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
