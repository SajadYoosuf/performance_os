import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';

/// Sidebar navigation matching Stitch web UI's dark navy sidebar.
class SidebarNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String userName;
  final String? userPlan;
  final double dailyScore;
  final double scoreProgress;
  final VoidCallback? onNewSprint;

  const SidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userName = 'User',
    this.userPlan,
    this.dailyScore = 0,
    this.scoreProgress = 0,
    this.onNewSprint,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 256,
      color: AppColors.navyDark,
      child: Column(
        children: [
          // ── Logo ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance OS',
                  style: AppTextStyles.heading4.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // ── Navigation Items ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _SidebarItem(
                    icon: Icons.bar_chart,
                    label: 'Analytics',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _SidebarItem(
                    icon: Icons.task_alt,
                    label: 'Tasks',
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _SidebarItem(
                    icon: Icons.folder,
                    label: 'Projects',
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _SidebarItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                  const SizedBox(height: 16),
                  // ── Daily Score Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY SCORE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dailyScore.toInt().toString(),
                              style: AppTextStyles.scoreMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: AppColors.accentGreen,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '4%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: scoreProgress / 100.0,
                            backgroundColor: Colors.grey.shade800,
                            color: AppColors.accentGreen,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom Section ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNewSprint,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Sprint'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade800,
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          if (userPlan != null)
                            Text(
                              userPlan!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? primary.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade400,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
