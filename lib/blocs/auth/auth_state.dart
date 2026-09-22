/// Authentication state definitions.
library;

import 'package:equatable/equatable.dart';
import '../../models/data/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts up before checking session.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during login, signup, or session validation.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with an active session and profile.
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated (signed out or session expired).
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// An authentication action failed (e.g. invalid password, network error).
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
