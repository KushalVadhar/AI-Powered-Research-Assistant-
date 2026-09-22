/// Document state definitions for DocumentBloc.
library;

import 'package:equatable/equatable.dart';
import '../../models/data/document_model.dart';
import '../../models/enums/document_status.dart';

sealed class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

/// Initial list loading state (shows shimmer skeletons).
class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

/// Documents successfully loaded with active filters.
class DocumentLoaded extends DocumentState {
  final List<DocumentModel> documents;
  final String? searchQuery;
  final DocumentStatus? activeFilter;
  final bool isUploading;
  final bool isSummarizing;
  final String? activeSummary;
  final String? actionSuccessMessage;

  const DocumentLoaded({
    required this.documents,
    this.searchQuery,
    this.activeFilter,
    this.isUploading = false,
    this.isSummarizing = false,
    this.activeSummary,
    this.actionSuccessMessage,
  });

  DocumentLoaded copyWith({
    List<DocumentModel>? documents,
    String? searchQuery,
    DocumentStatus? activeFilter,
    bool clearActiveFilter = false,
    bool? isUploading,
    bool? isSummarizing,
    String? activeSummary,
    String? actionSuccessMessage,
  }) {
    return DocumentLoaded(
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: clearActiveFilter ? null : (activeFilter ?? this.activeFilter),
      isUploading: isUploading ?? this.isUploading,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      activeSummary: activeSummary ?? this.activeSummary,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        documents,
        searchQuery,
        activeFilter,
        isUploading,
        isSummarizing,
        activeSummary,
        actionSuccessMessage,
      ];
}

/// An unrecoverable error occurred.
class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
