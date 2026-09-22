import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_research_assistant/models/data/chat_message_model.dart';
import 'package:ai_research_assistant/models/data/conversation_model.dart';
import 'package:ai_research_assistant/models/data/document_model.dart';
import 'package:ai_research_assistant/models/enums/document_status.dart';
import 'package:ai_research_assistant/models/enums/file_type.dart';
import 'package:ai_research_assistant/models/enums/message_role.dart';
import 'package:ai_research_assistant/services/supabase_database_service.dart';
import 'package:ai_research_assistant/services/supabase_storage_service.dart';

/// Test double simulating Supabase Storage in memory.
class FakeSupabaseStorageService extends SupabaseStorageService {
  final Map<String, Uint8List> storedFiles = {};
  bool shouldFail = false;
  String? failMessage;

  @override
  Future<String> uploadBytes({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    if (shouldFail) {
      throw Exception(failMessage ?? 'Upload failed');
    }
    final sanitizedFileName =
        fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';
    storedFiles[storagePath] = bytes;
    return storagePath;
  }

  @override
  Future<String> getSignedUrl({
    required String storagePath,
    int expiresInSeconds = 3600,
  }) async {
    if (shouldFail) {
      throw Exception(failMessage ?? 'Failed to get signed URL');
    }
    if (!storedFiles.containsKey(storagePath)) {
      throw Exception('Object not found');
    }
    return 'https://mock.supabase.co/storage/v1/object/sign/documents/$storagePath?token=mock_jwt_exp_$expiresInSeconds';
  }

  @override
  Future<void> deleteFile({required String storagePath}) async {
    if (shouldFail) {
      throw Exception(failMessage ?? 'Failed to delete file');
    }
    storedFiles.remove(storagePath);
  }

  @override
  Future<Uint8List> downloadFile({required String storagePath}) async {
    if (shouldFail) {
      throw Exception(failMessage ?? 'Download failed');
    }
    final bytes = storedFiles[storagePath];
    if (bytes == null) {
      throw Exception('File not found: $storagePath');
    }
    return bytes;
  }
}

/// Test double simulating Supabase Database & pgvector in memory.
class FakeSupabaseDatabaseService extends SupabaseDatabaseService {
  final List<Map<String, dynamic>> documents = [];
  final List<Map<String, dynamic>> conversations = [];
  final List<Map<String, dynamic>> messages = [];
  final List<Map<String, dynamic>> chunks = [];
  bool shouldFail = false;
  String? failMessage;

