/// Authentication repository interface contract.
library;

import '../models/data/user_model.dart';
import '../models/response/auth_response.dart';
import '../network/api_result.dart';

abstract class AuthRepository {
  /// Signs in a user with email and password credentials.
  Future<ApiResult<AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Registers a new user account.
  Future<ApiResult<AuthResponse>> signup({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sends a password reset email.
  Future<ApiResult<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Logs out the current user and clears local credentials.
  Future<ApiResult<void>> logout();

  /// Retrieves the currently authenticated user, or null if unauthenticated.
  Future<UserModel?> getCurrentUser();

  /// Whether a valid user session is currently active.
  Future<bool> isAuthenticated();
}
