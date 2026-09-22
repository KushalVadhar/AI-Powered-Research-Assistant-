/// Chat state definitions for ChatBloc.
library;

import 'package:equatable/equatable.dart';
import '../../models/data/chat_message_model.dart';
import '../../models/data/conversation_model.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized chat state.
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading conversation history or thread.
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Conversation list loaded for the conversations screen.
class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

/// Messages loaded for an active conversation thread.
class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final ConversationModel? conversation;

  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.isSending = false,
    this.conversation,
  });

  MessagesLoaded copyWith({
    String? conversationId,
    List<ChatMessageModel>? messages,
    bool? isSending,
    ConversationModel? conversation,
  }) {
    return MessagesLoaded(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      conversation: conversation ?? this.conversation,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages, isSending, conversation];
}

/// A chat operation failed.
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
