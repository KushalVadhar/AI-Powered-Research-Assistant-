/// Card widget representing an uploaded document in lists or grids.
library;

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../models/data/document_model.dart';
import '../../models/enums/document_status.dart';
import '../../utils/date_formatter.dart';
import '../../utils/file_utils.dart';
import '../document/document_status_badge.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onChat;
  final VoidCallback? onSummary;
  final VoidCallback? onProcess;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
    this.onChat,
    this.onSummary,
    this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileTypeColor = FileUtils.getFileTypeColor(document.fileType);
    final fileTypeIcon = FileUtils.getFileTypeIcon(document.fileType);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: fileTypeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Icon(
                        fileTypeIcon,
                        color: fileTypeColor,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Text(
                                document.formattedFileSize,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (document.pageCount != null) ...[
                                Text(
                                  ' • ',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  '${document.pageCount} pages',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              Text(
                                ' • ',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                DateFormatter.formatRelative(document.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: AppDimensions.iconMd,
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case 'chat':
                            onChat?.call();
                            break;
                          case 'summary':
                            onSummary?.call();
                            break;
                          case 'process':
                            onProcess?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (document.isReady) ...[
                          const PopupMenuItem(
                            value: 'chat',
                            child: Row(
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                SizedBox(width: AppDimensions.spacingMd),
                                Text('Chat with doc'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'summary',
                            child: Row(
                              children: [
                                Icon(Icons.auto_stories_outlined, size: 18),
                                SizedBox(width: AppDimensions.spacingMd),
                                Text('Summarize'),
                              ],
                            ),
                          ),
                        ],
                        if (document.hasFailed || document.status == DocumentStatus.pending)
                          const PopupMenuItem(
                            value: 'process',
                            child: Row(
                              children: [
                                Icon(Icons.refresh_rounded, size: 18),
                                SizedBox(width: AppDimensions.spacingMd),
                                Text('Process document'),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              SizedBox(width: AppDimensions.spacingMd),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DocumentStatusBadge(
                      status: document.status,
                      isCompact: true,
                    ),
                    if (document.hasSummary)
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Summarized',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
