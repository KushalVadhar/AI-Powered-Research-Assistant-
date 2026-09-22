/// Supported document file types.
enum FileType {
  pdf('pdf', 'PDF Document', 'application/pdf'),
  docx('docx', 'Word Document', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
  txt('txt', 'Text File', 'text/plain');

  const FileType(this.extension, this.label, this.mimeType);

  /// File extension without the dot.
  final String extension;

  /// Human-readable label.
  final String label;

  /// MIME type for HTTP Content-Type headers.
  final String mimeType;

  static final Map<String, FileType> _fromExtensionMap = {
    for (final type in values) type.extension: type,
  };

  /// Creates a [FileType] from a file extension string.
  /// Returns null if the extension is not supported.
  static FileType? fromExtension(String ext) {
    // Normalize: remove leading dot and lowercase
    final normalized = ext.replaceAll('.', '').toLowerCase();
    return _fromExtensionMap[normalized];
  }

  /// Whether a given extension is supported.
  static bool isSupported(String ext) {
    return fromExtension(ext) != null;
  }
}
