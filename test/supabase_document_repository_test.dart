import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:ai_research_assistant/models/enums/document_status.dart';
import 'package:ai_research_assistant/network/api_exception.dart';
import 'package:ai_research_assistant/network/api_result.dart';
import 'package:ai_research_assistant/repositories/supabase_document_repository.dart';
import 'package:ai_research_assistant/services/auth_service.dart';
import 'supabase_storage_and_db_test.dart';

/// Test double simulating AuthService.
class FakeDocAuthService extends AuthService {
  supabase.User? mockUser;

  FakeDocAuthService({this.mockUser});

  @override
  supabase.User? get currentUser => mockUser;
}

void main() {
  group('SupabaseDocumentRepository', () {
    late FakeSupabaseDatabaseService dbService;
    late FakeSupabaseStorageService storageService;
    late FakeDocAuthService authService;
    late SupabaseDocumentRepository repository;

    final testUser = const supabase.User(
      id: 'usr_abc_123',
      appMetadata: {},
      userMetadata: {'full_name': 'Dr. Alan Turing'},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    );

    setUp(() {
      dbService = FakeSupabaseDatabaseService();
      storageService = FakeSupabaseStorageService();
      authService = FakeDocAuthService(mockUser: testUser);
      repository = SupabaseDocumentRepository(
        databaseService: dbService,
        storageService: storageService,
        authService: authService,
      );
    });

    test('getDocuments returns UnauthorizedException when user is not authenticated',
        () async {
      authService.mockUser = null;

      final result = await repository.getDocuments();
      expect(result, isA<ApiFailure>());
      final failure = result as ApiFailure;
      expect(failure.exception, isA<UnauthorizedException>());
    });

    test('getDocuments returns documents and applies search & status filtering',
        () async {
      final now = DateTime.now().toUtc().toIso8601String();
      dbService.documents.addAll([
        {
          'id': 'doc_1',
          'user_id': 'usr_abc_123',
          'name': 'Transformer_Advances.pdf',
          'file_url': 'usr_abc_123/transformer.pdf',
          'file_type': 'pdf',
          'file_size': 1200000,
          'page_count': 12,
          'processing_status': 'ready',
          'summary': 'Summary of transformers',
          'metadata': {},
          'created_at': now,
        },
        {
          'id': 'doc_2',
          'user_id': 'usr_abc_123',
          'name': 'Quantum_Algorithms.docx',
          'file_url': 'usr_abc_123/quantum.docx',
          'file_type': 'docx',
          'file_size': 850000,
          'page_count': null,
          'processing_status': 'processing',
          'summary': null,
          'metadata': {},
          'created_at': now,
        },
        {
          'id': 'doc_other',
          'user_id': 'other_user',
          'name': 'Other_Paper.pdf',
          'file_url': 'other_user/paper.pdf',
          'file_type': 'pdf',
          'file_size': 500000,
          'page_count': 5,
          'processing_status': 'ready',
          'summary': null,
          'metadata': {},
          'created_at': now,
        },
      ]);

      // 1. All documents for current user
      final allResult = await repository.getDocuments();
      expect(allResult, isA<ApiSuccess>());
      final allDocs = (allResult as ApiSuccess).data;
      expect(allDocs.length, equals(2));

      // 2. Filter by search query
      final searchResult =
          await repository.getDocuments(searchQuery: 'quantum');
      expect(searchResult, isA<ApiSuccess>());
      final searchDocs = (searchResult as ApiSuccess).data;
      expect(searchDocs.length, equals(1));
      expect(searchDocs.first.name, equals('Quantum_Algorithms.docx'));

      // 3. Filter by status
      final statusResult = await repository.getDocuments(
          statusFilter: DocumentStatus.ready);
      expect(statusResult, isA<ApiSuccess>());
      final statusDocs = (statusResult as ApiSuccess).data;
      expect(statusDocs.length, equals(1));
      expect(statusDocs.first.id, equals('doc_1'));
    });

    test('getDocumentById returns DocumentModel or NotFoundException',
        () async {
      dbService.documents.add({
        'id': 'doc_found',
        'user_id': 'usr_abc_123',
        'name': 'Target.pdf',
        'file_url': 'usr_abc_123/target.pdf',
        'file_type': 'pdf',
        'file_size': 200000,
        'page_count': 4,
        'processing_status': 'ready',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Found
      final found = await repository.getDocumentById('doc_found');
      expect(found, isA<ApiSuccess>());
      expect((found as ApiSuccess).data.name, equals('Target.pdf'));

      // Not found
      final missing = await repository.getDocumentById('non_existent');
      expect(missing, isA<ApiFailure>());
      expect((missing as ApiFailure).exception, isA<NotFoundException>());
    });

    test('uploadDocument uploads bytes to storage and creates database record',
        () async {
      final sampleBytes = Uint8List.fromList([37, 80, 68, 70, 45, 49, 46, 52]); // %PDF-1.4

      final uploadResult = await repository.uploadDocument(
        filePath: '',
        fileName: 'Attention_Research_2026.pdf',
        fileSize: sampleBytes.length,
        fileBytes: sampleBytes,
      );

      expect(uploadResult, isA<ApiSuccess>());
      final doc = (uploadResult as ApiSuccess).data;
      expect(doc.name, equals('Attention_Research_2026.pdf'));
      expect(doc.status, equals(DocumentStatus.pending));
      expect(doc.userId, equals('usr_abc_123'));
      expect(doc.fileSize, equals(sampleBytes.length));

      // Verify file is stored in storage
      expect(storageService.storedFiles.containsKey(doc.fileUrl), isTrue);

      // Verify row exists in DB
      expect(dbService.documents.any((d) => d['id'] == doc.id), isTrue);
    });

    test('uploadDocument fails with ValidationException when bytes are missing',
        () async {
      final result = await repository.uploadDocument(
        filePath: '',
        fileName: 'empty.pdf',
      );

      expect(result, isA<ApiFailure>());
      expect((result as ApiFailure).exception, isA<ValidationException>());
    });

    test('processDocument updates status to processing and ready', () async {
      final newDoc = await repository.uploadDocument(
        filePath: '',
        fileName: 'Inference_Optimizations.pdf',
        fileBytes: Uint8List.fromList([1, 2, 3]),
      );
      final docId = (newDoc as ApiSuccess).data.id;

      final processResult = await repository.processDocument(docId);
      expect(processResult, isA<ApiSuccess>());
      final processedDoc = (processResult as ApiSuccess).data;
      expect(processedDoc.status, equals(DocumentStatus.ready));
      expect(processedDoc.pageCount, equals(10));
    });

    test('generateSummary creates and persists executive summary', () async {
      final newDoc = await repository.uploadDocument(
        filePath: '',
        fileName: 'RAG_Architecture.pdf',
        fileBytes: Uint8List.fromList([1, 2, 3]),
      );
      final docId = (newDoc as ApiSuccess).data.id;

      // First generation creates summary
      final summaryResult = await repository.generateSummary(docId);
      expect(summaryResult, isA<ApiSuccess>());
      final summaryText = (summaryResult as ApiSuccess).data;
      expect(summaryText, contains('Executive Summary'));

      // Second call returns cached summary
      final cachedResult = await repository.generateSummary(docId);
      expect(cachedResult, isA<ApiSuccess>());
      expect((cachedResult as ApiSuccess).data, equals(summaryText));
    });

    test('compareDocuments returns comparison synthesis data', () async {
      final doc1 = await repository.uploadDocument(
        filePath: '',
        fileName: 'Paper_A.pdf',
        fileBytes: Uint8List.fromList([1]),
      );
      final doc2 = await repository.uploadDocument(
        filePath: '',
        fileName: 'Paper_B.pdf',
        fileBytes: Uint8List.fromList([2]),
      );

      final doc1Id = (doc1 as ApiSuccess).data.id;
      final doc2Id = (doc2 as ApiSuccess).data.id;

      final compareResult = await repository.compareDocuments(
        docId1: doc1Id,
        docId2: doc2Id,
      );

      expect(compareResult, isA<ApiSuccess>());
      final comparison = (compareResult as ApiSuccess).data;
      expect(comparison['document1'], equals('Paper_A.pdf'));
      expect(comparison['document2'], equals('Paper_B.pdf'));
      expect(comparison['similarities'], isNotEmpty);
      expect(comparison['differences'], isNotEmpty);
      expect(comparison['synthesis'], isNotEmpty);
    });

    test('deleteDocument deletes file from storage and removes database row',
        () async {
      final doc = await repository.uploadDocument(
        filePath: '',
        fileName: 'Delete_Target.pdf',
        fileBytes: Uint8List.fromList([99]),
      );
      final docData = (doc as ApiSuccess).data;

      expect(storageService.storedFiles.containsKey(docData.fileUrl), isTrue);
      expect(dbService.documents.any((d) => d['id'] == docData.id), isTrue);

      final deleteResult = await repository.deleteDocument(docData.id);
      expect(deleteResult, isA<ApiSuccess>());

      expect(storageService.storedFiles.containsKey(docData.fileUrl), isFalse);
      expect(dbService.documents.any((d) => d['id'] == docData.id), isFalse);
    });
  });
}
