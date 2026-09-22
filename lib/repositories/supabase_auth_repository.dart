/// Supabase authentication repository implementation.
library;

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/data/user_model.dart';
import '../models/response/auth_response.dart';
import '../network/api_exception.dart';
import '../network/api_result.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../services/auth_service.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final AuthService authService;
  final AuthInterceptor? authInterceptor;

  SupabaseAuthRepository({
    required this.authService,
    this.authInterceptor,
  });

  @override
  Future<ApiResult<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authService.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        return const ApiFailure(
          UnauthorizedException(message: 'Authentication failed: No active session.'),
        );
      }

      // Keep interceptor synchronized with new JWT
      authInterceptor?.setToken(session.accessToken);

      final userModel = _mapSupabaseUserToModel(user);
      return ApiSuccess(
        AuthResponse(
          user: userModel,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        ),
      );
    } on supabase.AuthException catch (e) {
      return ApiFailure(
        ApiException(
          message: e.message,
          statusCode: int.tryParse(e.statusCode ?? '400') ?? 400,
        ),
      );
    } catch (e) {
      return ApiFailure(
        ApiException(message: 'Login failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<AuthResponse>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      final user = response.user;
      if (user == null) {
        return const ApiFailure(
          ApiException(message: 'Signup failed: Unable to create user.'),
        );
      }

      final session = response.session;
      final accessToken = session?.accessToken ?? '';
      if (accessToken.isNotEmpty) {
        authInterceptor?.setToken(accessToken);
      }

      final userModel = _mapSupabaseUserToModel(user, fallbackName: fullName);
      return ApiSuccess(
        AuthResponse(
          user: userModel,
          accessToken: accessToken,
          refreshToken: session?.refreshToken,
        ),
      );
    } on supabase.AuthException catch (e) {
      return ApiFailure(
        ApiException(
          message: e.message,
          statusCode: int.tryParse(e.statusCode ?? '400') ?? 400,
        ),
      );
    } catch (e) {
      return ApiFailure(
        ApiException(message: 'Signup failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await authService.resetPasswordForEmail(email: email);
      return const ApiSuccess(null);
    } on supabase.AuthException catch (e) {
      return ApiFailure(
        ApiException(
          message: e.message,
          statusCode: int.tryParse(e.statusCode ?? '400') ?? 400,
        ),
      );
    } catch (e) {
      return ApiFailure(
        ApiException(message: 'Password reset failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await authService.signOut();
      authInterceptor?.clearToken();
      return const ApiSuccess(null);
    } catch (e) {
      authInterceptor?.clearToken();
      return ApiFailure(
        ApiException(message: 'Logout failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = authService.currentUser;
    if (user == null) return null;

    final token = authService.currentAccessToken;
    if (token != null) {
      authInterceptor?.setToken(token);
    }

    return _mapSupabaseUserToModel(user);
  }

  @override
  Future<bool> isAuthenticated() async {
    return authService.currentSession != null;
  }

  /// Converts a Supabase SDK [supabase.User] into our clean domain [UserModel].
  UserModel _mapSupabaseUserToModel(
    supabase.User user, {
    String? fallbackName,
  }) {
    final metadata = user.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ??
        fallbackName ??
        user.email?.split('@').first ??
        'Researcher';

    final avatarUrl = metadata['avatar_url'] as String?;
    final createdAt = DateTime.tryParse(user.createdAt) ?? DateTime.now();

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
