import 'dart:io';

class FileUtils {
  static String getFileExtension(String path) {
    if (!path.contains('.')) return '';
    return path.split('.').last.toLowerCase();
  }

  static String getFileType(String path) {
    final ext = getFileExtension(path);
    if (ext == 'pdf') {
      return 'pdf';
    }
    return 'image';
  }

  static bool isPdf(String path) {
    return getFileType(path) == 'pdf';
  }

  static bool isImage(String path) {
    return getFileType(path) == 'image';
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  static Future<int> getFileSizeBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
  }

  static Future<bool> fileExists(String path) async {
    if (path.startsWith('assets/')) return true;
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }
}
