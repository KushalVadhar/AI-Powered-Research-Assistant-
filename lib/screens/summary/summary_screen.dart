/// AI Document summary presentation screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_event.dart';
import '../../blocs/documents/document_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../models/data/document_model.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_loader.dart';

class SummaryScreen extends StatefulWidget {
  final String documentId;

  const SummaryScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger summary generation if not already present
    context.read<DocumentBloc>().add(GenerateSummaryEvent(widget.documentId));
  }

  void _copySummary(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.copied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppAppBar(
        title: AppStrings.documentSummary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<DocumentBloc>().add(
                  GenerateSummaryEvent(widget.documentId),
                ),
            tooltip: AppStrings.regenerate,
          ),
        ],
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentLoaded) {
            final isSummarizing = state.isSummarizing;
            final document = state.documents.cast<DocumentModel?>().firstWhere(
                  (d) => d?.id == widget.documentId,
                  orElse: () => null,
                );

            final summaryText = state.activeSummary ?? document?.summary;

            if (isSummarizing) {
              return const Center(
                child: AppLoader(
                  message: AppStrings.generating,
                ),
              );
            }

            if (summaryText != null && summaryText.isNotEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH,
                  vertical: AppDimensions.screenPaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (document != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Text(
                              document.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingLg),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: SelectableText(
                        summaryText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing2Xl),
                    AppButton.outline(
                      text: AppStrings.copy,
                      leadingIcon: Icons.copy_rounded,
                      onPressed: () => _copySummary(summaryText),
                    ),
                  ],
                ),
              );
            }
          }

          if (state is DocumentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 48),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppDimensions.spacingLg),
                    ElevatedButton(
                      onPressed: () => context
                          .read<DocumentBloc>()
                          .add(GenerateSummaryEvent(widget.documentId)),
                      child: const Text('Retry Generation'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: AppButton.primary(
              text: 'Generate Summary',
              leadingIcon: Icons.auto_stories_rounded,
              isFullWidth: false,
              onPressed: () => context.read<DocumentBloc>().add(
                    GenerateSummaryEvent(widget.documentId),
                  ),
            ),
          );
        },
      ),
    );
  }
}
