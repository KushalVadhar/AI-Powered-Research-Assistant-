/// Chat and conversation repository interface contract.
library;

import '../models/data/chat_message_model.dart';
import '../models/data/conversation_model.dart';
import '../network/api_result.dart';

abstract class ChatRepository {
  /// Fetches all active conversation threads for the user.
  Future<ApiResult<List<ConversationModel>>> getConversations();

  /// Retrieves a specific conversation by ID.
  Future<ApiResult<ConversationModel>> getConversationById(String conversationId);

  /// Creates a new conversation, optionally linked to a specific document.
  Future<ApiResult<ConversationModel>> createConversation({
    String? documentId,
    required String title,
  });

  /// Retrieves the message history for a conversation.
  Future<ApiResult<List<ChatMessageModel>>> getMessages(String conversationId);

  /// Sends a user question and retrieves the AI answer with citations.
  Future<ApiResult<ChatMessageModel>> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Deletes an entire conversation thread.
  Future<ApiResult<void>> deleteConversation(String conversationId);
}
