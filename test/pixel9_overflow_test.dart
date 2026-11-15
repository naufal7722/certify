import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:certify/core/theme/app_theme.dart';
import 'package:certify/models/certificate.dart';
import 'package:certify/providers/auth_provider.dart';
import 'package:certify/providers/certificate_provider.dart';
import 'package:certify/providers/organizer_provider.dart';
import 'package:certify/screens/home/home_screen.dart';
import 'package:certify/screens/organizers/organizers_screen.dart';
import 'package:certify/screens/certificates/certificates_screen.dart';
import 'package:certify/screens/certificates/certificate_detail_screen.dart';
import 'package:certify/screens/certificates/add_edit_certificate_screen.dart';
import 'package:certify/screens/statistics/statistics_timeline_screen.dart';
import 'package:certify/screens/profile/profile_screen.dart';
import 'package:certify/screens/favorites/favorites_screen.dart';
import 'package:certify/screens/onboarding/login_screen.dart';
import 'package:certify/screens/main_navigation_screen.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      throw details.exception;
    };
  });

  Widget buildTestApp(Widget home, AuthProvider auth, OrganizerProvider org, CertificateProvider cert) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: org),
        ChangeNotifierProvider.value(value: cert),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: home,
      ),
    );
  }

  final testCert = Certificate(
    id: 'cert-test-detail',
    title: 'Workshop Pengenalan Flutter & Dart Tingkat Lanjut',
    category: 'Workshop & Pelatihan',
    organizerId: 'org-1',
    issueDate: DateTime(2026, 3, 20),
    filePath: 'assets/dummy/flutter_workshop.pdf',
    fileType: 'pdf',
    certificateNumber: 'CERT-2026-FLT-0987123',
    description: 'Sertifikat pelatihan intensif pengembangan aplikasi mobile lintas platform.',
  );

  testWidgets('Test all screens on Pixel 9 (412x915)', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final auth = AuthProvider();
    final org = OrganizerProvider();
    final cert = CertificateProvider();
    cert.addCertificate(testCert);

    final screens = [
      const HomeScreen(),
      const OrganizersScreen(),
      const CertificatesScreen(),
      CertificateDetailScreen(certificateId: testCert.id),
      const AddEditCertificateScreen(),
      const FavoritesScreen(),
      const LoginScreen(),
      const MainNavigationScreen(),
      const StatisticsTimelineScreen(),
      const ProfileScreen(),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(buildTestApp(screen, auth, org, cert));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Test all screens on smaller screen (360x740)', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final auth = AuthProvider();
    final org = OrganizerProvider();
    final cert = CertificateProvider();
    cert.addCertificate(testCert);

    final screens = [
      const HomeScreen(),
      const OrganizersScreen(),
      const CertificatesScreen(),
      CertificateDetailScreen(certificateId: testCert.id),
      const AddEditCertificateScreen(),
      const FavoritesScreen(),
      const LoginScreen(),
      const MainNavigationScreen(),
      const StatisticsTimelineScreen(),
      const ProfileScreen(),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(buildTestApp(screen, auth, org, cert));
      await tester.pumpAndSettle();
    }
  });
}
