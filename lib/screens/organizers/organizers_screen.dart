import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_utils.dart';
import '../../models/organizer.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../certificates/certificates_screen.dart';

class OrganizersScreen extends StatefulWidget {
  const OrganizersScreen({super.key});

  @override
  State<OrganizersScreen> createState() => _OrganizersScreenState();
}

class _OrganizersScreenState extends State<OrganizersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add dialog
  Future<void> _showAddOrganizerDialog() async {
    final textCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Penyelenggara Baru'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama Penyelenggara',
              hintText: 'Contoh: Politeknik Negeri Batam',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final orgProvider = context.read<OrganizerProvider>();
                await orgProvider.addOrganizer(textCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    DialogUtils.showSnackBar(
                      context,
                      message: 'Penyelenggara berhasil ditambahkan!',
                      isSuccess: true,
                    );
                  }
                }
              } catch (e) {
                if (ctx.mounted) {
                  DialogUtils.showSnackBar(
                    ctx,
                    message: e.toString().replaceAll('Exception: ', ''),
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Edit dialog
  Future<void> _showEditOrganizerDialog(Organizer organizer) async {
    final textCtrl = TextEditingController(text: organizer.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Penyelenggara'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perubahan nama akan otomatis diperbarui pada seluruh sertifikat yang terkait.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: textCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Baru Penyelenggara',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final orgProvider = context.read<OrganizerProvider>();
                await orgProvider.updateOrganizer(organizer.id, textCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    DialogUtils.showSnackBar(
                      context,
                      message: 'Nama penyelenggara berhasil diperbarui!',
                      isSuccess: true,
                    );
                  }
                }
              } catch (e) {
                if (ctx.mounted) {
                  DialogUtils.showSnackBar(
                    ctx,
                    message: e.toString().replaceAll('Exception: ', ''),
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Delete with safety check (Section 6 & 14)
  Future<void> _handleDeleteOrganizer(Organizer organizer, int certCount) async {
    if (certCount > 0) {
      // Prevent deletion because certificates still depend on this organizer
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Tidak Dapat Menghapus'),
            ],
          ),
          content: Text(
            'Penyelenggara "${organizer.name}" masih terhubung dengan $certCount sertifikat.\n\n'
            'Untuk menjaga keutuhan relasi data, harap ubah atau hapus sertifikat terkait terlebih dahulu sebelum menghapus penyelenggara ini.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    // If 0 certificates, confirm deletion
    final confirmed = await DialogUtils.showConfirmDialog(
      context,
      title: 'Hapus Penyelenggara?',
      message: 'Apakah Anda yakin ingin menghapus "${organizer.name}"?',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await context.read<OrganizerProvider>().deleteOrganizer(organizer.id);
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Penyelenggara berhasil dihapus',
          isSuccess: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizerProvider>();
    final certProvider = context.watch<CertificateProvider>();

    final organizers = orgProvider.organizers.where((o) {
      if (_searchQuery.trim().isEmpty) return true;
      return o.name.toLowerCase().contains(_searchQuery.trim().toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Penyelenggara'),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari penyelenggara / instansi...',
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

          // List
          Expanded(
            child: organizers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.corporate_fare_outlined,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada penyelenggara bernama "$_searchQuery"'
                                : 'Belum Ada Penyelenggara',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tambahkan institusi atau penyelenggara baru menggunakan tombol di bawah.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: organizers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final org = organizers[index];
                      final count = certProvider.getCertificateCountByOrganizer(org.id);

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Navigate to Certificates pre-filtered by this organizer
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CertificatesScreen(
                                  initialOrganizerId: org.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.corporate_fare_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        org.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: count > 0
                                                  ? AppColors.primaryLight
                                                  : const Color(0xFFF1F1F4),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$count Sertifikat',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: count > 0
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Dibuat ${DateFormatter.formatShort(org.createdAt)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  color: AppColors.textSecondary,
                                  tooltip: 'Ubah Nama',
                                  onPressed: () => _showEditOrganizerDialog(org),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  color: AppColors.danger,
                                  tooltip: 'Hapus Penyelenggara',
                                  onPressed: () => _handleDeleteOrganizer(org, count),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOrganizerDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Penyelenggara'),
      ),
    );
  }
}
