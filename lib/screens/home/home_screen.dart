/// Home dashboard screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_state.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../models/data/document_model.dart';
import '../../network/api_result.dart';
import '../../repositories/chat_repository.dart';
import '../../widgets/cards/conversation_card.dart';
import '../../widgets/cards/document_card.dart';
import '../../widgets/cards/quick_action_card.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openChatForDocument(
      BuildContext context, DocumentModel doc) async {
    final repo = context.read<ChatRepository>();
    final convsResult = await repo.getConversations();
    if (convsResult case ApiSuccess(:final data)) {
      final existing = data.where((c) => c.documentId == doc.id).firstOrNull;
      if (existing != null) {
        if (context.mounted) {
          context.push(RouteNames.chatPath(existing.id));
        }
        return;
      }
    }
    final newConvResult = await repo.createConversation(
      documentId: doc.id,
      title: 'Discussion: ${doc.name}',
    );
    if (newConvResult case ApiSuccess(:final data)) {
      if (context.mounted) {
        context.read<ChatBloc>().add(const LoadConversations());
        context.push(RouteNames.chatPath(data.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Greeting & Profile ──────────────────────────────
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final userName = state is Authenticated ? state.user.fullName : 'Researcher';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.homeGreeting}, $userName 👋',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            AppStrings.appTagline,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person_rounded,
                            color: colorScheme.primary,
                            size: AppDimensions.iconLg,
                          ),
                        ),
                        onPressed: () => context.push(RouteNames.profile),
                        tooltip: 'Profile',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spacing2Xl),

              // ── Quick Actions Grid ─────────────────────────────────────
              Text(
                AppStrings.quickActions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppDimensions.spacingMd,
                crossAxisSpacing: AppDimensions.spacingMd,
                childAspectRatio: 1.15,
                children: [
                  QuickActionCard(
                    title: AppStrings.uploadDocument,
                    subtitle: 'Upload PDF / DOCX',
                    icon: Icons.upload_file_rounded,
                    accentColor: AppColors.primaryLight,
                    onTap: () => context.push(RouteNames.uploadDocument),
                  ),
                  QuickActionCard(
                    title: AppStrings.askQuestion,
                    subtitle: 'Chat with documents',
                    icon: Icons.chat_bubble_outline_rounded,
                    accentColor: AppColors.secondaryLight,
                    onTap: () => context.push(RouteNames.conversations),
                  ),
                  QuickActionCard(
                    title: AppStrings.summarize,
                    subtitle: 'Generate executive summary',
                    icon: Icons.auto_stories_rounded,
                    accentColor: AppColors.tertiaryLight,
                    onTap: () => context.push(RouteNames.documents),
                  ),
                  QuickActionCard(
                    title: AppStrings.compare,
                    subtitle: 'Contrast 2 research papers',
                    icon: Icons.compare_arrows_rounded,
                    accentColor: AppColors.statusPending,
                    onTap: () => context.push(RouteNames.compareDocuments),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing2Xl),

              // ── Recent Documents ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentDocuments,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.documents),
                    child: Text(
                      AppStrings.viewAll,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              BlocBuilder<DocumentBloc, DocumentState>(
                builder: (context, state) {
                  if (state is DocumentLoading) {
                    return Column(
                      children: List.generate(2, (_) => AppLoader.cardSkeleton(context)),
                    );
                  }

                  if (state is DocumentLoaded) {
                    final recentDocs = state.documents.take(3).toList();
                    if (recentDocs.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.description_outlined,
                        title: AppStrings.noDocuments,
                        subtitle: AppStrings.noDocumentsSubtitle,
                      );
                    }

                    return Column(
                      children: recentDocs.map((doc) {
                        return DocumentCard(
                          document: doc,
                          onTap: () => context.push(RouteNames.documentDetailsPath(doc.id)),
                          onChat: () => _openChatForDocument(context, doc),
                          onSummary: () => context.push(RouteNames.summaryPath(doc.id)),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // ── Recent Conversations ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentConversations,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.conversations),
                    child: Text(
                      AppStrings.viewAll,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return Column(
                      children: List.generate(2, (_) => AppLoader.cardSkeleton(context)),
                    );
                  }

                  if (state is ConversationsLoaded) {
                    final recentConvs = state.conversations.take(2).toList();
                    if (recentConvs.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: AppStrings.noConversations,
                        subtitle: AppStrings.noConversationsSubtitle,
                      );
                    }

                    return Column(
                      children: recentConvs.map((conv) {
                        return ConversationCard(
                          conversation: conv,
                          onTap: () => context.push(RouteNames.chatPath(conv.id)),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.uploadDocument),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload PDF'),
      ),
    );
  }
}
