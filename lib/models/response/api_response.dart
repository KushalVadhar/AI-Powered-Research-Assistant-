/// Generic API response wrapper.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Whether the API call succeeded.
  final bool success;

  /// Human-readable status message from the server.
  final String message;

  /// The response payload, typed to T.
  final T? data;

  /// Creates an [ApiResponse] from JSON.
  ///
  /// [dataFromJson] converts the raw `data` field into type T.
  /// If data is null or success is false, `data` will be null.
  ///
  /// Usage:
  /// ```dart
  /// final response = ApiResponse.fromJson(
  ///   json,
  ///   (data) => UserModel.fromJson(data as Map<String, dynamic>),
  /// );
  /// ```
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? dataFromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && dataFromJson != null
          ? dataFromJson(json['data'])
          : null,
    );
  }

  /// Creates a success response.
  factory ApiResponse.success({
    required String message,
    T? data,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  /// Creates a failure response.
  factory ApiResponse.failure({
    required String message,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
    );
  }
}
