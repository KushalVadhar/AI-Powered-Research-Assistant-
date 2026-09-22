/// Unified loading indicators and shimmer skeleton placeholders.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_dimensions.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.message,
    this.size = 32.0,
    this.color,
  });

  /// Factory for a standalone centered loading indicator with an optional caption.
  const factory AppLoader.spinner({
    Key? key,
    String? message,
    double size,
    Color? color,
  }) = AppLoader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Shimmer skeleton container that matches theme background tones.
  static Widget shimmerBox({
    required BuildContext context,
    required double width,
    required double height,
    double borderRadius = AppDimensions.radiusMd,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Reusable shimmer placeholder for document and conversation cards.
  static Widget cardSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: baseColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
