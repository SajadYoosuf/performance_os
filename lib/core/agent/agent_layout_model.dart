import 'package:app/shared/models/enums.dart';

/// Input model for the Agent Decision Engine.
class AgentInput {
  final double productivityScore;
  final double growthScore;
  final double healthScore;
  final EnergyLevel energyLevel;
  final int overdueTasks;
  final int pendingHighImpactTasks;
  final int consecutiveLowScoreDays;

  const AgentInput({
    required this.productivityScore,
    required this.growthScore,
    required this.healthScore,
    required this.energyLevel,
    this.overdueTasks = 0,
    this.pendingHighImpactTasks = 0,
    this.consecutiveLowScoreDays = 0,
  });

  /// Average of all three scores.
  double get overallScore =>
      (productivityScore + growthScore + healthScore) / 3.0;
}

/// Output layout configuration from the Agent Decision Engine.
class AgentLayoutConfig {
  final LayoutMode layoutMode;
  final bool showMotivationBanner;
  final bool highlightPrimaryTask;
  final bool showLowEnergyTasks;
  final bool showStopDoingPanel;
  final String? motivationMessage;
  final String? coachInsight;

  const AgentLayoutConfig({
    required this.layoutMode,
    required this.showMotivationBanner,
    required this.highlightPrimaryTask,
    required this.showLowEnergyTasks,
    required this.showStopDoingPanel,
    this.motivationMessage,
    this.coachInsight,
  });

  /// Default balanced layout.
  factory AgentLayoutConfig.balanced() => const AgentLayoutConfig(
    layoutMode: LayoutMode.balanced,
    showMotivationBanner: false,
    highlightPrimaryTask: true,
    showLowEnergyTasks: true,
    showStopDoingPanel: false,
  );
}
