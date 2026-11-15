import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/certificate.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_certificate_screen.dart';
import 'certificate_detail_screen.dart';

class CertificatesScreen extends StatefulWidget {
  final String? initialOrganizerId;

  const CertificatesScreen({super.key, this.initialOrganizerId});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final _searchController = TextEditingController();
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final certProvider = context.read<CertificateProvider>();
      if (widget.initialOrganizerId != null) {
        certProvider.setSelectedOrganizerId(widget.initialOrganizerId);
      }
      _searchController.text = certProvider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer2<CertificateProvider, OrganizerProvider>(
          builder: (context, certProvider, orgProvider, _) {
            final years = certProvider.availableYears;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Sertifikat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          certProvider.resetFilters();
                          _searchController.clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // 1. Category Filter
                  const Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: certProvider.selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                      ...AppConstants.categories.map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      ),
                    ],
                    onChanged: (val) {
                      certProvider.setSelectedCategory(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Organizer Filter
                  const Text(
                    'Penyelenggara',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: certProvider.selectedOrganizerId,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Penyelenggara')),
                      ...orgProvider.organizers.map(
                        (org) => DropdownMenuItem(value: org.id, child: Text(org.name)),
                      ),
                    ],
                    onChanged: (val) {
                      certProvider.setSelectedOrganizerId(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Year Filter
                  if (years.isNotEmpty) ...[
                    const Text(
                      'Tahun Penerbitan',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: certProvider.selectedYear,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Tahun')),
                        ...years.map(
                          (yr) => DropdownMenuItem(value: yr, child: Text('$yr')),
                        ),
                      ],
                      onChanged: (val) {
                        certProvider.setSelectedYear(val);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    final certProvider = context.read<CertificateProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _buildSortOption(ctx, certProvider, 'Terbaru (Tanggal Terbit)', 'newest'),
              _buildSortOption(ctx, certProvider, 'Terlama (Tanggal Terbit)', 'oldest'),
              _buildSortOption(ctx, certProvider, 'Judul (A ke Z)', 'a-z'),
              _buildSortOption(ctx, certProvider, 'Judul (Z ke A)', 'z-a'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext ctx,
    CertificateProvider provider,
    String label,
    String value,
  ) {
    final isSelected = provider.sortBy == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.primary : AppColors.textMuted,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        provider.setSortBy(value);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    final filteredList = certProvider.getFilteredCertificates(orgProvider);
    final activeFilters = certProvider.activeFiltersCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Sertifikat'),
        actions: [
          // Grid / List View Toggle
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: _isGrid ? 'Tampilan List' : 'Tampilan Grid',
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Urutkan',
            onPressed: () => _showSortModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // Search Input
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => certProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penyelenggara...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                certProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Filter Button with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => _showFilterModal(context),
                      icon: const Icon(Icons.tune_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: activeFilters > 0 ? AppColors.primaryLight : AppColors.background,
                        foregroundColor: activeFilters > 0 ? AppColors.primary : AppColors.textPrimary,
                      ),
                      tooltip: 'Filter Lanjutan',
                    ),
                    if (activeFilters > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$activeFilters',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Active filter chip row (if any)
          if (activeFilters > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFBFBFE),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '$activeFilters Filter Aktif',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      certProvider.resetFilters();
                      _searchController.clear();
                    },
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: AppColors.border),

          // Certificate list / grid content
          Expanded(
            child: filteredList.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak Ada Sertifikat Ditemukan',
                    message: activeFilters > 0 || _searchController.text.isNotEmpty
                        ? 'Coba ubah kata kunci atau bersihkan filter pencarian.'
                        : 'Belum ada data sertifikat yang tersimpan.',
                    buttonText: activeFilters > 0 || _searchController.text.isNotEmpty
                        ? 'Reset Pencarian'
                        : 'Tambah Sertifikat',
                    onButtonPressed: () {
                      if (activeFilters > 0 || _searchController.text.isNotEmpty) {
                        certProvider.resetFilters();
                        _searchController.clear();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditCertificateScreen(),
                          ),
                        );
                      }
                    },
                  )
                : _isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.76,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (ctx, index) {
                          final cert = filteredList[index];
                          return CertificateCard(
                            certificate: cert,
                            isGrid: true,
                            onTap: () => _openDetail(cert),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final cert = filteredList[index];
                          return CertificateCard(
                            certificate: cert,
                            isGrid: false,
                            onTap: () => _openDetail(cert),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Certificate cert) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificateDetailScreen(certificateId: cert.id),
      ),
    );
  }
}
