import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/core/agent/agent_decision_engine.dart';
import 'package:app/core/agent/agent_layout_model.dart';
import 'package:app/features/dashboard/domain/entities/daily_score_entity.dart';
import 'package:app/features/dashboard/domain/repositories/daily_score_repository.dart';
import 'package:app/features/dashboard/domain/usecases/calculate_productivity_score.dart';
import 'package:app/features/dashboard/domain/usecases/calculate_growth_score.dart';
import 'package:app/features/dashboard/domain/usecases/calculate_health_score.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/shared/models/enums.dart';

/// Dashboard provider — the central orchestrator.
///
/// Responsibilities:
/// 1. Fetch and watch daily scores
/// 2. Compute scores via use cases
/// 3. Feed data into AgentDecisionEngine
/// 4. Expose AgentLayoutConfig to the UI
class DashboardProvider extends ChangeNotifier {
  final DailyScoreRepository _scoreRepository;
  final CalculateProductivityScore _calcProductivity;
  final CalculateGrowthScore _calcGrowth;
  final CalculateHealthScore _calcHealth;
  final AgentDecisionEngine _agentEngine;

  StreamSubscription<List<DailyScoreEntity>>? _subscription;

  DashboardProvider({
    required DailyScoreRepository scoreRepository,
    CalculateProductivityScore? calcProductivity,
    CalculateGrowthScore? calcGrowth,
    CalculateHealthScore? calcHealth,
    AgentDecisionEngine? agentEngine,
  }) : _scoreRepository = scoreRepository,
       _calcProductivity = calcProductivity ?? CalculateProductivityScore(),
       _calcGrowth = calcGrowth ?? CalculateGrowthScore(),
       _calcHealth = calcHealth ?? CalculateHealthScore(),
       _agentEngine = agentEngine ?? const AgentDecisionEngine();

  // ── State ──
  List<DailyScoreEntity> _weeklyScores = [];
  DailyScoreEntity? _todayScore;
  AgentLayoutConfig _layoutConfig = AgentLayoutConfig.balanced();
  double _productivityScore = 0;
  double _growthScore = 0;
  double _healthScore = 0;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──
  List<DailyScoreEntity> get weeklyScores => _weeklyScores;
  DailyScoreEntity? get todayScore => _todayScore;
  AgentLayoutConfig get layoutConfig => _layoutConfig;
  double get productivityScore => _productivityScore;
  double get growthScore => _growthScore;
  double get healthScore => _healthScore;
  double get overallScore =>
      (_productivityScore + _growthScore + _healthScore) / 3.0;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Start watching dashboard data for a user.
  void watchDashboard(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription = _scoreRepository
        .watchDailyScores(userId, 7)
        .listen(
          (scores) {
            _weeklyScores = scores;
            if (scores.isNotEmpty) {
              _todayScore = scores.first;
              _productivityScore = _todayScore!.productivityScore;
              _growthScore = _todayScore!.growthScore;
              _healthScore = _todayScore!.healthScore;
            }
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Recompute scores from task data and update agent layout.
  void updateFromTasks({
    required List<TaskEntity> completedTasks,
    required List<TaskEntity> allTasks,
    required EnergyLevel currentEnergy,
  }) {
    _productivityScore = _calcProductivity(completedTasks);
    _growthScore = _calcGrowth(completedTasks);
    _healthScore = _calcHealth(completedTasks);

    final overdueTasks = allTasks.where((t) => t.isOverdue).length;
    final pendingHighImpact =
        allTasks.where((t) => t.isHighImpact && !t.isCompleted).length;

    // Count consecutive low-score days
    int consecutiveLow = 0;
    for (final score in _weeklyScores) {
      if (score.overallScore < 40) {
        consecutiveLow++;
      } else {
        break;
      }
    }

    final input = AgentInput(
      productivityScore: _productivityScore,
      growthScore: _growthScore,
      healthScore: _healthScore,
      energyLevel: currentEnergy,
      overdueTasks: overdueTasks,
      pendingHighImpactTasks: pendingHighImpact,
      consecutiveLowScoreDays: consecutiveLow,
    );

    _layoutConfig = _agentEngine.evaluate(input);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Builds a formatted string of the current dashboard state to feed directly to the AI coach.
  String buildDashboardContextForAI() {
    final buf = StringBuffer();
    buf.writeln('User Dashboard Data:');
    buf.writeln(
      '- Overall Score: ${(overallScore * 20).toStringAsFixed(1)}/100',
    );
    buf.writeln('- Productivity: ${productivityScore.toStringAsFixed(1)}/5');
    buf.writeln('- Growth: ${growthScore.toStringAsFixed(1)}/5');
    buf.writeln('- Health: ${healthScore.toStringAsFixed(1)}/5');
    if (_todayScore != null) {
      buf.writeln('- Today\'s Completed Tasks: ${_todayScore!.tasksCompleted}');
      buf.writeln('- Today\'s Deep Work: ${_todayScore!.deepWorkMinutes} mins');
    }
    return buf.toString();
  }
}
