/// Documents library screen with search, filter tabs, and CRUD actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_event.dart';
import '../../blocs/documents/document_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../models/data/document_model.dart';
import '../../models/enums/document_status.dart';
import '../../network/api_result.dart';
import '../../repositories/chat_repository.dart';
import '../../widgets/cards/document_card.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/dialogs/confirm_dialog.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DocumentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(const LoadDocuments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<DocumentBloc>().add(LoadDocuments(
          searchQuery: query,
          statusFilter: _selectedStatus,
        ));
  }

  void _onStatusFilterSelected(DocumentStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<DocumentBloc>().add(LoadDocuments(
          searchQuery: _searchController.text,
          statusFilter: status,
        ));
  }

  Future<void> _confirmDelete(String docId, String docName) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: AppStrings.deleteDocument,
      message: 'Are you sure you want to delete "$docName"? This cannot be undone.',
      confirmText: AppStrings.delete,
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed && mounted) {
      context.read<DocumentBloc>().add(DeleteDocumentEvent(docId));
    }
  }

  Future<void> _openChatForDocument(DocumentModel doc) async {
    final repo = context.read<ChatRepository>();
    final convsResult = await repo.getConversations();
    if (convsResult case ApiSuccess(:final data)) {
      final existing = data.where((c) => c.documentId == doc.id).firstOrNull;
      if (existing != null) {
        if (mounted) {
          context.push(RouteNames.chatPath(existing.id));
        }
        return;
      }
    }
    final newConvResult = await repo.createConversation(
      documentId: doc.id,
      title: 'Discussion: ${doc.name}',
    );
    if (newConvResult case ApiSuccess(:final data)) {
      if (mounted) {
        context.read<ChatBloc>().add(const LoadConversations());
        context.push(RouteNames.chatPath(data.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppAppBar(
        title: AppStrings.documents,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RouteNames.uploadDocument),
            tooltip: AppStrings.uploadDocument,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Input ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacingSm,
            ),
            child: AppTextField(
              controller: _searchController,
              hint: AppStrings.searchDocuments,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              onChanged: _onSearchChanged,
            ),
          ),

          // ── Status Filter Chips ───────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedStatus == null, () => _onStatusFilterSelected(null)),
                const SizedBox(width: AppDimensions.spacingSm),
                ...DocumentStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
                    child: _buildFilterChip(
                      status.label,
                      _selectedStatus == status,
                      () => _onStatusFilterSelected(status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Documents List View ───────────────────────────────────
          Expanded(
            child: BlocBuilder<DocumentBloc, DocumentState>(
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                    itemCount: 4,
                    itemBuilder: (context, index) => AppLoader.cardSkeleton(context),
                  );
                }

                if (state is DocumentError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DocumentBloc>().add(const LoadDocuments()),
                  );
                }

                if (state is DocumentLoaded) {
                  if (state.documents.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: AppStrings.noDocuments,
                      subtitle: _searchController.text.isNotEmpty
                          ? 'No documents matched your query.'
                          : AppStrings.noDocumentsSubtitle,
                      buttonText: AppStrings.uploadYourFirst,
                      buttonIcon: Icons.upload_file_rounded,
                      onButtonPressed: () => context.push(RouteNames.uploadDocument),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DocumentBloc>().add(LoadDocuments(
                            searchQuery: _searchController.text,
                            statusFilter: _selectedStatus,
                          ));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingH,
                        vertical: AppDimensions.spacingSm,
                      ),
                      itemCount: state.documents.length,
                      itemBuilder: (context, index) {
                        final doc = state.documents[index];
                        return DocumentCard(
                          document: doc,
                          onTap: () => context.push(RouteNames.documentDetailsPath(doc.id)),
                          onChat: () => _openChatForDocument(doc),
                          onSummary: () => context.push(RouteNames.summaryPath(doc.id)),
                          onProcess: () => context.read<DocumentBloc>().add(ProcessDocumentEvent(doc.id)),
                          onDelete: () => _confirmDelete(doc.id, doc.name),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}
