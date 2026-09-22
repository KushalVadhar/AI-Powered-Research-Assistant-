/// Detailed view for a single research document.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_event.dart';
import '../../blocs/documents/document_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../models/data/document_model.dart';
import '../../models/enums/document_status.dart';
import '../../network/api_result.dart';
import '../../repositories/chat_repository.dart';
import '../../utils/date_formatter.dart';
import '../../utils/file_utils.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/document/document_status_badge.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final String documentId;

  const DocumentDetailsScreen({
    super.key,
    required this.documentId,
  });

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

    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        DocumentModel? document;
        if (state is DocumentLoaded) {
          document = state.documents.cast<DocumentModel?>().firstWhere(
                (d) => d?.id == documentId,
                orElse: () => null,
              );
        }

        if (document == null) {
          return Scaffold(
            appBar: const AppAppBar(title: AppStrings.documentDetails),
            body: Center(
              child: Text(
                'Document not found',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }

        final fileTypeColor = FileUtils.getFileTypeColor(document.fileType);
        final fileTypeIcon = FileUtils.getFileTypeIcon(document.fileType);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppAppBar(
            title: AppStrings.documentDetails,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: AppStrings.deleteDocument,
                    message: 'Delete "${document!.name}" permanently?',
                    confirmText: AppStrings.delete,
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    context.read<DocumentBloc>().add(DeleteDocumentEvent(document.id));
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero File Type & Name ──────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: fileTypeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: Icon(
                        fileTypeIcon,
                        size: 32,
                        color: fileTypeColor,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingLg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          DocumentStatusBadge(status: document.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Metadata Grid ──────────────────────────────────────────
                Text(
                  'Metadata',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMetaRow('File Size', document.formattedFileSize, context),
                      const Divider(height: AppDimensions.spacingXl),
                      _buildMetaRow('Page Count', '${document.pageCount ?? "Unknown"} pages', context),
                      const Divider(height: AppDimensions.spacingXl),
                      _buildMetaRow('Uploaded', DateFormatter.formatDateTime(document.createdAt), context),
                      const Divider(height: AppDimensions.spacingXl),
                      _buildMetaRow('File Format', document.fileType.label, context),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Action Buttons ─────────────────────────────────────────
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                if (document.isReady) ...[
                  AppButton.primary(
                    text: 'Chat with this Document',
                    leadingIcon: Icons.chat_bubble_outline_rounded,
                    onPressed: () => _openChatForDocument(context, document!),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  AppButton.secondary(
                    text: 'View AI Summary',
                    leadingIcon: Icons.auto_stories_rounded,
                    onPressed: () => context.push(RouteNames.summaryPath(document!.id)),
                  ),
                ] else if (document.status == DocumentStatus.failed ||
                    document.status == DocumentStatus.pending) ...[
                  AppButton.primary(
                    text: AppStrings.processDocument,
                    leadingIcon: Icons.refresh_rounded,
                    onPressed: () =>
                        context.read<DocumentBloc>().add(ProcessDocumentEvent(document!.id)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
