import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/certificate.dart';
import '../models/organizer.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Get App Documents Directory path
  static Future<String> getAppStorageDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final certsDir = Directory('${dir.path}/certify_documents');
    if (!await certsDir.exists()) {
      await certsDir.create(recursive: true);
    }
    return certsDir.path;
  }

  // Copy an asset or temporary file to internal storage
  static Future<String> copyAssetToInternalStorage(String assetPath, String targetFileName) async {
    try {
      final storageDir = await getAppStorageDirectory();
      final targetFile = File('$storageDir/$targetFileName');

      if (await targetFile.exists()) {
        return targetFile.path;
      }

      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer;
      await targetFile.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      return targetFile.path;
    } catch (e) {
      // If rootBundle load fails (e.g. running outside flutter assets), fallback to assetPath
      return assetPath;
    }
  }

  // Copy local file from picker to internal storage
  static Future<String> copyFileToInternalStorage(String sourcePath, String targetFileName) async {
    final storageDir = await getAppStorageDirectory();
    final targetFile = File('$storageDir/$targetFileName');
    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetFile.path);
    return targetFile.path;
  }

  // Check if initial dummy data has been seeded
  static Future<bool> isDataSeeded() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyIsInitialized) ?? false;
  }

  // Load Organizers from SharedPreferences
  static Future<List<Organizer>> loadOrganizers() async {
    final prefs = await _preferences;
    final jsonStr = prefs.getString(AppConstants.keyOrganizers);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => Organizer.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Organizers to SharedPreferences
  static Future<void> saveOrganizers(List<Organizer> organizers) async {
    final prefs = await _preferences;
    final list = organizers.map((o) => o.toMap()).toList();
    await prefs.setString(AppConstants.keyOrganizers, jsonEncode(list));
  }

  // Load Certificates from SharedPreferences
  static Future<List<Certificate>> loadCertificates() async {
    final prefs = await _preferences;
    final jsonStr = prefs.getString(AppConstants.keyCertificates);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => Certificate.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Certificates to SharedPreferences
  static Future<void> saveCertificates(List<Certificate> certificates) async {
    final prefs = await _preferences;
    final list = certificates.map((c) => c.toMap()).toList();
    await prefs.setString(AppConstants.keyCertificates, jsonEncode(list));
  }

  // Seed Initial Dummy Data
  static Future<void> seedInitialData() async {
    final prefs = await _preferences;
    
    // 1. Initial Organizers
    final orgDicoding = Organizer(
      id: 'org-dicoding-01',
      name: 'Dicoding Indonesia',
      createdAt: DateTime(2025, 1, 10),
    );
    final orgPolibatam = Organizer(
      id: 'org-polibatam-02',
      name: 'Politeknik Negeri Batam',
      createdAt: DateTime(2025, 1, 15),
    );
    final orgBinar = Organizer(
      id: 'org-binar-03',
      name: 'Binar Academy',
      createdAt: DateTime(2025, 2, 1),
    );
    final orgHima = Organizer(
      id: 'org-hima-04',
      name: 'Himpunan Mahasiswa',
      createdAt: DateTime(2025, 3, 10),
    );

    final initialOrganizers = [orgDicoding, orgPolibatam, orgBinar, orgHima];
    await saveOrganizers(initialOrganizers);

    // 2. Copy sample files to internal storage
    final pathFlutter = await copyAssetToInternalStorage(
      'assets/dummy/flutter_workshop.pdf',
      'sample_flutter_workshop.pdf',
    );
    final pathComp = await copyAssetToInternalStorage(
      'assets/dummy/national_programming_competition.jpg',
      'sample_competition.jpg',
    );
    final pathUiux = await copyAssetToInternalStorage(
      'assets/dummy/uiux_design_webinar.png',
      'sample_uiux.png',
    );
    final pathPython = await copyAssetToInternalStorage(
      'assets/dummy/basic_python.pdf',
      'sample_basic_python.pdf',
    );
    final pathHima = await copyAssetToInternalStorage(
      'assets/dummy/student_leadership.jpg',
      'sample_leadership.jpg',
    );
    final pathSeminar = await copyAssetToInternalStorage(
      'assets/dummy/national_seminar.pdf',
      'sample_national_seminar.pdf',
    );

    // 3. Initial Certificates (from PDF Section 9 & 15)
    final initialCertificates = [
      Certificate(
        id: 'cert-001',
        title: 'Flutter Development Workshop',
        category: 'Workshop',
        organizerId: orgDicoding.id,
        issueDate: DateTime(2026, 1, 15),
        filePath: pathFlutter,
        fileType: 'pdf',
        certificateNumber: 'DICODING-2026-FLT-8921',
        description: 'Pelatihan intensif pengembangan aplikasi Flutter dan Dart lintas platform tingkat lanjut.',
        isFavorite: true,
      ),
      Certificate(
        id: 'cert-002',
        title: 'National Programming Competition',
        category: 'Competition',
        organizerId: orgPolibatam.id,
        issueDate: DateTime(2025, 11, 20),
        filePath: pathComp,
        fileType: 'image',
        certificateNumber: 'POLIBATAM-NPC-2025-042',
        description: 'Juara 2 Lomba Pemrograman Nasional kategori Mobile Apps Development tingkat mahasiswa.',
        isFavorite: true,
      ),
      Certificate(
        id: 'cert-003',
        title: 'UI/UX Design Webinar',
        category: 'Webinar',
        organizerId: orgBinar.id,
        issueDate: DateTime(2026, 2, 5),
        filePath: pathUiux,
        fileType: 'image',
        certificateNumber: 'BINAR-UIUX-2026-7819',
        description: 'Webinar prinsip desain antarmuka, design thinking, dan usability testing aplikasi modern.',
        isFavorite: false,
      ),
      Certificate(
        id: 'cert-004',
        title: 'Basic Python Programming',
        category: 'Certification',
        organizerId: orgDicoding.id,
        issueDate: DateTime(2025, 8, 12),
        filePath: pathPython,
        fileType: 'pdf',
        certificateNumber: 'DICODING-PY-2025-3312',
        description: 'Sertifikasi kompetensi pemrograman dasar Python untuk data science dan otomatisasi.',
        isFavorite: false,
      ),
      Certificate(
        id: 'cert-005',
        title: 'Student Leadership Training',
        category: 'Organization',
        organizerId: orgHima.id,
        issueDate: DateTime(2025, 9, 18),
        filePath: pathHima,
        fileType: 'image',
        certificateNumber: 'HIMA-LKMM-2025-103',
        description: 'Latihan Keterampilan Manajemen Mahasiswa (LKMM) tingkat madya pengelolaan organisasi kampus.',
        isFavorite: true,
      ),
      Certificate(
        id: 'cert-006',
        title: 'National Seminar on Technology',
        category: 'Academic',
        organizerId: orgPolibatam.id,
        issueDate: DateTime(2026, 1, 10),
        filePath: pathSeminar,
        fileType: 'pdf',
        certificateNumber: 'POLIBATAM-SEM-2026-550',
        description: 'Seminar nasional integrasi kecerdasan buatan, cloud computing, dan komputasi bergerak masa depan.',
        isFavorite: false,
      ),
    ];

    await saveCertificates(initialCertificates);
    await prefs.setBool(AppConstants.keyIsInitialized, true);
  }

  // Auth session helpers
  static Future<bool> isUserLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyUserLoggedIn) ?? false;
  }

  static Future<void> setUserLoggedIn(
    bool loggedIn, {
    String? name,
    String? email,
    String? nim,
    String? institution,
  }) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.keyUserLoggedIn, loggedIn);
    if (name != null) await prefs.setString(AppConstants.keyUserName, name);
    if (email != null) await prefs.setString(AppConstants.keyUserEmail, email);
    if (nim != null) await prefs.setString(AppConstants.keyUserNim, nim);
    if (institution != null) await prefs.setString(AppConstants.keyUserInstitution, institution);
  }

  static Future<String> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keyUserName) ?? AppConstants.defaultName;
  }

  static Future<String> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keyUserEmail) ?? AppConstants.defaultEmail;
  }

  static Future<String> getUserNim() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keyUserNim) ?? AppConstants.defaultNim;
  }

  static Future<String> getUserInstitution() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.keyUserInstitution) ?? AppConstants.defaultInstitution;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
}
