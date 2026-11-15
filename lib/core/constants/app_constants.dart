class AppConstants {
  static const String appName = 'Certify';
  static const String appTagline = 'Personal Certificate & Achievement Manager';
  static const String appSubtagline = 'Your Achievements, Organized in One Place.';
  static const String appVersion = '1.0.0';

  // Standard categories
  static const List<String> categories = [
    'Workshop',
    'Competition',
    'Webinar',
    'Certification',
    'Academic',
    'Organization',
    'Lainnya',
  ];

  // Storage keys for SharedPreferences
  static const String keyCertificates = 'certify_certificates_json';
  static const String keyOrganizers = 'certify_organizers_json';
  static const String keyIsInitialized = 'certify_is_seeded_v1';
  static const String keyUserLoggedIn = 'certify_user_logged_in';
  static const String keyUserName = 'certify_user_name';
  static const String keyUserEmail = 'certify_user_email';
  static const String keyUserNim = 'certify_user_nim';
  static const String keyUserInstitution = 'certify_user_institution';

  // Maximum allowed file size in bytes (10 MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  // Allowed file extensions
  static const List<String> allowedFileExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  // Default user profile
  static const String defaultEmail = 'rafi.pratama@email.com';
  static const String defaultPassword = '123';
  static const String defaultName = 'Rafi Pratama';
  static const String defaultNim = '3312301045';
  static const String defaultInstitution = 'Politeknik Negeri Batam';
}
