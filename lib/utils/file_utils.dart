/// File and filesystem utility helper functions.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enums/file_type.dart';

class FileUtils {
  FileUtils._();

  /// Formats raw byte count into human-readable string (e.g., "1.4 MB", "512 KB").
  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final clampedIndex = i.clamp(0, suffixes.length - 1);
    final size = bytes / pow(1024, clampedIndex);
    return '${size.toStringAsFixed(decimals)} ${suffixes[clampedIndex]}';
  }

  /// Extracts the file extension in lowercase without the dot (e.g., "pdf").
  static String getExtension(String pathOrName) {
    if (pathOrName.isEmpty) return '';
    final lastDot = pathOrName.lastIndexOf('.');
    if (lastDot == -1 || lastDot == pathOrName.length - 1) return '';
    return pathOrName.substring(lastDot + 1).toLowerCase();
  }

  /// Resolves the domain [FileType] enum from a filename or path.
  static FileType resolveFileType(String pathOrName) {
    final ext = getExtension(pathOrName);
    return FileType.fromExtension(ext) ?? FileType.pdf;
  }

  /// Returns an appropriate [IconData] for a given [FileType].
  static IconData getFileTypeIcon(FileType? type) {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.docx:
        return Icons.description_rounded;
      case FileType.txt:
        return Icons.article_rounded;
      case null:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Returns a signature color associated with each document type.
  static Color getFileTypeColor(FileType? type) {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFEF4444); // Red
      case FileType.docx:
        return const Color(0xFF2563EB); // Blue
      case FileType.txt:
        return const Color(0xFF10B981); // Emerald green
      case null:
        return const Color(0xFF64748B); // Slate gray
    }
  }
}
