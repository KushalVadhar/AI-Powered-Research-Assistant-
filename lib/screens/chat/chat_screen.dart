/// Interactive RAG chat conversation screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../repositories/mock/mock_data.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/streaming_indicator.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_loader.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.conversationId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendMessage(String text) {
    context.read<ChatBloc>().add(
          SendMessageEvent(
            conversationId: widget.conversationId,
            content: text,
          ),
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppAppBar(
        title: 'Research Chat',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Answers are grounded in your uploaded documents.')),
              );
            },
            tooltip: 'RAG Info',
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is MessagesLoaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: AppLoader(message: 'Loading conversation...'));
          }

          if (state is MessagesLoaded) {
            final messages = state.messages;
            final isSending = state.isSending;

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyPromptSuggestions()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingMd,
                          ),
                          itemCount: messages.length + (isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < messages.length) {
                              return ChatMessageBubble(
                                message: messages[index],
                                onCitationTap: (citation) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Viewing citation on Page ${citation.pageNumber}'),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const StreamingIndicator();
                            }
                          },
                        ),
                ),
                ChatInputField(
                  isLoading: isSending,
                  onSend: _onSendMessage,
                ),
              ],
            );
          }

          if (state is ChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 48),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppDimensions.spacingLg),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ChatBloc>()
                          .add(LoadMessages(widget.conversationId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyPromptSuggestions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              AppStrings.suggestedQuestions,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            ...MockData.suggestedQuestions.take(3).map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      onPressed: () => _onSendMessage(question),
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
