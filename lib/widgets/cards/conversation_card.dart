/// Card widget representing a chat conversation session.
library;

import 'package:flutter/material.dart';
import '../../config/app_dimensions.dart';
import '../../models/data/conversation_model.dart';
import '../../utils/date_formatter.dart';

class ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timestamp = conversation.updatedAt ?? conversation.createdAt;

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: colorScheme.primary,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Text(
                            DateFormatter.formatRelative(timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.0,
                            ),
                          ),
                        ],
                      ),
                      if (conversation.documentName != null) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                conversation.documentName!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (conversation.lastMessage != null) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          conversation.lastMessage!.content,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: colorScheme.onSurfaceVariant,
                    iconSize: AppDimensions.iconMd,
                    splashRadius: 18,
                    onPressed: onDelete,
                    tooltip: 'Delete conversation',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
