import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../certificates/certificate_detail_screen.dart';

class StatisticsTimelineScreen extends StatefulWidget {
  const StatisticsTimelineScreen({super.key});

  @override
  State<StatisticsTimelineScreen> createState() => _StatisticsTimelineScreenState();
}

class _StatisticsTimelineScreenState extends State<StatisticsTimelineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik & Timeline'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Statistik & Grafik'),
            Tab(icon: Icon(Icons.timeline_rounded), text: 'Timeline Pencapaian'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StatisticsTab(),
          _TimelineTab(),
        ],
      ),
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    final totalCerts = certProvider.certificates.length;
    final totalFavs = certProvider.favoriteCertificates.length;
    final catDist = certProvider.getCategoryDistribution();
    final yearDist = certProvider.getYearDistribution();
    final orgDist = certProvider.getOrganizerDistribution();

    if (totalCerts == 0) {
      return const Center(
        child: Text('Belum ada data sertifikat untuk dianalisis.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview Metric Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricColumn('Total Portofolio', '$totalCerts', Icons.workspace_premium, AppColors.primary),
                ),
                Container(height: 36, width: 1, color: AppColors.border),
                Expanded(
                  child: _buildMetricColumn('Favorit', '$totalFavs', Icons.favorite, AppColors.favorite),
                ),
                Container(height: 36, width: 1, color: AppColors.border),
                Expanded(
                  child: _buildMetricColumn('Penyelenggara', '${orgProvider.organizers.length}', Icons.apartment, AppColors.info),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Bar Chart: Sertifikat per Tahun (PDF Section 8)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pencapaian Berdasarkan Tahun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Grafik perbandingan jumlah sertifikat tiap tahun penerbitan',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  _buildYearBarChart(yearDist),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Category Breakdown Bars
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Distribusi Kategori',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...catDist.entries.map((entry) {
                    final percentage = totalCerts > 0 ? (entry.value / totalCerts) : 0.0;
                    final color = AppColors.getCategoryColor(entry.key);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value} sertifikat (${(percentage * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Top Organizers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.corporate_fare_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sertifikat Berdasarkan Penyelenggara',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...orgDist.entries.map((entry) {
                    final orgName = orgProvider.getOrganizerName(entry.key);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business_center_outlined, color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        orgName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${entry.value} Sertifikat',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildYearBarChart(Map<int, int> yearDist) {
    if (yearDist.isEmpty) return const SizedBox.shrink();

    final sortedYears = yearDist.keys.toList()..sort();
    final maxCount = yearDist.values.fold<int>(1, (prev, val) => max(prev, val));

    return SizedBox(
      height: 160,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barAreaWidth = max(constraints.maxWidth, sortedYears.length * 56.0);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: barAreaWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: sortedYears.map((year) {
                  final count = yearDist[year] ?? 0;
                  final barHeight = (count / maxCount) * 110;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 38,
                        height: max(barHeight, 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF9E8EFF)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$year',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();
    final timelineItems = certProvider.timelineCertificates;

    if (timelineItems.isEmpty) {
      return const Center(child: Text('Belum ada sertifikat di timeline.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: timelineItems.length,
      itemBuilder: (ctx, index) {
        final cert = timelineItems[index];
        final orgName = orgProvider.getOrganizerName(cert.organizerId);
        final isLast = index == timelineItems.length - 1;
        final catColor = AppColors.getCategoryColor(cert.category);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node Line
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: catColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Timeline Content Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CertificateDetailScreen(certificateId: cert.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCategoryLightColor(cert.category),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    cert.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: catColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatShort(cert.issueDate),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cert.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orgName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
