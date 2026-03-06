import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';

/// Bottom navigation bar matching Stitch UI's mobile navigation.
///
/// 5 items: Dashboard, Add Task, AI (center FAB), Reflection, Insights
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                primary: primary,
              ),
              _NavItem(
                icon: Icons.checklist,
                label: 'My Tasks',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                primary: primary,
              ),
              // Center FAB
              GestureDetector(
                onTap: () => onTap(2),
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: bg, width: 4),
                    ),
                    child: const Icon(
                      Icons.flare,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.self_improvement,
                label: 'Reflection',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                primary: primary,
              ),
              _NavItem(
                icon: Icons.analytics,
                label: 'Insights',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
                primary: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color primary;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primary : AppColors.textTertiary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? primary : AppColors.textTertiary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