  @override
  Future<List<Map<String, dynamic>>> getDocuments({String? userId}) async {
    if (shouldFail) throw Exception(failMessage ?? 'Query failed');
    var result = List<Map<String, dynamic>>.from(documents);
    if (userId != null) {
      result = result.where((d) => d['user_id'] == userId).toList();
    }
    result.sort((a, b) =>
        (b['created_at'] as String).compareTo(a['created_at'] as String));
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getDocumentById(String id) async {
    if (shouldFail) throw Exception(failMessage ?? 'Query failed');
    try {
      return documents.firstWhere((d) => d['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> insertDocument(
      Map<String, dynamic> documentData) async {
    if (shouldFail) throw Exception(failMessage ?? 'Insert failed');
    final row = Map<String, dynamic>.from(documentData);
    row['id'] ??=
        'doc_${DateTime.now().microsecondsSinceEpoch}_${documents.length}';
    row['created_at'] ??= DateTime.now().toUtc().toIso8601String();
    documents.add(row);
    return row;
  }

  @override
  Future<Map<String, dynamic>> updateDocument(
    String id,
    Map<String, dynamic> updates,
  ) async {
    if (shouldFail) throw Exception(failMessage ?? 'Update failed');
    final idx = documents.indexWhere((d) => d['id'] == id);
    if (idx == -1) throw Exception('Document not found');
    documents[idx].addAll(updates);
    documents[idx]['updated_at'] = DateTime.now().toUtc().toIso8601String();
    return Map<String, dynamic>.from(documents[idx]);
  }

  @override
  Future<void> deleteDocument(String id) async {
    if (shouldFail) throw Exception(failMessage ?? 'Delete failed');
    documents.removeWhere((d) => d['id'] == id);
    chunks.removeWhere((c) => c['document_id'] == id);
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations({String? userId}) async {
    if (shouldFail) throw Exception(failMessage ?? 'Query failed');
    var result = List<Map<String, dynamic>>.from(conversations);
    if (userId != null) {
      result = result.where((c) => c['user_id'] == userId).toList();
    }
    result.sort((a, b) =>
        (b['updated_at'] as String).compareTo(a['updated_at'] as String));
    return result;
  }

  @override
  Future<Map<String, dynamic>> createConversation({
    required String userId,
    String? documentId,
    required String title,
  }) async {
    if (shouldFail) throw Exception(failMessage ?? 'Insert failed');
    final now = DateTime.now().toUtc().toIso8601String();
    final row = <String, dynamic>{
      'id': 'conv_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'document_id': documentId,
      'title': title,
      'created_at': now,
      'updated_at': now,
    };
    conversations.add(row);
    return row;
  }

  @override
  Future<void> deleteConversation(String id) async {
    if (shouldFail) throw Exception(failMessage ?? 'Delete failed');
    conversations.removeWhere((c) => c['id'] == id);
    messages.removeWhere((m) => m['conversation_id'] == id);
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    if (shouldFail) throw Exception(failMessage ?? 'Query failed');
    final result = messages
        .where((m) => m['conversation_id'] == conversationId)
        .toList();
    result.sort((a, b) =>
        (a['created_at'] as String).compareTo(b['created_at'] as String));
    return result;
  }

  @override
  Future<Map<String, dynamic>> insertMessage(
      Map<String, dynamic> messageData) async {
    if (shouldFail) throw Exception(failMessage ?? 'Insert failed');
    final row = Map<String, dynamic>.from(messageData);
    row['id'] ??= 'msg_${DateTime.now().millisecondsSinceEpoch}';
    row['created_at'] ??= DateTime.now().toUtc().toIso8601String();
    messages.add(row);

    final convId = row['conversation_id'] as String?;
    if (convId != null) {
      final convIdx = conversations.indexWhere((c) => c['id'] == convId);
      if (convIdx != -1) {
        conversations[convIdx]['updated_at'] =
            DateTime.now().toUtc().toIso8601String();
      }
    }

    return row;
  }

  @override
  Future<List<Map<String, dynamic>>> matchDocumentChunks({
    required List<double> queryEmbedding,
    double matchThreshold = 0.3,
    int matchCount = 5,
    String? filterDocumentId,
  }) async {
    if (shouldFail) throw Exception(failMessage ?? 'RPC failed');
    var matched = chunks.where((c) {
      if (filterDocumentId != null &&
          c['document_id'] != filterDocumentId) {
        return false;
      }
      final sim = c['similarity'] as double? ?? 0.85;
      return sim >= matchThreshold;
    }).toList();

    matched.sort((a, b) => ((b['similarity'] as double? ?? 0.0))
        .compareTo(a['similarity'] as double? ?? 0.0));
    return matched.take(matchCount).toList();
  }
}

void main() {
  group('SupabaseStorageService', () {
    late FakeSupabaseStorageService storageService;

    setUp(() {
      storageService = FakeSupabaseStorageService();
    });

    test('bucketName constant is documents', () {
      expect(SupabaseStorageService.bucketName, equals('documents'));
    });

    test('uploadBytes sanitizes special characters in file name and stores data',
        () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final path = await storageService.uploadBytes(
        userId: 'usr_123',
        fileName: 'my research paper #1 (draft).pdf',
        bytes: testBytes,
        mimeType: 'application/pdf',
      );

      expect(path, startsWith('usr_123/'));
      expect(path, contains('my_research_paper__1__draft_.pdf'));
      expect(storageService.storedFiles.containsKey(path), isTrue);
      expect(storageService.storedFiles[path], equals(testBytes));
    });

    test('getSignedUrl returns valid signed URL for uploaded file', () async {
      final testBytes = Uint8List.fromList([10, 20, 30]);
      final path = await storageService.uploadBytes(
        userId: 'usr_123',
        fileName: 'report.txt',
        bytes: testBytes,
      );

      final signedUrl = await storageService.getSignedUrl(
        storagePath: path,
        expiresInSeconds: 1800,
      );

      expect(signedUrl, contains(path));
      expect(signedUrl, contains('token=mock_jwt_exp_1800'));
    });

    test('downloadFile returns uploaded bytes', () async {
      final testBytes = Uint8List.fromList([7, 8, 9]);
      final path = await storageService.uploadBytes(
        userId: 'usr_123',
        fileName: 'data.txt',
        bytes: testBytes,
      );

      final downloaded = await storageService.downloadFile(storagePath: path);
      expect(downloaded, equals(testBytes));
    });

    test('deleteFile removes object from storage', () async {
      final testBytes = Uint8List.fromList([42]);
      final path = await storageService.uploadBytes(
        userId: 'usr_123',
        fileName: 'delete_me.pdf',
        bytes: testBytes,
      );

      expect(storageService.storedFiles.containsKey(path), isTrue);
      await storageService.deleteFile(storagePath: path);
      expect(storageService.storedFiles.containsKey(path), isFalse);
    });

    test('error handling when storage operation fails', () async {
      storageService.shouldFail = true;
      storageService.failMessage = 'Storage quota exceeded';

      expect(
        () => storageService.uploadBytes(
          userId: 'usr_123',
          fileName: 'large.pdf',
          bytes: Uint8List(0),
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Storage quota exceeded'),
        )),
      );
    });
  });

  group('SupabaseDatabaseService', () {
    late FakeSupabaseDatabaseService dbService;

    setUp(() {
      dbService = FakeSupabaseDatabaseService();
    });

    test('document CRUD operations work accurately', () async {
      // 1. Insert
      final newDoc = await dbService.insertDocument({
        'user_id': 'usr_456',
        'name': 'Attention_Is_All_You_Need.pdf',
        'file_url': 'usr_456/attention.pdf',
        'file_type': 'pdf',
        'file_size': 204800,
        'page_count': 15,
        'processing_status': 'pending',
        'summary': null,
        'metadata': {'conference': 'NeurIPS'},
      });

      expect(newDoc['id'], isNotNull);
      expect(newDoc['name'], equals('Attention_Is_All_You_Need.pdf'));

      // 2. Query list
      final userDocs = await dbService.getDocuments(userId: 'usr_456');
      expect(userDocs.length, equals(1));
      expect(userDocs.first['name'], equals('Attention_Is_All_You_Need.pdf'));

      // 3. Parse with DocumentModel
      final docModel = DocumentModel.fromJson(userDocs.first);
      expect(docModel.name, equals('Attention_Is_All_You_Need.pdf'));
      expect(docModel.fileType, equals(FileType.pdf));
      expect(docModel.status, equals(DocumentStatus.pending));
      expect(docModel.isReady, isFalse);

      // 4. Update status & summary
      final updated = await dbService.updateDocument(
        newDoc['id'] as String,
        {
          'processing_status': 'ready',
          'summary': 'The seminal paper introducing the Transformer architecture.',
        },
      );
      expect(updated['processing_status'], equals('ready'));

      final updatedModel = DocumentModel.fromJson(updated);
      expect(updatedModel.isReady, isTrue);
      expect(updatedModel.hasSummary, isTrue);
      expect(updatedModel.summary, contains('Transformer'));

      // 5. Delete
      await dbService.deleteDocument(newDoc['id'] as String);
      final remaining = await dbService.getDocuments(userId: 'usr_456');
      expect(remaining.isEmpty, isTrue);
    });

    test('conversation and message CRUD operations link correctly', () async {
      // 1. Create conversation
      final conv = await dbService.createConversation(
        userId: 'usr_456',
        title: 'Transformer Architecture Discussion',
        documentId: 'doc_1',
      );

      expect(conv['id'], isNotNull);
      expect(conv['title'], equals('Transformer Architecture Discussion'));

      final convModel = ConversationModel.fromJson(conv);
      expect(convModel.title, equals('Transformer Architecture Discussion'));
      expect(convModel.hasDocument, isTrue);

      // 2. Insert messages
      final userMsg = await dbService.insertMessage({
        'conversation_id': conv['id'],
        'role': 'user',
        'content': 'Explain multi-head self-attention.',
        'citations': [],
      });

      final assistantMsg = await dbService.insertMessage({
        'conversation_id': conv['id'],
        'role': 'assistant',
        'content':
            'Multi-head attention allows the model to jointly attend to information from different representation subspaces.',
        'citations': [
          {
            'document_id': 'doc_1',
            'document_name': 'Attention Is All You Need',
            'chunk_id': 'chunk_1',
            'page_number': 4,
            'content_preview': 'Multi-head attention allows the model to jointly attend...',
            'relevance_score': 0.95,
          }
        ],
      });

      // 3. Fetch messages
      final msgs = await dbService.getMessages(conv['id'] as String);
      expect(msgs.length, equals(2));

      final parsedUserMsg = ChatMessageModel.fromJson(userMsg);
      expect(parsedUserMsg.role, equals(MessageRole.user));
      expect(parsedUserMsg.isUser, isTrue);

      final parsedAssistantMsg = ChatMessageModel.fromJson(assistantMsg);
      expect(parsedAssistantMsg.role, equals(MessageRole.assistant));
      expect(parsedAssistantMsg.isAssistant, isTrue);
      expect(parsedAssistantMsg.hasCitations, isTrue);
      expect(parsedAssistantMsg.citations.first.pageNumber, equals(4));

      // 4. Delete conversation
      await dbService.deleteConversation(conv['id'] as String);
      final remainingMsgs = await dbService.getMessages(conv['id'] as String);
      expect(remainingMsgs.isEmpty, isTrue);
    });

    test('matchDocumentChunks filters by document and similarity threshold',
        () async {
      dbService.chunks.addAll([
        {
          'id': 'chunk_1',
          'document_id': 'doc_A',
          'chunk_index': 0,
          'content': 'Deep learning models utilize neural networks.',
          'page_number': 1,
          'similarity': 0.92,
        },
        {
          'id': 'chunk_2',
          'document_id': 'doc_A',
          'chunk_index': 1,
          'content': 'Transformers replace recurrent layers completely.',
          'page_number': 2,
          'similarity': 0.78,
        },
        {
          'id': 'chunk_3',
          'document_id': 'doc_B',
          'chunk_index': 0,
          'content': 'Unrelated medical biology chunk.',
          'page_number': 1,
          'similarity': 0.25,
        },
      ]);

      // Query across all documents with threshold 0.5
      final allMatches = await dbService.matchDocumentChunks(
        queryEmbedding: List.filled(768, 0.01),
        matchThreshold: 0.5,
        matchCount: 10,
      );
      expect(allMatches.length, equals(2));
      expect(allMatches.first['id'], equals('chunk_1'));

      // Query with document filter
      final docAMatches = await dbService.matchDocumentChunks(
        queryEmbedding: List.filled(768, 0.01),
        matchThreshold: 0.5,
        filterDocumentId: 'doc_A',
      );
      expect(docAMatches.length, equals(2));

      // Query with higher threshold
      final highSimMatches = await dbService.matchDocumentChunks(
        queryEmbedding: List.filled(768, 0.01),
        matchThreshold: 0.85,
      );
      expect(highSimMatches.length, equals(1));
      expect(highSimMatches.first['id'], equals('chunk_1'));
    });
  });
}
