import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../models/certificate.dart';

class ShareService {
  static Future<void> shareCertificate(Certificate cert, {String? organizerName}) async {
    try {
      final text = 'Sertifikat: ${cert.title}\n'
          'Penyelenggara: ${organizerName ?? "Certify"}\n'
          'Kategori: ${cert.category}\n'
          'ID: ${cert.certificateNumber ?? cert.id}\n'
          'Dibagikan via aplikasi Certify (Personal Certificate Manager)';

      final file = File(cert.filePath);
      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(cert.filePath, name: '${cert.title}.${cert.fileType}')],
            text: text,
            subject: cert.title,
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: cert.title,
          ),
        );
      }
    } catch (e) {
      throw Exception('Gagal membagikan sertifikat: $e');
    }
  }
}
