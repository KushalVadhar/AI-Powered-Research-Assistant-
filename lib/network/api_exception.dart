/// Custom API exception types.
/// Base exception for all API errors.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
  });

  /// Human-readable error message.
  final String message;

  /// HTTP status code (if applicable).
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 — User's session has expired or token is invalid.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}

/// 403 — User doesn't have permission for this action.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You don\'t have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// 404 — Requested resource doesn't exist.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

/// 422 — Validation error (invalid input data).
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Invalid input. Please check your data.',
    super.statusCode = 422,
    this.errors = const {},
  });

  /// Field-level error messages (e.g., {'email': 'Invalid email format'}).
  final Map<String, String> errors;
}

/// 429 — Too many requests (rate limited).
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Too many requests. Please try again later.',
    super.statusCode = 429,
  });
}

/// 500+ — Server-side error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error. Our team has been notified.',
    super.statusCode = 500,
  });
}

/// No internet connection or DNS resolution failure.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  });
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again later.',
    super.statusCode,
  });
}
