/// Authentication response payload containing session tokens and user profile.
library;

import 'package:equatable/equatable.dart';
import '../data/user_model.dart';

class AuthResponse extends Equatable {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
