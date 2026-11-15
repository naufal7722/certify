import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/dialog_utils.dart';
import '../core/utils/file_utils.dart';
import '../models/certificate.dart';
import '../services/share_service.dart';

class DocumentPreviewWidget extends StatelessWidget {
  final Certificate certificate;
  final String organizerName;

  const DocumentPreviewWidget({
    super.key,
    required this.certificate,
    required this.organizerName,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = certificate.fileType == 'pdf';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isPdf ? const Color(0xFFFFF5F5) : const Color(0xFFF7FAFC),
            child: Row(
              children: [
                Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                  color: isPdf ? AppColors.danger : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPdf ? 'Dokumen Digital (PDF)' : 'Dokumen Gambar (JPG/PNG)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPdf ? AppColors.danger : AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  tooltip: 'Bagikan Dokumen',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () async {
                    try {
                      await ShareService.shareCertificate(
                        certificate,
                        organizerName: organizerName,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        DialogUtils.showSnackBar(
                          context,
                          message: 'Gagal membagikan: $e',
                          isError: true,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Main Preview Box
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320, minHeight: 200),
            child: isPdf
                ? _buildPdfPreviewCanvas(context)
                : _buildInteractiveImagePreview(context),
          ),

          // Action Toolbar below preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFD),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openExternalDocument(context),
                    icon: Icon(
                      isPdf ? Icons.launch_rounded : Icons.zoom_in_rounded,
                      size: 18,
                    ),
                    label: Text(isPdf ? 'Buka PDF Eksternal' : 'Perbesar Gambar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveImagePreview(BuildContext context) {
    final path = certificate.filePath;
    Widget imgWidget;

    if (path.startsWith('assets/')) {
      imgWidget = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFileUnavailableWidget(),
      );
    } else {
      final file = File(path);
      if (!file.existsSync()) {
        imgWidget = _buildFileUnavailableWidget();
      } else {
        imgWidget = Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFileUnavailableWidget(),
        );
      }
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: InteractiveViewer(
        maxScale: 3.0,
        child: Container(
          color: const Color(0xFFF9F9FB),
          width: double.infinity,
          alignment: Alignment.center,
          child: imgWidget,
        ),
      ),
    );
  }

  Widget _buildPdfPreviewCanvas(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFFAFAFA),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 44,
                color: Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              certificate.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Penyelenggara: $organizerName',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Terbit: ${DateFormatter.formatFull(certificate.issueDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B6CB0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUnavailableWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Dokumen tidak dapat dimuat atau path telah dipindahkan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalDocument(BuildContext context) async {
    final path = certificate.filePath;
    try {
      if (path.startsWith('assets/')) {
        // If asset, show preview info or open full image
        if (!FileUtils.isPdf(path)) {
          _showFullScreenImage(context);
          return;
        }
        DialogUtils.showSnackBar(
          context,
          message: 'Menampilkan dokumen sertifikat digital.',
          isSuccess: true,
        );
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        if (context.mounted) {
          DialogUtils.showSnackBar(
            context,
            message: 'File fisik tidak ditemukan pada perangkat: $path',
            isError: true,
          );
        }
        return;
      }

      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          DialogUtils.showSnackBar(
            context,
            message: 'Tidak dapat membuka file: ${result.message}',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Terjadi kesalahan saat membuka file: $e',
          isError: true,
        );
      }
    }
  }

  void _showFullScreenImage(BuildContext context) {
    final path = certificate.filePath;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: path.startsWith('assets/')
                    ? Image.asset(path)
                    : Image.file(File(path)),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
