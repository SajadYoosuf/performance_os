import 'package:app/shared/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/widgets/task_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:app/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

/// Performance Summary / Insights screen — mapped from Stitch performance_summary + web insights.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Consumer<TaskProvider>(
            builder: (context, tp, _) => _buildHeader(context, primary, tp),
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer2<TaskProvider, DashboardProvider>(
            builder: (context, taskProvider, dashboardProvider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSummaryGrid(context, primary, dashboardProvider),
                    const SizedBox(height: 24),
                    _buildAIInsight(context, primary, taskProvider),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(context, primary, dashboardProvider),
                    const SizedBox(height: 24),
                    _buildTopTasks(context, taskProvider),
                  ],
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color primary,
    TaskProvider taskProvider,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance OS',
                    style: AppTextStyles.heading4.copyWith(fontSize: 16),
                  ),
                  Text(
                    'DASHBOARD',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _sharePerformance(taskProvider),
              icon: Icon(Icons.share, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePerformance(TaskProvider tp) {
    final tasks = tp.todayTasks;
    if (tasks.isEmpty) {
      Share.share(
        '🚀 Check out Performance OS! I\'m getting ready to crush my goals today.',
      );
      return;
    }

    final total = tasks.length;
    final workCount = tasks.where((t) => t.domain == TaskDomain.work).length;
    final learningCount =
        tasks.where((t) => t.domain == TaskDomain.learning).length;
    final healthCount =
        tasks.where((t) => t.domain == TaskDomain.health).length;
    final personalCount =
        tasks.where((t) => t.domain == TaskDomain.personal).length;

    final workPercent = (workCount / total * 100).toInt();
    final learningPercent = (learningCount / total * 100).toInt();
    final healthPercent = (healthCount / total * 100).toInt();
    final personalPercent = (personalCount / total * 100).toInt();

    final completed = tp.completedToday.length;
    final progress = (completed / total * 100).toInt();

    final message = '''
📊 My Performance OS Today:
✅ Growth Progress: $progress%

Focus Distribution:
💼 Work: $workPercent%
🎓 Learning: $learningPercent%
🌿 Health: $healthPercent%
👤 Personal: $personalPercent%

#PerformanceOS #Productivity #Optimization
''';

    Share.share(message);
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    Color primary,
    DashboardProvider dashboardProvider,
  ) {
    final score = (dashboardProvider.overallScore * 20).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Executive Summary', style: AppTextStyles.heading3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIVE DATA',
                style: AppTextStyles.labelSmall.copyWith(color: primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 128,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Efficiency Score',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score%',
                          style: AppTextStyles.scoreMedium.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Good',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 128,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Productivity',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dashboardProvider.productivityScore.toStringAsFixed(
                            1,
                          ),
                          style: AppTextStyles.scoreMedium.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          'On Track',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIInsight(
    BuildContext context,
    Color primary,
    TaskProvider taskProvider,
  ) {
    final completedCount = taskProvider.completedToday.length;
    final totalCount = taskProvider.todayTasks.length;
    final progress =
        totalCount > 0 ? (completedCount / totalCount * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: AppColors.accentGreen, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Insight Summary',
                style: AppTextStyles.labelLarge.copyWith(
                  color: const Color(0xFF064E3B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'Today you have completed '),
                TextSpan(
                  text: '$progress%',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      ' of your scheduled missions. ${progress > 50 ? "Excellent momentum!" : "Consider tackling a high-impact task next."}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(
    BuildContext context,
    Color primary,
    DashboardProvider dashboardProvider,
  ) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final scores = dashboardProvider.weeklyScores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKLY OUTPUT TREND',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                // Map days to our 7-day view (simple mapping for demo)
                final scoreIndex = i < scores.length ? i : -1;
                final heightFactor =
                    scoreIndex != -1
                        ? (scores[scoreIndex].overallScore / 100).clamp(
                          0.1,
                          1.0,
                        )
                        : 0.1;
                final isToday = i == (DateTime.now().weekday - 1);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isToday
                                        ? primary
                                        : primary.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: AppTextStyles.labelSmall.copyWith(
                            color:
                                isToday
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopTasks(BuildContext context, TaskProvider taskProvider) {
    final topTasks = List<TaskEntity>.from(taskProvider.tasks)
      ..sort((a, b) => b.impactScore.compareTo(a.impactScore));
    final displayTasks = topTasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP 3 HIGH IMPACT TASKS',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        if (displayTasks.isEmpty)
          Center(
            child: Text(
              'No high impact tasks identified yet.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          )
        else
          ...displayTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskListTile(
                title: task.title,
                domain: task.domain.label,
                impact: task.impactScore.toInt().toString(),
                isCompleted: task.isCompleted,
                onTap: () {
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
      ],
    );
  }
}
