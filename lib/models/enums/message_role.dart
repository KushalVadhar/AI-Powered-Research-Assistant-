/// Chat message role — identifies who sent a message.
enum MessageRole {
  user('user', 'You'),
  assistant('assistant', 'AI Assistant'),
  system('system', 'System');

  const MessageRole(this.value, this.label);

  /// JSON/API value.
  final String value;

  /// Display label for the UI.
  final String label;

  static final Map<String, MessageRole> _fromJsonMap = {
    for (final role in values) role.value: role,
  };

  /// Creates a [MessageRole] from a JSON string.
  /// Returns [user] as fallback for unknown values.
  static MessageRole fromJson(String value) {
    return _fromJsonMap[value] ?? MessageRole.user;
  }

  String toJson() => value;
}
