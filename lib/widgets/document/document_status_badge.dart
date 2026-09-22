/// Visual status badge widget for document processing states.
library;

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../models/enums/document_status.dart';

class DocumentStatusBadge extends StatelessWidget {
  final DocumentStatus status;
  final bool isCompact;

  const DocumentStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  Color _getStatusColor() {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.statusPending;
      case DocumentStatus.processing:
        return AppColors.statusProcessing;
      case DocumentStatus.ready:
        return AppColors.statusReady;
      case DocumentStatus.failed:
        return AppColors.statusFailed;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case DocumentStatus.pending:
        return Icons.schedule_rounded;
      case DocumentStatus.processing:
        return Icons.sync_rounded;
      case DocumentStatus.ready:
        return Icons.check_circle_outline_rounded;
      case DocumentStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);

    final fontSize = isCompact ? 11.0 : 12.0;
    final iconSize = isCompact ? 12.0 : 14.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: 4.0),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
