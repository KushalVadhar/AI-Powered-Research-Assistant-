import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:ai_research_assistant/models/enums/message_role.dart';
import 'package:ai_research_assistant/network/api_exception.dart';
import 'package:ai_research_assistant/network/api_result.dart';
import 'package:ai_research_assistant/repositories/supabase_chat_repository.dart';
import 'supabase_document_repository_test.dart';
import 'supabase_storage_and_db_test.dart';

void main() {
  group('SupabaseChatRepository Unit Tests', () {
    late FakeSupabaseDatabaseService dbService;
    late FakeDocAuthService authService;
    late SupabaseChatRepository repository;

    const testUser = supabase.User(
      id: 'usr_turing_001',
      appMetadata: {},
      userMetadata: {'full_name': 'Dr. Alan Turing'},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    );

    setUp(() {
      dbService = FakeSupabaseDatabaseService();
      authService = FakeDocAuthService(mockUser: testUser);
      repository = SupabaseChatRepository(
        databaseService: dbService,
        authService: authService,
      );
    });

    test('getConversations returns UnauthorizedException when user is unauthenticated', () async {
      authService.mockUser = null;

      final result = await repository.getConversations();
      expect(result, isA<ApiFailure>());
      final failure = result as ApiFailure;
      expect(failure.exception, isA<UnauthorizedException>());
    });

    test('getConversations returns conversations with lastMessage and documentName populated', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Seed a document
      dbService.documents.add({
        'id': 'doc_foundations',
        'user_id': testUser.id,
        'name': 'Transformer Foundations.pdf',
        'file_url': 'documents/test.pdf',
        'file_type': 'pdf',
        'file_size': 1024,
        'processing_status': 'ready',
        'created_at': now,
      });

      // Seed a conversation
      dbService.conversations.add({
        'id': 'conv_123',
        'user_id': testUser.id,
        'document_id': 'doc_foundations',
        'title': 'Attention Mechanism Analysis',
        'created_at': now,
        'updated_at': now,
      });

      // Seed a message
      dbService.messages.add({
        'id': 'msg_001',
        'conversation_id': 'conv_123',
        'role': 'assistant',
        'content': 'Self-attention scales with sequence length.',
        'citations': [],
        'created_at': now,
      });

      final result = await repository.getConversations();
      expect(result, isA<ApiSuccess>());
      final conversations = (result as ApiSuccess).data;
      expect(conversations.length, 1);
      expect(conversations.first.title, 'Attention Mechanism Analysis');
      expect(conversations.first.documentName, 'Transformer Foundations.pdf');
      expect(conversations.first.lastMessage?.content, 'Self-attention scales with sequence length.');
    });

    test('getConversationById returns conversation when found and NotFoundException when missing', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      dbService.conversations.add({
        'id': 'conv_abc',
        'user_id': testUser.id,
        'document_id': null,
        'title': 'General Research Ideas',
        'created_at': now,
        'updated_at': now,
      });

      final foundResult = await repository.getConversationById('conv_abc');
      expect(foundResult, isA<ApiSuccess>());
      expect((foundResult as ApiSuccess).data.title, 'General Research Ideas');

      final notFoundResult = await repository.getConversationById('non_existent');
      expect(notFoundResult, isA<ApiFailure>());
      expect((notFoundResult as ApiFailure).exception, isA<NotFoundException>());
    });

    test('createConversation creates new record and returns ConversationModel', () async {
      final result = await repository.createConversation(
        title: 'New Topic Discussion',
        documentId: null,
      );

      expect(result, isA<ApiSuccess>());
      final conv = (result as ApiSuccess).data;
      expect(conv.title, 'New Topic Discussion');
      expect(conv.userId, testUser.id);
      expect(dbService.conversations.length, 1);
    });

    test('getMessages returns chronological messages for conversation', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      dbService.messages.addAll([
        {
          'id': 'msg_1',
          'conversation_id': 'conv_target',
          'role': 'user',
          'content': 'What is RAG?',
          'citations': [],
          'created_at': now,
        },
        {
          'id': 'msg_2',
          'conversation_id': 'conv_target',
          'role': 'assistant',
          'content': 'Retrieval-Augmented Generation.',
          'citations': [],
          'created_at': now,
        },
      ]);

      final result = await repository.getMessages('conv_target');
      expect(result, isA<ApiSuccess>());
      final messages = (result as ApiSuccess).data;
      expect(messages.length, 2);
      expect(messages[0].isUser, true);
      expect(messages[1].isAssistant, true);
    });

    test('sendMessage persists user message, generates grounded response, and returns assistant message with citations', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      dbService.conversations.add({
        'id': 'conv_chat_test',
        'user_id': testUser.id,
        'document_id': null,
        'title': 'RAG Chat',
        'created_at': now,
        'updated_at': now,
      });

      final result = await repository.sendMessage(
        conversationId: 'conv_chat_test',
        content: 'How does cosine distance work for dense embeddings?',
      );

      expect(result, isA<ApiSuccess>());
      final aiMessage = (result as ApiSuccess).data;
      expect(aiMessage.role, MessageRole.assistant);
      expect(aiMessage.content.isNotEmpty, true);
      expect(aiMessage.hasCitations, true);

      // Verify that both user message and assistant message were inserted into DB
      expect(dbService.messages.length, 2);
      expect(dbService.messages[0]['role'], 'user');
      expect(dbService.messages[0]['content'], 'How does cosine distance work for dense embeddings?');
      expect(dbService.messages[1]['role'], 'assistant');
    });

    test('deleteConversation deletes conversation and messages', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      dbService.conversations.add({
        'id': 'conv_to_delete',
        'user_id': testUser.id,
        'document_id': null,
        'title': 'Delete me',
        'created_at': now,
        'updated_at': now,
      });

      final result = await repository.deleteConversation('conv_to_delete');
      expect(result, isA<ApiSuccess>());
      expect(dbService.conversations.isEmpty, true);
    });
  });
}
