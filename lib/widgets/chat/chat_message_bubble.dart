/// Chat message bubble supporting user & assistant roles, citations, and clipboard copy.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../models/data/chat_message_model.dart';
import '../../models/data/citation_model.dart';
import '../../utils/date_formatter.dart';
import 'source_citation_card.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final ValueChanged<CitationModel>? onCitationTap;
  final VoidCallback? onRegenerate;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onCitationTap,
    this.onRegenerate,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _showCitations = true;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.copied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = widget.message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * AppDimensions.chatBubbleMaxWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: AppDimensions.spacingSm, top: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingLg,
                    vertical: AppDimensions.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? colorScheme.primary
                        : (theme.brightness == Brightness.light
                            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusLg),
                      topRight: Radius.circular(AppDimensions.radiusLg),
                      bottomLeft: Radius.circular(isUser ? AppDimensions.radiusLg : AppDimensions.radiusXs),
                      bottomRight: Radius.circular(isUser ? AppDimensions.radiusXs : AppDimensions.radiusLg),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        widget.message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormatter.formatTime(widget.message.createdAt),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isUser
                                  ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          InkWell(
                            onTap: () => _copyToClipboard(context),
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 12.0,
                                color: isUser
                                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          if (!isUser && widget.onRegenerate != null) ...[
                            const SizedBox(width: AppDimensions.spacingSm),
                            InkWell(
                              onTap: widget.onRegenerate,
                              borderRadius: BorderRadius.circular(4.0),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  size: 12.0,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isUser && widget.message.hasCitations) ...[
            Container(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              margin: const EdgeInsets.only(
                left: 36.0,
                top: AppDimensions.spacingSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showCitations = !_showCitations;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.message.citations.length} Sources',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            _showCitations
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showCitations)
                    ...widget.message.citations.asMap().entries.map(
                          (entry) => SourceCitationCard(
                            index: entry.key + 1,
                            citation: entry.value,
                            onTap: widget.onCitationTap != null
                                ? () => widget.onCitationTap!(entry.value)
                                : null,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
