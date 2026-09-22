/// Authentication state management Cubit.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/api_result.dart';
import '../../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthInitial());

  /// Checks if a session already exists on device startup.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Signs in a user with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await authRepository.login(
      email: email,
      password: password,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(Authenticated(data.user));
      case ApiFailure(:final exception):
        emit(AuthError(exception.message));
    }
  }

  /// Registers a new user account.
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(const AuthLoading());
    final result = await authRepository.signup(
      email: email,
      password: password,
      fullName: fullName,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(Authenticated(data.user));
      case ApiFailure(:final exception):
        emit(AuthError(exception.message));
    }
  }

  /// Sends a password reset email.
  Future<bool> resetPassword(String email) async {
    final result = await authRepository.sendPasswordResetEmail(email: email);
    switch (result) {
      case ApiSuccess():
        return true;
      case ApiFailure(:final exception):
        emit(AuthError(exception.message));
        return false;
    }
  }

  /// Logs the user out of the current session.
  Future<void> logout() async {
    emit(const AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated());
  }
}
