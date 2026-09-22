/// Named route constants.
class RouteNames {
  RouteNames._();

  // ── Root ───────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ── Auth ───────────────────────────────────────────────────
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // ── Main App ──────────────────────────────────────────────
  static const String home = '/home';

  // ── Documents ─────────────────────────────────────────────
  static const String documents = '/documents';
  static const String documentDetails = '/documents/:id';
  static const String uploadDocument = '/documents/upload';

  // ── Chat ──────────────────────────────────────────────────
  static const String conversations = '/conversations';
  static const String chat = '/chat/:conversationId';

  // ── Summary ───────────────────────────────────────────────
  static const String summary = '/documents/:id/summary';

  // ── Compare ───────────────────────────────────────────────
  static const String compareDocuments = '/compare';

  // ── Profile ───────────────────────────────────────────────
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ── Helper Methods ────────────────────────────────────────
  /// Creates a document details path with the given id.
  static String documentDetailsPath(String id) => '/documents/$id';

  /// Creates a chat path with the given conversation id.
  static String chatPath(String conversationId) => '/chat/$conversationId';

  /// Creates a summary path with the given document id.
  static String summaryPath(String id) => '/documents/$id/summary';
}
