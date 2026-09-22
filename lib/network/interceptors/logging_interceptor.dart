import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Logging interceptor — logs HTTP requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logBody = false});

  /// Whether to log request/response bodies (verbose mode).
  /// Default is false — set to true when debugging specific issues.
  final bool logBody;

  static const String _name = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Store the request start time in the `extra` map.
    // `extra` is a general-purpose Map<String, dynamic> on RequestOptions
    // that Dio carries through the request lifecycle. Perfect for
    // attaching metadata that interceptors downstream can read.
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;

    final method = options.method.toUpperCase();
    final path = options.path;

    AppLogger.debug('→ $method $path', name: _name);

    if (logBody && options.data != null) {
      AppLogger.debug('  Body: ${options.data}', name: _name);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final path = response.requestOptions.path;
    final statusCode = response.statusCode;

    // Calculate request duration
    final startTime =
        response.requestOptions.extra['startTime'] as int? ?? 0;
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;

    AppLogger.debug(
      '← $method $path ($statusCode) in ${duration}ms',
      name: _name,
    );

    if (logBody && response.data != null) {
      // Truncate large response bodies to avoid flooding the log
      final body = response.data.toString();
      final truncated =
          body.length > 500 ? '${body.substring(0, 500)}...' : body;
      AppLogger.debug('  Response: $truncated', name: _name);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method.toUpperCase();
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode ?? 'N/A';

    // Calculate request duration
    final startTime = err.requestOptions.extra['startTime'] as int? ?? 0;
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;

    AppLogger.error(
      '✕ $method $path ($statusCode) in ${duration}ms — ${err.message}',
      name: _name,
      error: err,
    );

    handler.next(err);
  }
}
