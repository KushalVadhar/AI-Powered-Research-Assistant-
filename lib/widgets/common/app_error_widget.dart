/// Error display widget with retry callback support.
library;

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconXxl,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title ?? 'An Error Occurred',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXxl),
              AppButton(
                text: AppStrings.retry,
                leadingIcon: Icons.refresh_rounded,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                isFullWidth: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
