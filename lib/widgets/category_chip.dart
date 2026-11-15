import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showAllOption;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showAllOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.getCategoryColor(category);
    final bgColor = isSelected ? catColor : AppColors.getCategoryLightColor(category);
    final textColor = isSelected ? Colors.white : catColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? catColor : catColor.withOpacity(0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: catColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return Icons.build_circle_outlined;
      case 'competition':
        return Icons.emoji_events_outlined;
      case 'webinar':
        return Icons.video_camera_front_outlined;
      case 'certification':
        return Icons.verified_outlined;
      case 'academic':
        return Icons.school_outlined;
      case 'organization':
        return Icons.groups_outlined;
      case 'semua':
        return Icons.dashboard_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}
