import 'package:dio/dio.dart';

/// Auth interceptor — attaches the JWT access token to every request.
class AuthInterceptor extends Interceptor {
  /// Optional dynamic token provider callback (e.g. from Supabase session).
  final String? Function()? tokenProvider;

  AuthInterceptor({this.tokenProvider});

  /// The current access token. Null when user is not authenticated.
  String? _accessToken;

  /// Sets the access token for all subsequent requests.
  ///
  /// Called after successful login or token refresh.
  void setToken(String token) {
    _accessToken = token;
  }

  /// Clears the access token (on logout).
  void clearToken() {
    _accessToken = null;
  }

  /// Whether a token is currently available.
  bool get hasToken => _accessToken != null || (tokenProvider?.call() != null);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check explicitly set token, or query dynamic token provider
    final token = _accessToken ?? tokenProvider?.call();

    // If we have a token, attach it to the request
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Always pass the request to the next interceptor
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO(Phase 6): Implement token refresh logic here.
    //
    // When the access token expires, the backend returns 401.
    // The ideal flow is:
    //   1. Catch 401 error
    //   2. Use refresh token to get a new access token
    //   3. Retry the original request with the new token
    //   4. If refresh also fails → force logout
    //
    // This prevents the user from being logged out every time
    // their short-lived access token expires (typically 1 hour).

    handler.next(err);
  }
}
