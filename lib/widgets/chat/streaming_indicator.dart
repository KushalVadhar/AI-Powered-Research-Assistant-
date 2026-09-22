/// Animated indicator displaying an AI generating/thinking state.
library;

import 'package:flutter/material.dart';
import '../../config/app_dimensions.dart';

class StreamingIndicator extends StatefulWidget {
  final String label;

  const StreamingIndicator({
    super.key,
    this.label = 'AI is thinking...',
  });

  @override
  State<StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final progress = (_controller.value - delay).clamp(0.0, 1.0);
        final opacity = (0.3 + 0.7 * (1.0 - (progress * 2 - 1.0).abs())).clamp(0.2, 1.0);
        final scale = 0.8 + 0.4 * (1.0 - (progress * 2 - 1.0).abs());

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 7.0,
              height: 7.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppDimensions.spacingLg,
          bottom: AppDimensions.spacingMd,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusLg),
            topRight: Radius.circular(AppDimensions.radiusLg),
            bottomRight: Radius.circular(AppDimensions.radiusLg),
            bottomLeft: Radius.circular(AppDimensions.radiusXs),
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16.0,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              widget.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => _buildDot(index, colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
