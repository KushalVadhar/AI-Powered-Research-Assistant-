/// Source citation card displaying retrieved document chunks and page references.
library;

import 'package:flutter/material.dart';
import '../../config/app_dimensions.dart';
import '../../models/data/citation_model.dart';

class SourceCitationCard extends StatelessWidget {
  final CitationModel citation;
  final int? index;
  final VoidCallback? onTap;

  const SourceCitationCard({
    super.key,
    required this.citation,
    this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusMd),
                      bottomLeft: Radius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (index != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                '[$index]',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                          ],
                          Flexible(
                            child: Text(
                              citation.documentName,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        'Page ${citation.pageNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  '"${citation.contentPreview}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
),
);
  }
}
