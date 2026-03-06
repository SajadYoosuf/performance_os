import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/shared/widgets/responsive_scaffold.dart';
import 'package:app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:app/features/reflection/presentation/screens/daily_reflection_screen.dart';
import 'package:app/features/insights/presentation/screens/insights_screen.dart';
import 'package:app/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/insights/presentation/providers/insight_provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';

/// Home shell — the main app scaffold that manages navigation.
///
/// On mobile: bottom nav with IndexedStack
/// On desktop: sidebar nav via ResponsiveScaffold
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    DashboardScreen(), // 0
    TaskListScreen(), // 1 — Day/Week/Month task views
    AICoachScreen(), // 2 (center FAB — GenUI-powered)
    DailyReflectionScreen(), // 3
    InsightsScreen(), // 4
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    return ResponsiveScaffold(
      currentNavIndex: _currentIndex,
      onNavTap: (i) => setState(() => _currentIndex = i),
      userName: auth.user?.displayName ?? 'User',
      dailyScore: dashboard.overallScore,
      mobileBody: IndexedStack(index: _currentIndex, children: _pages),
      insightPanel: _buildInsightPanel(context),
    );
  }

  Widget _buildInsightPanel(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final insights = context.watch<InsightProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Strategic Insights',
            style: AppTextStyles.heading3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'AI-powered analysis',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (insights.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...insights.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
