import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase Database service wrapper for PostgreSQL CRUD, realtime streams, and pgvector RPC.
class SupabaseDatabaseService {
  final supabase.SupabaseClient? customClient;

  SupabaseDatabaseService({this.customClient});

  supabase.SupabaseClient get client =>
      customClient ?? supabase.Supabase.instance.client;

  // ===========================================================================
  // Documents
  // ===========================================================================

  /// Fetches documents for a user, sorted newest first.
  Future<List<Map<String, dynamic>>> getDocuments({String? userId}) async {
    var query = client.from('documents').select();
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetches a single document by its UUID.
  Future<Map<String, dynamic>?> getDocumentById(String id) async {
    final response = await client
        .from('documents')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response != null ? Map<String, dynamic>.from(response) : null;
  }

  /// Inserts a new document record.
  Future<Map<String, dynamic>> insertDocument(
      Map<String, dynamic> documentData) async {
    final response = await client
        .from('documents')
        .insert(documentData)
        .select()
        .single();
    return Map<String, dynamic>.from(response);
  }

  /// Updates document fields (such as status, summary, or page count).
  Future<Map<String, dynamic>> updateDocument(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await client
        .from('documents')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(response);
  }

  /// Deletes a document record by ID.
  Future<void> deleteDocument(String id) async {
    await client.from('documents').delete().eq('id', id);
  }

  /// Subscribes to realtime updates on the documents table.
  Stream<List<Map<String, dynamic>>> watchDocuments({String? userId}) {
    var stream = client.from('documents').stream(primaryKey: ['id']);
    if (userId != null) {
      stream = stream.eq('user_id', userId);
    }
    return stream.order('created_at', ascending: false);
  }

  // ===========================================================================
  // Conversations & Messages
  // ===========================================================================

  /// Fetches conversations for a user, sorted by last updated.
  Future<List<Map<String, dynamic>>> getConversations({String? userId}) async {
    var query = client.from('conversations').select();
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final response = await query.order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Creates a new conversation thread.
  Future<Map<String, dynamic>> createConversation({
    required String userId,
    String? documentId,
    required String title,
  }) async {
    final response = await client
        .from('conversations')
        .insert({
          'user_id': userId,
          'document_id': documentId,
          'title': title,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(response);
  }

  /// Deletes a conversation by ID (cascades to messages).
  Future<void> deleteConversation(String id) async {
    await client.from('conversations').delete().eq('id', id);
  }

  /// Fetches all messages in a conversation ordered chronologically.
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final response = await client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Inserts a chat message and updates the parent conversation's updated_at timestamp.
  Future<Map<String, dynamic>> insertMessage(
      Map<String, dynamic> messageData) async {
    final response = await client
        .from('messages')
        .insert(messageData)
        .select()
        .single();

    final conversationId = messageData['conversation_id'] as String?;
    if (conversationId != null) {
      await client
          .from('conversations')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', conversationId);
    }

    return Map<String, dynamic>.from(response);
  }

  // ===========================================================================
  // pgvector Semantic Match RPC
  // ===========================================================================

  /// Executes pgvector cosine similarity search on document chunks via RPC.
  Future<List<Map<String, dynamic>>> matchDocumentChunks({
    required List<double> queryEmbedding,
    double matchThreshold = 0.3,
    int matchCount = 5,
    String? filterDocumentId,
  }) async {
    final response = await client.rpc(
      'match_document_chunks',
      params: {
        'query_embedding': queryEmbedding,
        'match_threshold': matchThreshold,
        'match_count': matchCount,
        'filter_document_id': filterDocumentId,
      },
    );
    return List<Map<String, dynamic>>.from(response as List);
  }
}
