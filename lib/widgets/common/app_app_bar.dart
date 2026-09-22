/// Standardized top application bar component.
library;

import 'package:flutter/material.dart';
import '../../config/app_dimensions.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBottomBorder;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
    this.showBottomBorder = false,
  }) : assert(
          title != null || titleWidget != null || leading != null,
          'At least title, titleWidget, or leading must be provided',
        );

  @override
  Size get preferredSize => Size.fromHeight(
        AppDimensions.appBarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        iconSize: AppDimensions.iconMd,
        color: colorScheme.onSurface,
        tooltip: 'Back',
        onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
      );
    }

    final Widget? actualTitle = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              )
            : null);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: AppBar(
        title: actualTitle,
        leading: leadingWidget,
        actions: actions != null
            ? [
                ...actions!,
                const SizedBox(width: AppDimensions.spacingSm),
              ]
            : null,
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: bottom,
      ),
    );
  }
}
