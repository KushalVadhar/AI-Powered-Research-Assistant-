/// Document processing status.
enum DocumentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  ready('ready', 'Ready'),
  failed('failed', 'Failed');

  const DocumentStatus(this.value, this.label);

  /// The JSON/API value (lowercase string sent to/from backend).
  final String value;

  /// Human-readable label for UI display.
  final String label;

  /// Lookup map for O(1) deserialization.
  static final Map<String, DocumentStatus> _fromJsonMap = {
    for (final status in values) status.value: status,
  };

  /// Creates a [DocumentStatus] from a JSON string.
  /// Returns [pending] as fallback for unknown values.
  static DocumentStatus fromJson(String value) {
    return _fromJsonMap[value] ?? DocumentStatus.pending;
  }

  /// Converts to JSON string.
  String toJson() => value;
}
