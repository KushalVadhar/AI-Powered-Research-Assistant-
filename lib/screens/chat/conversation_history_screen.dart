/// Conversation threads history screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../network/api_result.dart';
import '../../repositories/chat_repository.dart';
import '../../widgets/cards/conversation_card.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/dialogs/confirm_dialog.dart';

class ConversationHistoryScreen extends StatelessWidget {
  const ConversationHistoryScreen({super.key});

  Future<void> _startNewConversation(BuildContext context) async {
    final repo = context.read<ChatRepository>();
    final result = await repo.createConversation(
      title: 'New Research Chat',
    );
    if (result case ApiSuccess(:final data)) {
      if (context.mounted) {
        context.read<ChatBloc>().add(const LoadConversations());
        context.push(RouteNames.chatPath(data.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppAppBar(
        title: AppStrings.conversations,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: () => _startNewConversation(context),
            tooltip: AppStrings.newConversation,
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
              itemCount: 4,
              itemBuilder: (context, index) => AppLoader.cardSkeleton(context),
            );
          }

          if (state is ChatError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ChatBloc>().add(const LoadConversations()),
            );
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return AppEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: AppStrings.noConversations,
                subtitle: AppStrings.noConversationsSubtitle,
                buttonText: AppStrings.newConversation,
                buttonIcon: Icons.add_comment_rounded,
                onButtonPressed: () => _startNewConversation(context),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                return ConversationCard(
                  conversation: conv,
                  onTap: () => context.push(RouteNames.chatPath(conv.id)),
                  onDelete: () async {
                    final confirmed = await ConfirmDialog.show(
                      context: context,
                      title: 'Delete Conversation',
                      message: 'Are you sure you want to delete "${conv.title}"?',
                      confirmText: AppStrings.delete,
                      isDestructive: true,
                    );
                    if (confirmed && context.mounted) {
                      context.read<ChatBloc>().add(DeleteConversationEvent(conv.id));
                    }
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
