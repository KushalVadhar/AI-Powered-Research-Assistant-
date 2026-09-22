import 'package:flutter_test/flutter_test.dart';

import 'package:ai_research_assistant/blocs/auth/auth_cubit.dart';
import 'package:ai_research_assistant/blocs/auth/auth_state.dart';
import 'package:ai_research_assistant/blocs/chat/chat_bloc.dart';
import 'package:ai_research_assistant/blocs/chat/chat_event.dart';
import 'package:ai_research_assistant/blocs/chat/chat_state.dart';
import 'package:ai_research_assistant/blocs/documents/document_bloc.dart';
import 'package:ai_research_assistant/blocs/documents/document_event.dart';
import 'package:ai_research_assistant/blocs/documents/document_state.dart';
import 'package:ai_research_assistant/models/enums/document_status.dart';
import 'package:ai_research_assistant/repositories/mock/mock_auth_repository.dart';
import 'package:ai_research_assistant/repositories/mock/mock_chat_repository.dart';
import 'package:ai_research_assistant/repositories/mock/mock_document_repository.dart';

void main() {
  group('AuthCubit Tests', () {
    late MockAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      authRepo = MockAuthRepository(delay: Duration.zero);
      authCubit = AuthCubit(authRepository: authRepo);
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    test('checkAuthStatus emits Authenticated when user exists', () async {
      await authCubit.checkAuthStatus();
      expect(authCubit.state, isA<Authenticated>());
    });

    test('login with valid password emits Authenticated', () async {
      await authCubit.login(email: 'test@example.com', password: 'password123');
      expect(authCubit.state, isA<Authenticated>());
    });

    test('login with short password emits AuthError', () async {
      await authCubit.login(email: 'test@example.com', password: '123');
      expect(authCubit.state, isA<AuthError>());
    });

    test('logout emits Unauthenticated', () async {
      await authCubit.logout();
      expect(authCubit.state, const Unauthenticated());
    });
  });

  group('DocumentBloc Tests', () {
    late MockDocumentRepository docRepo;
    late DocumentBloc docBloc;

    setUp(() {
      docRepo = MockDocumentRepository(delay: Duration.zero);
      docBloc = DocumentBloc(documentRepository: docRepo);
    });

    tearDown(() {
      docBloc.close();
    });

    test('initial state is DocumentInitial', () {
      expect(docBloc.state, const DocumentInitial());
    });

    test('LoadDocuments emits DocumentLoaded with documents', () async {
      docBloc.add(const LoadDocuments());
      await expectLater(
        docBloc.stream,
        emitsInOrder([
          const DocumentLoading(),
          isA<DocumentLoaded>().having((s) => s.documents.isNotEmpty, 'has docs', isTrue),
        ]),
      );
    });

    test('LoadDocuments with status filter filters correctly', () async {
      docBloc.add(const LoadDocuments(statusFilter: DocumentStatus.ready));
      await expectLater(
        docBloc.stream,
        emitsInOrder([
          const DocumentLoading(),
          isA<DocumentLoaded>().having(
            (s) => s.documents.every((d) => d.status == DocumentStatus.ready),
            'all ready',
            isTrue,
          ),
        ]),
      );
    });

    test('UploadDocumentEvent prepends document and sets success message', () async {
      docBloc.add(const LoadDocuments());
      await docBloc.stream.firstWhere((s) => s is DocumentLoaded);

      docBloc.add(const UploadDocumentEvent(
        filePath: '/path/test.pdf',
        fileName: 'test.pdf',
        fileSize: 1024,
      ));

      await expectLater(
        docBloc.stream,
        emitsInOrder([
          isA<DocumentLoaded>().having((s) => s.isUploading, 'isUploading', isTrue),
          isA<DocumentLoaded>().having((s) => s.documents.first.name, 'first doc name', 'test.pdf'),
        ]),
      );
    });
  });

  group('ChatBloc Tests', () {
    late MockChatRepository chatRepo;
    late ChatBloc chatBloc;

    setUp(() {
      chatRepo = MockChatRepository(delay: Duration.zero);
      chatBloc = ChatBloc(chatRepository: chatRepo);
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initial state is ChatInitial', () {
      expect(chatBloc.state, const ChatInitial());
    });

    test('LoadConversations emits ConversationsLoaded', () async {
      chatBloc.add(const LoadConversations());
      await expectLater(
        chatBloc.stream,
        emitsInOrder([
          const ChatLoading(),
          isA<ConversationsLoaded>().having((s) => s.conversations.isNotEmpty, 'has convs', isTrue),
        ]),
      );
    });

    test('LoadMessages emits MessagesLoaded', () async {
      chatBloc.add(const LoadMessages('conv-001'));
      await expectLater(
        chatBloc.stream,
        emitsInOrder([
          const ChatLoading(),
          isA<MessagesLoaded>().having((s) => s.messages.isNotEmpty, 'has messages', isTrue),
        ]),
      );
    });
  });
}
