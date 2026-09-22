import 'package:dio/dio.dart';

import '../config/app_constants.dart';
import '../models/response/api_response.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import 'api_result.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Central HTTP service — ALL network requests go through here.
class HttpService {
  HttpService({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        connectTimeout:
            const Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout:
            const Duration(seconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order.
    // ORDER MATTERS: interceptors execute in the order they're added.
    //   Request:  auth → logging → network
    //   Response: network → logging → auth
    _dio.interceptors.addAll([
      authInterceptor,
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;

  /// Public auth interceptor so external code can set/clear tokens.
  ///
  /// Usage:
  ///   httpService.authInterceptor.setToken(jwt);
  ///   httpService.authInterceptor.clearToken();
  final AuthInterceptor authInterceptor = AuthInterceptor();

  // ══════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ══════════════════════════════════════════════════════════════

  /// Performs a GET request.
  ///
  /// [endpoint] — API path (e.g., '/documents')
  /// [fromJson] — function to parse the response `data` field into type T.
  ///              Pass null if the endpoint returns no data (e.g., health check).
  /// [queryParameters] — URL query parameters (e.g., ?page=1&limit=20)
  ///
  Future<ApiResult<T>> get<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs a POST request.
  ///
  /// [body] — request body (will be serialized to JSON).
  ///          Use .toJson() on your request DTOs.
  Future<ApiResult<T>> post<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs a PUT request (full resource replacement).
  Future<ApiResult<T>> put<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.put(endpoint, data: body);
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs a PATCH request (partial resource update).
  ///
  Future<ApiResult<T>> patch<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.patch(endpoint, data: body);
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Performs a DELETE request.
  Future<ApiResult<T>> delete<T>({
    required String endpoint,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.delete(endpoint, data: body);
      return _parseResponse<T>(response, fromJson);
    });
  }

  /// Uploads a file using multipart/form-data.
  ///
  Future<ApiResult<T>> uploadFile<T>({
    required String endpoint,
    required String filePath,
    required String fileFieldName,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? additionalFields,
  }) async {
    return _executeRequest(() async {
      final formData = FormData.fromMap({
        fileFieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  // ══════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ══════════════════════════════════════════════════════════════

  /// Executes a request and wraps the result in ApiResult.
  ///
  /// WHY THIS WRAPPER:
  /// Every HTTP method has the same error handling pattern:
  ///   try { make request → return success } catch { map error → return failure }
  ///
  /// Without this, we'd duplicate the try/catch + error mapping in
  /// EVERY method (get, post, put, patch, delete). DRY principle:
  /// extract the shared logic into one function.
  ///
  Future<ApiResult<T>> _executeRequest<T>(
    Future<ApiResult<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      return ApiFailure(_mapDioException(e));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error',
        error: e,
        stackTrace: stackTrace,
      );
      return ApiFailure(
        ApiException(message: 'An unexpected error occurred: $e'),
      );
    }
  }

  /// Parses a Dio Response into our standard ApiResult format.
  ///
  /// Expects the backend response to follow our standard format:
  /// { "success": true, "message": "...", "data": { ... } }
  ///
  /// If [fromJson] is null, returns ApiSuccess with null data
  /// (useful for endpoints that don't return data, like DELETE).
  ApiResult<T> _parseResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final responseData = response.data;

    // If the response is our standard API format
    if (responseData is Map<String, dynamic>) {
      final apiResponse = ApiResponse.fromJson(responseData, fromJson);

      if (apiResponse.success) {
        return ApiSuccess(apiResponse.data as T);
      } else {
        return ApiFailure(
          ApiException(
            message: apiResponse.message,
            statusCode: response.statusCode,
          ),
        );
      }
    }

    // If the response is a raw value (not our standard format),
    // try to parse it directly
    if (fromJson != null) {
      return ApiSuccess(fromJson(responseData));
    }

    return ApiSuccess(responseData as T);
  }

  /// Maps Dio exceptions to our typed ApiException hierarchy.
  ///
  /// WHY THIS MAPPING:
  /// DioException is a catch-all. It could be a timeout, a network
  /// failure, a 404, or a 500 — all wrapped in the same class.
  /// We map to specific types so the BLoC can react differently:
  ///
  ///   DioException(type: connectionTimeout) → TimeoutException
  ///     → BLoC emits TimeoutState → Screen shows "Server is slow"
  ///
  ///   DioException(response.statusCode: 401) → UnauthorizedException
  ///     → BLoC emits UnauthenticatedState → Router redirects to login
  ///
  ///   DioException(type: connectionError) → NetworkException
  ///     → BLoC emits NetworkErrorState → Screen shows "No internet"
  ApiException _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(
          exception.response?.statusCode,
          exception.response?.data,
        );

      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Certificate verification failed',
        );

      case DioExceptionType.transformTimeout:
        return const TimeoutException();

      case DioExceptionType.unknown:
        // Check if the underlying error is a network issue
        if (exception.error.toString().contains('SocketException')) {
          return const NetworkException();
        }
        return ApiException(
          message: exception.message ?? 'An unknown error occurred',
        );
    }
  }

  /// Maps HTTP status codes to specific exception types.
  ///
  /// Tries to extract the error message from the response body.
  /// Falls back to generic messages if the body isn't parseable.
  ApiException _mapStatusCode(int? statusCode, dynamic responseData) {
    // Try to extract error message from response body
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String? ??
          responseData['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: serverMessage ?? 'Bad request',
          statusCode: 400,
        );
      case 401:
        return UnauthorizedException(
          message: serverMessage ?? 'Session expired. Please log in again.',
        );
      case 403:
        return ForbiddenException(
          message: serverMessage ??
              'You don\'t have permission to perform this action.',
        );
      case 404:
        return NotFoundException(
          message: serverMessage ?? 'The requested resource was not found.',
        );
      case 422:
        return ValidationException(
          message: serverMessage ?? 'Invalid input. Please check your data.',
        );
      case 429:
        return const RateLimitException();
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message:
                serverMessage ?? 'Server error. Our team has been notified.',
          );
        }
        return ApiException(
          message: serverMessage ?? 'An unexpected error occurred',
          statusCode: statusCode,
        );
    }
  }
}
