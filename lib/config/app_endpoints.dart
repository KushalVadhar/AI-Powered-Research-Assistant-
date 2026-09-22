/// API endpoint path constants.
class AppEndpoints {
  AppEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profile = '/auth/profile';

  // ── Documents ─────────────────────────────────────────────────
  static const String documents = '/documents';

  /// Use with string interpolation: '${AppEndpoints.documents}/$id'
  static String documentById(String id) => '/documents/$id';
  static String processDocument(String id) => '/documents/$id/process';

  // ── Chat ──────────────────────────────────────────────────────
  static const String conversations = '/conversations';
  static String conversationById(String id) => '/conversations/$id';
  static String chatMessages(String conversationId) =>
      '/conversations/$conversationId/messages';
  static const String chatSend = '/chat/send';
  static const String chatStream = '/chat/stream';

  // ── Summary ───────────────────────────────────────────────────
  static String summarizeDocument(String id) => '/documents/$id/summary';

  // ── Compare ───────────────────────────────────────────────────
  static const String compareDocuments = '/documents/compare';
}
