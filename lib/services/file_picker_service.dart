import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/file_utils.dart';
import 'storage_service.dart';

class PickedDocumentResult {
  final String filePath;
  final String fileName;
  final String fileType; // 'image' or 'pdf'
  final int fileSizeBytes;

  PickedDocumentResult({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
  });
}

class FilePickerService {
  static const _uuid = Uuid();

  // Pick file from device storage
  static Future<PickedDocumentResult?> pickDocument() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedFileExtensions,
      );

      if (files.isEmpty) {
        return null; // User cancelled
      }

      final file = files.first;
      final sourcePath = file.path;

      if (sourcePath == null) {
        throw Exception('Path file tidak dapat diakses dari perangkat');
      }

      // Check file size
      final fileSize = (await file.length()) ?? file.lengthSync() ?? 0;
      if (fileSize > AppConstants.maxFileSizeBytes) {
        throw Exception('Ukuran file melebihi batas maksimum 10 MB (${FileUtils.formatBytes(fileSize)})');
      }

      // Check extension
      final ext = FileUtils.getFileExtension(sourcePath);
      if (!AppConstants.allowedFileExtensions.contains(ext)) {
        throw Exception('Format file tidak didukung. Harap pilih format JPG, PNG, atau PDF');
      }

      // Generate unique name and copy to internal app directory
      final uniqueFileName = 'cert_${_uuid.v4()}.$ext';
      final internalPath = await StorageService.copyFileToInternalStorage(
        sourcePath,
        uniqueFileName,
      );

      return PickedDocumentResult(
        filePath: internalPath,
        fileName: file.name,
        fileType: FileUtils.getFileType(internalPath),
        fileSizeBytes: fileSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Pick from sample assets for quick demo / testing
  static Future<PickedDocumentResult> pickSamplePreset(String sampleName, String ext) async {
    final uniqueFileName = 'sample_${_uuid.v4()}.$ext';
    final assetPath = 'assets/dummy/$sampleName.$ext';
    final internalPath = await StorageService.copyAssetToInternalStorage(
      assetPath,
      uniqueFileName,
    );

    int size = 0;
    try {
      final f = File(internalPath);
      if (await f.exists()) {
        size = await f.length();
      }
    } catch (_) {}

    return PickedDocumentResult(
      filePath: internalPath,
      fileName: '$sampleName.$ext',
      fileType: FileUtils.getFileType(internalPath),
      fileSizeBytes: size > 0 ? size : 256000,
    );
  }
}
