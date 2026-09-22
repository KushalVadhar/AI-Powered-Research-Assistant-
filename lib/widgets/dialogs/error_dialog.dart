/// Modal error presentation dialog for unrecoverable or critical errors.
library;

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../common/app_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
  });

  /// Displays the error dialog modally.
  static Future<void> show({
    required BuildContext context,
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: AppDimensions.iconXl,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
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
            const SizedBox(height: AppDimensions.spacingXxl),
            Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    text: AppStrings.cancel,
                    size: AppButtonSize.medium,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: AppButton.primary(
                      text: AppStrings.retry,
                      size: AppButtonSize.medium,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry!();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
