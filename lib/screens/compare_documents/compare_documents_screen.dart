/// Multi-document comparative analysis screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_state.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../models/data/document_model.dart';
import '../../network/api_result.dart';
import '../../repositories/document_repository.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_loader.dart';

class CompareDocumentsScreen extends StatefulWidget {
  const CompareDocumentsScreen({super.key});

  @override
  State<CompareDocumentsScreen> createState() => _CompareDocumentsScreenState();
}

class _CompareDocumentsScreenState extends State<CompareDocumentsScreen> {
  String? _selectedDocId1;
  String? _selectedDocId2;
  bool _isComparing = false;
  Map<String, dynamic>? _comparisonResult;

  Future<void> _runComparison(DocumentRepository repo) async {
    if (_selectedDocId1 == null || _selectedDocId2 == null) return;
    setState(() => _isComparing = true);

    final result = await repo.compareDocuments(
      docId1: _selectedDocId1!,
      docId2: _selectedDocId2!,
    );

    if (mounted) {
      setState(() {
        _isComparing = false;
        if (result case ApiSuccess(:final data)) {
          _comparisonResult = data;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppAppBar(title: AppStrings.compareDocuments),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final documents = state is DocumentLoaded ? state.documents : <DocumentModel>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.selectDocuments,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // ── Document 1 Selector ────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _selectedDocId1 ?? (documents.isNotEmpty ? documents[0].id : null),
                  decoration: InputDecoration(
                    labelText: 'First Document',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                  items: documents.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        doc.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDocId1 = val),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // ── Document 2 Selector ────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _selectedDocId2 ?? (documents.length > 1 ? documents[1].id : null),
                  decoration: InputDecoration(
                    labelText: 'Second Document',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                  items: documents.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        doc.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDocId2 = val),
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                AppButton.primary(
                  text: AppStrings.startComparison,
                  leadingIcon: Icons.compare_arrows_rounded,
                  isLoading: _isComparing,
                  onPressed: () {
                    final repo = context.read<DocumentRepository>();
                    _runComparison(repo);
                  },
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Comparison Results ─────────────────────────────────────
                if (_isComparing) ...[
                  const Center(child: AppLoader(message: 'Analyzing similarities & contrasts...')),
                ] else if (_comparisonResult != null) ...[
                  _buildSection(
                    title: AppStrings.similarities,
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.success,
                    items: (_comparisonResult!['similarities'] as List<dynamic>).cast<String>(),
                    context: context,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _buildSection(
                    title: AppStrings.differences,
                    icon: Icons.difference_outlined,
                    iconColor: AppColors.statusPending,
                    items: (_comparisonResult!['differences'] as List<dynamic>).cast<String>(),
                    context: context,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Synthesis',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          _comparisonResult!['synthesis'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
