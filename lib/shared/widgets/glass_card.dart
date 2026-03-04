import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

/// Glassmorphism card widget matching Stitch UI's `.glass` class.
///
/// background: rgba(255,255,255,0.7), backdrop-filter: blur(12px),
/// border: 1px solid rgba(255,255,255,0.3)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassWhite,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color:
                  borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.glassBorder),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
