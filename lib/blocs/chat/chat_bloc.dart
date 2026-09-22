/// Chat state management BLoC.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/data/chat_message_model.dart';
import '../../models/enums/message_role.dart';
import '../../network/api_result.dart';
import '../../repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(const ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<CreateConversationEvent>(_onCreateConversation);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteConversationEvent>(_onDeleteConversation);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await chatRepository.getConversations();

    switch (result) {
      case ApiSuccess(:final data):
        emit(ConversationsLoaded(data));
      case ApiFailure(:final exception):
        emit(ChatError(exception.message));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Fetch conversation details and messages in parallel
    final convResult = await chatRepository.getConversationById(event.conversationId);
    final messagesResult = await chatRepository.getMessages(event.conversationId);

    if (messagesResult case ApiSuccess(:final data)) {
      emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: data,
        conversation: convResult is ApiSuccess ? (convResult as ApiSuccess).data : null,
      ));
    } else if (messagesResult case ApiFailure(:final exception)) {
      emit(ChatError(exception.message));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await chatRepository.createConversation(
      title: event.title,
      documentId: event.documentId,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(MessagesLoaded(
          conversationId: data.id,
          messages: const [],
          conversation: data,
        ));
      case ApiFailure(:final exception):
        emit(ChatError(exception.message));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessagesLoaded) return;

    // 1. Optimistically display user message
    final optimisticUserMsg = ChatMessageModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: event.conversationId,
      role: MessageRole.user,
      content: event.content,
      createdAt: DateTime.now(),
    );

    final optimisticList = [...currentState.messages, optimisticUserMsg];
    emit(currentState.copyWith(
      messages: optimisticList,
      isSending: true,
    ));

    // 2. Call repository
    final result = await chatRepository.sendMessage(
      conversationId: event.conversationId,
      content: event.content,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(currentState.copyWith(
          messages: [...optimisticList, data],
          isSending: false,
        ));
      case ApiFailure(:final exception):
        emit(currentState.copyWith(isSending: false));
        emit(ChatError(exception.message));
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.deleteConversation(event.conversationId);
    add(const LoadConversations());
  }
}
