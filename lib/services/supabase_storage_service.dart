import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase Storage service wrapper for document file uploads.
class SupabaseStorageService {
  final supabase.SupabaseClient? customClient;
  static const String bucketName = 'documents';

  SupabaseStorageService({this.customClient});

  supabase.SupabaseClient get client =>
      customClient ?? supabase.Supabase.instance.client;

  supabase.StorageFileApi get _bucket => client.storage.from(bucketName);

  /// Uploads raw file bytes to the user's isolated folder in the bucket.
  /// Returns the relative storage path (e.g. 'user_id/1718000000_filename.pdf').
  Future<String> uploadBytes({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';

    await _bucket.uploadBinary(
      storagePath,
      bytes,
      fileOptions: supabase.FileOptions(
        contentType: mimeType,
        upsert: false,
      ),
    );

    return storagePath;
  }

  /// Generates a temporary signed download URL for private documents.
  Future<String> getSignedUrl({
    required String storagePath,
    int expiresInSeconds = 3600,
  }) async {
    return await _bucket.createSignedUrl(storagePath, expiresInSeconds);
  }

  /// Deletes a file from the documents bucket.
  Future<void> deleteFile({required String storagePath}) async {
    await _bucket.remove([storagePath]);
  }

  /// Downloads the file as raw bytes.
  Future<Uint8List> downloadFile({required String storagePath}) async {
    return await _bucket.download(storagePath);
  }
}
