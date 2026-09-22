/// Application-wide constants.
class AppConstants {
  AppConstants._(); // Prevents instantiation

  // ── App Identity ──────────────────────────────────────────────
  static const String appName = 'AI Research Assistant';
  static const String appVersion = '1.0.0';

  // ── Supabase Configuration ────────────────────────────────────
  /// Supabase project URL.
  /// Can be supplied at build time via `--dart-define=SUPABASE_URL=...`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dutjtfltvstujwrkaisu.supabase.co',
  );

  /// Supabase anonymous API key.
  /// Can be supplied at build time via `--dart-define=SUPABASE_ANON_KEY=...`
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dGp0Zmx0dnN0dWp3cmthaXN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwNzQ2MDAsImV4cCI6MjEwNTY1MDYwMH0.Zn38kkqugtxwsui7__rg5kohKzwRPiDYWjt3nIotuqg',
  );

  /// Indicates whether real Supabase credentials have been configured.
  /// When false, the app runs in local mock mode without network errors.
  static bool get isSupabaseConfigured =>
      supabaseUrl != 'https://placeholder.supabase.co' &&
      !supabaseUrl.contains('placeholder') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('placeholder');

  // ── Networking ────────────────────────────────────────────────
  /// Base URL for the FastAPI backend.
  /// In production, this would come from environment config or flavor.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  /// Request timeout in seconds.
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 60;

  // ── Pagination ────────────────────────────────────────────────
  /// Default number of items per page for list endpoints.
  static const int defaultPageSize = 20;

  // ── Document Processing ───────────────────────────────────────
  /// Maximum file size for document uploads (in bytes).
  /// 20 MB = 20 * 1024 * 1024
  static const int maxFileSize = 20 * 1024 * 1024;

  /// Allowed file extensions for upload.
  static const List<String> allowedFileExtensions = ['pdf', 'docx', 'txt'];

  // ── Chat ──────────────────────────────────────────────────────
  /// Maximum number of messages to show in conversation history preview.
  static const int maxPreviewMessages = 5;

  /// Number of top chunks to retrieve for RAG context.
  static const int ragTopK = 5;

  // ── Storage Keys ──────────────────────────────────────────────
  /// SharedPreferences / secure storage keys.
  static const String themeKey = 'theme_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';
}
