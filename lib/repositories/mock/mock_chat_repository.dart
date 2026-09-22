/// In-memory mock chat repository with realistic RAG answers and citations.
library;

import '../../models/data/chat_message_model.dart';
import '../../models/data/citation_model.dart';
import '../../models/data/conversation_model.dart';
import '../../models/enums/message_role.dart';
import '../../network/api_exception.dart';
import '../../network/api_result.dart';
import '../chat_repository.dart';
import 'mock_data.dart';

class MockChatRepository implements ChatRepository {
  final List<ConversationModel> _conversations;
  final Map<String, List<ChatMessageModel>> _messages;
  final Duration delay;

  MockChatRepository({
    this.delay = const Duration(milliseconds: 400),
  })  : _conversations = List.from(MockData.conversations),
        _messages = {
          'conv-001': List.from(MockData.transformerChatMessages),
          'conv-002': List.from(MockData.ragChatMessages),
          'conv-003': [],
        };

  @override
  Future<ApiResult<List<ConversationModel>>> getConversations() async {
    await Future.delayed(delay);
    final sorted = List<ConversationModel>.from(_conversations)
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    return ApiSuccess(sorted);
  }

  @override
  Future<ApiResult<ConversationModel>> getConversationById(String conversationId) async {
    await Future.delayed(delay);
    final conv = _conversations.cast<ConversationModel?>().firstWhere(
          (c) => c?.id == conversationId,
          orElse: () => null,
        );

    if (conv == null) {
      return const ApiFailure(NotFoundException(message: 'Conversation not found'));
    }

    return ApiSuccess(conv);
  }

  @override
  Future<ApiResult<ConversationModel>> createConversation({
    String? documentId,
    required String title,
  }) async {
    await Future.delayed(delay);

    final newConv = ConversationModel(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      userId: MockData.currentUser.id,
      documentId: documentId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      documentName: documentId != null ? 'Research Document' : null,
    );

    _conversations.insert(0, newConv);
    _messages[newConv.id] = [];

    return ApiSuccess(newConv);
  }

  @override
  Future<ApiResult<List<ChatMessageModel>>> getMessages(String conversationId) async {
    await Future.delayed(delay);
    final list = _messages[conversationId] ?? [];
    return ApiSuccess(List.from(list));
  }

  @override
  Future<ApiResult<ChatMessageModel>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    // 1. Add user message immediately
    final userMsg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
    );

    _messages.putIfAbsent(conversationId, () => []).add(userMsg);

    // 2. Simulate AI thinking / generation delay
    await Future.delayed(const Duration(milliseconds: 900));

    // 3. Generate grounded AI response with citations
    final aiMsg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content:
          'Based on the document context, here is what was found regarding your question:\n\n'
          'The research highlights key structural properties that optimize retrieval accuracy while maintaining context continuity. '
          'Empirical benchmarks demonstrate that semantic chunking combined with cross-encoder re-ranking outperforms standard dense retrieval.\n\n'
          'Refer to the attached source citation for the exact experimental parameters.',
      createdAt: DateTime.now(),
      citations: [
        CitationModel(
          chunkId: 'chunk-${DateTime.now().millisecondsSinceEpoch}',
          documentId: 'doc-001',
          documentName: 'Research Paper Evidence',
          pageNumber: 4,
          contentPreview:
              'Cross-encoder re-ranking on top-20 retrieved candidate chunks achieved a MAP@10 improvement of +14.2% over naive dot-product search.',
        ),
      ],
    );

    _messages[conversationId]!.add(aiMsg);

    // Update conversation lastMessage
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        lastMessage: aiMsg,
        updatedAt: DateTime.now(),
      );
    }

    return ApiSuccess(aiMsg);
  }

  @override
  Future<ApiResult<void>> deleteConversation(String conversationId) async {
    await Future.delayed(delay);
    _conversations.removeWhere((c) => c.id == conversationId);
    _messages.remove(conversationId);
    return const ApiSuccess(null);
  }
}
