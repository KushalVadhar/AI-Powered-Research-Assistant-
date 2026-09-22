/// In-memory mock authentication repository implementation.
library;

import '../../models/data/user_model.dart';
import '../../models/response/auth_response.dart';
import '../../network/api_exception.dart';
import '../../network/api_result.dart';
import '../auth_repository.dart';
import 'mock_data.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  final Duration delay;

  MockAuthRepository({
    this.delay = const Duration(milliseconds: 500),
    bool startAuthenticated = true,
  }) {
    if (startAuthenticated) {
      _currentUser = MockData.currentUser;
    }
  }

  @override
  Future<ApiResult<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(delay);

    if (password.length < 6) {
      return const ApiFailure(
        ValidationException(message: 'Password must be at least 6 characters'),
      );
    }

    _currentUser = MockData.currentUser.copyWith(email: email);
    return ApiSuccess(
      AuthResponse(
        user: _currentUser!,
        accessToken: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<ApiResult<AuthResponse>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(delay);

    if (password.length < 6) {
      return const ApiFailure(
        ValidationException(message: 'Password must be at least 6 characters'),
      );
    }

    _currentUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
    );

    return ApiSuccess(
      AuthResponse(
        user: _currentUser!,
        accessToken: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<ApiResult<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    await Future.delayed(delay);
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> logout() async {
    await Future.delayed(delay);
    _currentUser = null;
    return const ApiSuccess(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _currentUser != null;
  }
}
