import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_utils.dart';
import '../../core/utils/file_utils.dart';
import '../../models/certificate.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../../services/share_service.dart';
import '../../widgets/document_preview_widget.dart';
import 'add_edit_certificate_screen.dart';
import 'certificates_screen.dart';

class CertificateDetailScreen extends StatefulWidget {
  final String certificateId;

  const CertificateDetailScreen({super.key, required this.certificateId});

  @override
  State<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  int _fileSizeBytes = 0;

  @override
  void initState() {
    super.initState();
    _loadFileSizeBytes();
  }

  Future<void> _loadFileSizeBytes() async {
    final certProvider = context.read<CertificateProvider>();
    final certs = certProvider.certificates.where((c) => c.id == widget.certificateId);
    if (certs.isNotEmpty) {
      final cert = certs.first;
      if (!cert.filePath.startsWith('assets/')) {
        final size = await FileUtils.getFileSizeBytes(cert.filePath);
        if (mounted) setState(() => _fileSizeBytes = size);
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, Certificate cert) async {
    final confirmed = await DialogUtils.showConfirmDialog(
      context,
      title: 'Hapus Sertifikat?',
      message: 'Apakah Anda yakin ingin menghapus "${cert.title}"? Dokumen fisik yang tersimpan juga akan dibersihkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      try {
        await context.read<CertificateProvider>().deleteCertificate(cert.id);
        if (context.mounted) {
          DialogUtils.showSnackBar(
            context,
            message: 'Sertifikat berhasil dihapus',
            isSuccess: true,
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          DialogUtils.showSnackBar(
            context,
            message: 'Gagal menghapus: $e',
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _handleShare(Certificate cert, String organizerName) async {
    try {
      await ShareService.shareCertificate(cert, organizerName: organizerName);
    } catch (e) {
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Gagal membagikan sertifikat: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final certProvider = context.watch<CertificateProvider>();
    final orgProvider = context.watch<OrganizerProvider>();

    final matches = certProvider.certificates.where((c) => c.id == widget.certificateId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Sertifikat')),
        body: const Center(child: Text('Sertifikat tidak ditemukan')),
      );
    }

    final cert = matches.first;
    final organizerName = orgProvider.getOrganizerName(cert.organizerId);
    final catColor = AppColors.getCategoryColor(cert.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Sertifikat'),
        actions: [
          // Favorite Toggle
          IconButton(
            icon: Icon(
              cert.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: cert.isFavorite ? AppColors.favorite : AppColors.textSecondary,
            ),
            tooltip: cert.isFavorite ? 'Hapus dari Favorit' : 'Tandai Favorit',
            onPressed: () {
              certProvider.toggleFavorite(cert.id);
            },
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bagikan',
            onPressed: () => _handleShare(cert, organizerName),
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah Data',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditCertificateScreen(existingCertificate: cert),
                ),
              );
            },
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            tooltip: 'Hapus Sertifikat',
            onPressed: () => _handleDelete(context, cert),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Large Document Preview Card
            DocumentPreviewWidget(
              certificate: cert,
              organizerName: organizerName,
            ),

            const SizedBox(height: 20),

            // 2. Certificate Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag & Issue Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.getCategoryLightColor(cert.category),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cert.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: catColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatFull(cert.issueDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      cert.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(),
                    const SizedBox(height: 12),

                    // Organizer clickable tile (PDF Section 6: Membuka daftar sertifikat berdasarkan organizer)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CertificatesScreen(
                              initialOrganizerId: cert.organizerId,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Penyelenggara',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    organizerName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Certificate Number (if provided)
                    if (cert.certificateNumber != null && cert.certificateNumber!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor Sertifikat / Kredensial',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  cert.certificateNumber!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Description (if provided)
                    if (cert.description != null && cert.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi / Catatan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cert.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Storage & File Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Penyimpanan File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Tipe Dokumen', cert.fileType.toUpperCase()),
                    _buildInfoRow(
                      'Ukuran Dokumen',
                      _fileSizeBytes > 0 ? FileUtils.formatBytes(_fileSizeBytes) : 'Standar Dokumen',
                    ),
                    _buildInfoRow(
                      'Penyimpanan',
                      cert.filePath.startsWith('assets/')
                          ? 'Asset Bawaan Aplikasi (Dummy)'
                          : 'Penyimpanan Internal Aplikasi',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
