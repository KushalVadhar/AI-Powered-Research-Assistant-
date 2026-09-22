/// Document state management BLoC.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_strings.dart';
import '../../models/data/document_model.dart';
import '../../network/api_result.dart';
import '../../repositories/document_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository documentRepository;

  DocumentBloc({required this.documentRepository})
      : super(const DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<ProcessDocumentEvent>(_onProcessDocument);
    on<GenerateSummaryEvent>(_onGenerateSummary);
    on<DeleteDocumentEvent>(_onDeleteDocument);
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DocumentLoaded) {
      emit(const DocumentLoading());
    }

    final result = await documentRepository.getDocuments(
      searchQuery: event.searchQuery,
      statusFilter: event.statusFilter,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(DocumentLoaded(
          documents: data,
          searchQuery: event.searchQuery,
          activeFilter: event.statusFilter,
        ));
      case ApiFailure(:final exception):
        emit(DocumentError(exception.message));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentLoaded) {
      emit(currentState.copyWith(isUploading: true));
    }

    final result = await documentRepository.uploadDocument(
      filePath: event.filePath,
      fileName: event.fileName,
      fileSize: event.fileSize,
      fileBytes: event.fileBytes,
    );

    switch (result) {
      case ApiSuccess(:final data):
        if (currentState is DocumentLoaded) {
          final updatedDocs = [data, ...currentState.documents];
          emit(currentState.copyWith(
            documents: updatedDocs,
            isUploading: false,
            actionSuccessMessage: AppStrings.documentUploaded,
          ));
        } else {
          emit(DocumentLoaded(
            documents: [data],
            actionSuccessMessage: AppStrings.documentUploaded,
          ));
        }
      case ApiFailure(:final exception):
        if (currentState is DocumentLoaded) {
          emit(currentState.copyWith(isUploading: false));
        }
        emit(DocumentError(exception.message));
    }
  }

  Future<void> _onProcessDocument(
    ProcessDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    final result = await documentRepository.processDocument(event.documentId);

    if (result case ApiSuccess(:final data)) {
      if (state is DocumentLoaded) {
        final current = state as DocumentLoaded;
        final index = current.documents.indexWhere((d) => d.id == data.id);
        if (index != -1) {
          final updated = List<DocumentModel>.from(current.documents);
          updated[index] = data;
          emit(current.copyWith(documents: updated));
        }
      }
    }
  }

  Future<void> _onGenerateSummary(
    GenerateSummaryEvent event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentLoaded) {
      emit(currentState.copyWith(isSummarizing: true));
    }

    final result = await documentRepository.generateSummary(event.documentId);

    switch (result) {
      case ApiSuccess(:final data):
        if (state is DocumentLoaded) {
          emit((state as DocumentLoaded).copyWith(
            isSummarizing: false,
            activeSummary: data,
          ));
        }
      case ApiFailure(:final exception):
        if (state is DocumentLoaded) {
          emit((state as DocumentLoaded).copyWith(isSummarizing: false));
        }
        emit(DocumentError(exception.message));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    final result = await documentRepository.deleteDocument(event.documentId);

    switch (result) {
      case ApiSuccess():
        if (state is DocumentLoaded) {
          final current = state as DocumentLoaded;
          final updated = current.documents.where((d) => d.id != event.documentId).toList();
          emit(current.copyWith(
            documents: updated,
            actionSuccessMessage: AppStrings.documentDeleted,
          ));
        }
      case ApiFailure(:final exception):
        emit(DocumentError(exception.message));
    }
  }
}
