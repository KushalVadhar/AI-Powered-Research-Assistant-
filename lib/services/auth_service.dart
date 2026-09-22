/// Supabase authentication service wrapper.
library;

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthService {
  final supabase.SupabaseClient? customClient;

  AuthService({this.customClient});

  supabase.SupabaseClient get client =>
      customClient ?? supabase.Supabase.instance.client;

  supabase.GoTrueClient get _auth => client.auth;

  /// Retrieves the currently authenticated Supabase user, or null.
  supabase.User? get currentUser => _auth.currentUser;

  /// Retrieves the active Supabase session (including access token), or null.
  supabase.Session? get currentSession => _auth.currentSession;

  /// Access token getter for the current session.
  String? get currentAccessToken => _auth.currentSession?.accessToken;

  /// Stream of Supabase authentication state changes (SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED, etc.).
  Stream<supabase.AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Signs in using email and password credentials.
  Future<supabase.AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a new user account with email, password, and custom metadata.
  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
      },
    );
  }

  /// Sends a password reset request email to the specified address.
  Future<void> resetPasswordForEmail({required String email}) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  /// Signs out the current user session and invalidates local tokens.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
