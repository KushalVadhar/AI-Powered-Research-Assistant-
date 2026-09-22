/// Reusable, multi-variant button widget.
library;

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.danger;

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSm;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMd;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLg;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 13.0;
      case AppButtonSize.medium:
        return 14.0;
      case AppButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.iconSm;
      case AppButtonSize.medium:
        return AppDimensions.iconMd;
      case AppButtonSize.large:
        return AppDimensions.iconLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isEnabled ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.5);
        foregroundColor = colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isEnabled ? colorScheme.secondaryContainer : colorScheme.secondaryContainer.withValues(alpha: 0.5);
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.38);
        borderSide = BorderSide(
          color: isEnabled ? colorScheme.outline : colorScheme.outline.withValues(alpha: 0.38),
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.38);
        break;
      case AppButtonVariant.danger:
        backgroundColor = isEnabled ? AppColors.error : AppColors.error.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else {
      final textWidget = Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          color: foregroundColor,
          letterSpacing: 0.2,
        ),
      );

      if (leadingIcon == null && trailingIcon == null) {
        content = textWidget;
      } else {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: _getIconSize(), color: foregroundColor),
              const SizedBox(width: AppDimensions.spacingSm),
            ],
            textWidget,
            if (trailingIcon != null) ...[
              const SizedBox(width: AppDimensions.spacingSm),
              Icon(trailingIcon, size: _getIconSize(), color: foregroundColor),
            ],
          ],
        );
      }
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: size == AppButtonSize.small ? AppDimensions.spacingMd : AppDimensions.spacingLg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: borderSide ?? BorderSide.none,
      ),
    );

    Widget button = SizedBox(
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: content,
      ),
    );

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
