import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/certificate.dart';
import '../providers/certificate_provider.dart';
import '../providers/organizer_provider.dart';

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;
  final bool isGrid;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final orgProvider = Provider.of<OrganizerProvider>(context, listen: false);
    final organizerName = orgProvider.getOrganizerName(certificate.organizerId);
    final catColor = AppColors.getCategoryColor(certificate.category);
    final isPdf = certificate.fileType == 'pdf';

    if (isGrid) {
      return _buildGridCard(context, organizerName, catColor, isPdf);
    }

    return _buildListCard(context, organizerName, catColor, isPdf);
  }

  Widget _buildListCard(
    BuildContext context,
    String organizerName,
    Color catColor,
    bool isPdf,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Document Thumbnail
              _buildThumbnail(isPdf, 70, 70),
              const SizedBox(width: 14),

              // Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.getCategoryLightColor(certificate.category),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              certificate.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: catColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatShort(certificate.issueDate),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      certificate.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Organizer
                    Row(
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            organizerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Favorite toggle button
              IconButton(
                onPressed: () {
                  context.read<CertificateProvider>().toggleFavorite(certificate.id);
                },
                icon: Icon(
                  certificate.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: certificate.isFavorite ? AppColors.favorite : AppColors.textMuted,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String organizerName,
    Color catColor,
    bool isPdf,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Banner
            Stack(
              children: [
                _buildThumbnail(isPdf, double.infinity, 100),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.read<CertificateProvider>().toggleFavorite(certificate.id);
                      },
                      icon: Icon(
                        certificate.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: certificate.isFavorite ? AppColors.favorite : AppColors.textMuted,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.getCategoryLightColor(certificate.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      certificate.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: catColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    certificate.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    organizerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isPdf, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        color: isPdf ? const Color(0xFFFFF2F2) : const Color(0xFFF0F4FF),
        child: isPdf
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFE53E3E),
                    size: 32,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePreview() {
    final path = certificate.filePath;
    if (path.isEmpty) {
      return const Icon(Icons.image_outlined, color: AppColors.primary, size: 28);
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
      );
    }

    final file = File(path);
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
    );
  }
}
