import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/empty_state.dart';
import '../certificates/certificate_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    final favorites = certProvider.favoriteCertificates.where((cert) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final org = orgProvider.getOrganizerName(cert.organizerId).toLowerCase();
      return cert.title.toLowerCase().contains(q) || org.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sertifikat Favorit'),
      ),
      body: Column(
        children: [
          // Search Bar
          if (certProvider.favoriteCertificates.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari di favorit...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),

          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: favorites.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'Belum Ada Favorit',
                    message: _searchQuery.isNotEmpty
                        ? 'Tidak ada sertifikat favorit dengan kata kunci "$_searchQuery".'
                        : 'Tandai sertifikat penting dengan ikon hati agar mudah diakses kembali di sini.',
                    buttonText: _searchQuery.isNotEmpty ? 'Bersihkan Pencarian' : null,
                    onButtonPressed: _searchQuery.isNotEmpty
                        ? () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          }
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final cert = favorites[index];
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
          ),
        ],
      ),
    );
  }
}
