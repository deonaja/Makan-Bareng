import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 44,
    this.backgroundColor,
    this.showBorder = false,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get _avatarColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.secondaryLight,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? _avatarColor,
            (backgroundColor ?? _avatarColor).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? _avatarColor).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  photoUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    _initials,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : Text(
                _initials,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
