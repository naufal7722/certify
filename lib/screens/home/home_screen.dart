import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
import '../certificates/add_edit_certificate_screen.dart';
import '../certificates/certificate_detail_screen.dart';
import '../certificates/certificates_screen.dart';
import '../organizers/organizers_screen.dart';
import '../statistics/statistics_timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    final totalCerts = certProvider.certificates.length;
    final totalFavs = certProvider.favoriteCertificates.length;
    final totalOrgs = orgProvider.organizers.length;
    final totalCats = certProvider.getCategoryDistribution().keys.length;
    final recentCerts = certProvider.recentCertificates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Halo, ${auth.userName} 👋',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            tooltip: 'Statistik & Timeline',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsTimelineScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.corporate_fare_rounded, color: AppColors.primary),
            tooltip: 'Kelola Penyelenggara',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrganizersScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await certProvider.loadCertificates();
          await orgProvider.loadOrganizers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8F7FF0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Portofolio Digital',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pencapaian & Sertifikatmu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simpan bukti akademik, webinar, dan sertifikasi lokal di perangkat secara terstruktur.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditCertificateScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Tambah Sertifikat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overview Section
              const Text(
                'Ringkasan Portofolio',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Grid of Stat Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        title: 'Total Sertifikat',
                        value: '$totalCerts',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.primary,
                        onTap: () {
                          // Navigate to Certificates tab
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Favorit',
                        value: '$totalFavs',
                        icon: Icons.favorite_rounded,
                        color: AppColors.favorite,
                        onTap: () {
                          // Filter to favorite
                        },
                      ),
                      StatCard(
                        title: 'Penyelenggara',
                        value: '$totalOrgs',
                        icon: Icons.corporate_fare_rounded,
                        color: AppColors.info,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const OrganizersScreen()),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Kategori Aktif',
                        value: '$totalCats',
                        icon: Icons.category_rounded,
                        color: AppColors.success,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const StatisticsTimelineScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // Quick Actions Bar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StatisticsTimelineScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      icon: const Icon(Icons.show_chart_rounded, size: 18),
                      label: const Text(
                        'Timeline & Grafik',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrganizersScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      icon: const Icon(Icons.corporate_fare_rounded, size: 18),
                      label: const Text(
                        'Penyelenggara',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Recent Certificates Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Sertifikat Terbaru',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Certificates List
              if (recentCerts.isEmpty)
                EmptyState(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Belum Ada Sertifikat',
                  message: 'Mulai bangun portofoliomu dengan menambahkan sertifikat pertamamu.',
                  buttonText: 'Tambah Sertifikat Sekarang',
                  onButtonPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddEditCertificateScreen(),
                      ),
                    );
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentCerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final cert = recentCerts[index];
                    return CertificateCard(
                      certificate: cert,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CertificateDetailScreen(certificateId: cert.id),
                          ),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
