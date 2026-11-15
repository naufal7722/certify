import 'package:flutter_test/flutter_test.dart';
import 'package:certify/models/organizer.dart';
import 'package:certify/models/certificate.dart';
import 'package:certify/core/constants/app_constants.dart';
import 'package:certify/core/utils/date_formatter.dart';
import 'package:certify/core/utils/file_utils.dart';

void main() {
  group('Certify Unit Tests', () {
    test('Organizer Model serialization and copyWith', () {
      final now = DateTime(2026, 1, 15);
      final org = Organizer(
        id: 'org-test-1',
        name: 'Dicoding Indonesia',
        createdAt: now,
      );

      final map = org.toMap();
      expect(map['id'], 'org-test-1');
      expect(map['name'], 'Dicoding Indonesia');

      final fromMap = Organizer.fromMap(map);
      expect(fromMap.id, org.id);
      expect(fromMap.name, org.name);

      final updated = org.copyWith(name: 'Dicoding Academy');
      expect(updated.name, 'Dicoding Academy');
      expect(updated.id, org.id);
    });

    test('Certificate Model serialization and toggling favorite', () {
      final cert = Certificate(
        id: 'cert-123',
        title: 'Flutter Mobile Expert',
        category: 'Workshop',
        organizerId: 'org-test-1',
        issueDate: DateTime(2026, 2, 10),
        filePath: 'assets/dummy/flutter_workshop.pdf',
        fileType: 'pdf',
        certificateNumber: 'FLT-2026-99',
        isFavorite: false,
      );

      expect(cert.isFavorite, false);

      final favorited = cert.copyWith(isFavorite: true);
      expect(favorited.isFavorite, true);

      final map = favorited.toMap();
      final fromMap = Certificate.fromMap(map);
      expect(fromMap.isFavorite, true);
      expect(fromMap.title, 'Flutter Mobile Expert');
    });

    test('DateFormatter formats dates correctly', () {
      final date = DateTime(2026, 3, 25);
      expect(DateFormatter.formatYear(date), '2026');
      expect(DateFormatter.formatShort(date), isNotEmpty);
    });

    test('FileUtils detects extension and formats bytes', () {
      expect(FileUtils.getFileType('document.pdf'), 'pdf');
      expect(FileUtils.getFileType('photo.png'), 'image');
      expect(FileUtils.getFileType('photo.jpg'), 'image');
      expect(FileUtils.isPdf('test.pdf'), true);
      expect(FileUtils.isImage('sample.png'), true);

      expect(FileUtils.formatBytes(1024), '1.0 KB');
      expect(FileUtils.formatBytes(10 * 1024 * 1024), '10.0 MB');
    });

    test('AppConstants contains required ATS categories', () {
      expect(AppConstants.categories, contains('Workshop'));
      expect(AppConstants.categories, contains('Competition'));
      expect(AppConstants.categories, contains('Webinar'));
      expect(AppConstants.categories, contains('Certification'));
    });
  });
}
