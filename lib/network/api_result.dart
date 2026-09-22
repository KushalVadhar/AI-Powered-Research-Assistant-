import 'api_exception.dart';

/// Sealed result type for API operations.
sealed class ApiResult<T> {
  const ApiResult();
}

/// Successful API result containing data of type T.
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  /// The successful response data.
  final T data;
}

/// Failed API result containing an exception.
final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  /// The exception that caused the failure.
  final ApiException exception;
}
