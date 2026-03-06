import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/models/enums.dart';
import 'package:app/shared/widgets/glass_card.dart';
import 'package:app/shared/widgets/score_ring_widget.dart';
import 'package:app/shared/widgets/focus_block_card.dart';
import 'package:app/shared/widgets/task_grid_card.dart';
import 'package:app/shared/widgets/stop_doing_banner.dart';
import 'package:app/shared/widgets/motivation_banner.dart';
import 'package:app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/insights/presentation/providers/insight_provider.dart';
import 'package:app/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:app/shared/widgets/task_list_tile.dart';
import 'package:app/features/dashboard/presentation/widgets/focused_session_card.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

/// Dashboard screen — Stitch mobile dashboard mapped to Flutter.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, TaskProvider>(
      builder: (context, dashboard, taskProvider, _) {
        final config = dashboard.layoutConfig;
        final priorityTask = taskProvider.getPriorityTask(EnergyLevel.medium);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildScoreCard(context, dashboard),
              ),
            ),
            if (config.showMotivationBanner && config.motivationMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: MotivationBanner(message: config.motivationMessage!),
                ),
              ),
            if (_hasFocusedProject(taskProvider))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: FocusedSessionCard(
                    task: _getFocusedProject(taskProvider)!,
                    onTap: () {
                      final task = _getFocusedProject(taskProvider)!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (config.highlightPrimaryTask &&
                priorityTask != null &&
                !_hasFocusedProject(taskProvider))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        'Do This Now',
                        icon: Icons.local_fire_department,
                        iconColor: AppColors.accentOrange,
                        badge: 'AI PRIORITY',
                      ),
                      const SizedBox(height: 12),
                      FocusBlockCard(
                        taskTitle: priorityTask.title,
                        subtitle: 'Deep work session: High focus required',
                        impact: priorityTask.isHighImpact ? 'HIGH' : 'MEDIUM',
                        timeEstimate: '${priorityTask.estimatedMinutes} min',
                        energyNote: 'Peak Energy Window',
                        onStart: () {},
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TaskGridCard(
                        title: 'Deep Work Block',
                        subtitle: 'Next: 2:00 PM - 4:00 PM',
                        icon: Icons.psychology,
                        isDark: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (config.showLowEnergyTasks)
                      Expanded(
                        child: TaskGridCard(
                          title: 'Low Energy Tasks',
                          subtitle: 'Inbox Zero, File Sorting',
                          icon: Icons.battery_1_bar,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      "Today's Roadmap",
                      icon: Icons.calendar_today,
                      iconColor: AppColors.accentBlue,
                    ),
                    const SizedBox(height: 12),
                    if (taskProvider.todayTasks.isEmpty)
                      GlassCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No tasks scheduled for today.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: taskProvider.todayTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = taskProvider.todayTasks[index];
                          return TaskListTile(
                            title: task.title,
                            domain: task.domain.label,
                            impact: task.impactScore.toInt().toString(),
                            isCompleted: task.isCompleted,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TaskDetailScreen(task: task),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (config.showStopDoingPanel)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Consumer<InsightProvider>(
                    builder: (context, insightProvider, _) {
                      final stopDoing = insightProvider.stopDoingInsights;
                      if (stopDoing.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return StopDoingBanner(
                        title: 'Stop Doing: ${stopDoing.first.title}',
                        description: stopDoing.first.description,
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance OS',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                  Text(
                    dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
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

  Widget _buildScoreCard(BuildContext context, DashboardProvider dashboard) {
    return GlassCard(
      child: Row(
        children: [
          ScoreRingWidget(score: dashboard.overallScore, label: 'Score'),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Trajectory',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ScoreMetric(
                      value: '${dashboard.productivityScore.toInt()}%',
                      label: 'Prod.',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _ScoreMetric(
                      value: '${dashboard.growthScore.toInt()}%',
                      label: 'Growth',
                      color: AppColors.accentGreen,
                    ),
                    _ScoreMetric(
                      value: '${dashboard.healthScore.toInt()}%',
                      label: 'Health',
                      color: AppColors.accentOrange,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    IconData? icon,
    Color? iconColor,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
          ],
          Text(title, style: AppTextStyles.heading4.copyWith(fontSize: 16)),
          const Spacer(),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasFocusedProject(TaskProvider provider) {
    return provider.tasks.any(
      (t) => t.isProject && t.domain == TaskDomain.work && !t.isCompleted,
    );
  }

  TaskEntity? _getFocusedProject(TaskProvider provider) {
    final projects =
        provider.tasks
            .where(
              (t) =>
                  t.isProject && t.domain == TaskDomain.work && !t.isCompleted,
            )
            .toList();
    return projects.isNotEmpty ? projects.first : null;
  }
}

class _ScoreMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _ScoreMetric({
    required this.value,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(color: color, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
