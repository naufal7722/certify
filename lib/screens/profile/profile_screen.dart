import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/dialog_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../onboarding/login_screen.dart';
import '../organizers/organizers_screen.dart';
import '../statistics/statistics_timeline_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleResetDemo(BuildContext context) async {
    final confirmed = await DialogUtils.showConfirmDialog(
      context,
      title: 'Pulihkan Katalog Sertifikat?',
      message: 'Tindakan ini akan menyinkronkan kembali katalog dan mengembalikan sertifikat standar.',
      confirmLabel: 'Pulihkan',
      cancelLabel: 'Batal',
      isDestructive: false,
    );

    if (confirmed && context.mounted) {
      final certProvider = context.read<CertificateProvider>();
      final orgProvider = context.read<OrganizerProvider>();
      await certProvider.resetToDummyData(orgProvider);

      if (context.mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Katalog sertifikat berhasil dipulihkan',
          isSuccess: true,
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Tentang Certify'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Certify — Personal Certificate & Achievement Manager',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi profesional untuk menyimpan, mengarsipkan, dan mengelola portofolio sertifikat pencapaian pribadi secara terstruktur dan aman di perangkat lokal.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Informasi Aplikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
            ),
            SizedBox(height: 6),
            Text('• Versi: 1.0.0 (Official Build)', style: TextStyle(fontSize: 12)),
            Text('• Format Berkas: PDF, JPG, PNG', style: TextStyle(fontSize: 12)),
            Text('• Penyimpanan: Dokumen Lokal Terenkripsi', style: TextStyle(fontSize: 12)),
            Text('• Lisensi: Hak Cipta Dilindungi', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await DialogUtils.showConfirmDialog(
      context,
      title: 'Keluar dari Akun?',
      message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      confirmLabel: 'Keluar',
      cancelLabel: 'Batal',
      isDestructive: false,
    );

    if (confirmed && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // 1. Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/default_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.userEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NIM: ${auth.userNim} • ${auth.institution}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Navigation & Feature Shortcuts
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.corporate_fare_rounded, color: AppColors.info, size: 20),
                    ),
                    title: const Text('Kelola Penyelenggara', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${orgProvider.organizers.length} Penyelenggara tersimpan', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrganizersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: const Text('Statistik & Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${certProvider.certificates.length} Total sertifikat', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatisticsTimelineScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. System & Catalog Options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: const Text('Pulihkan Katalog Standar', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Sinkronkan kembali sertifikat dan penyelenggara bawaan', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    onTap: () => _handleResetDemo(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF8FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF3182CE), size: 20),
                    ),
                    title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Versi 1.0.0 (Official Build)', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Logout Button Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                ),
                title: const Text(
                  'Keluar dari Aplikasi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                onTap: () => _handleLogout(context),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
