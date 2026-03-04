import 'package:app/core/agent/agent_layout_model.dart';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/shared/models/enums.dart';

/// Pure rule-based Agentic Decision Engine.
///
/// Evaluates user performance metrics and produces a layout configuration
/// that drives the entire UI rendering. No UI logic should exist outside
/// this engine — all conditional visibility flows through [AgentLayoutConfig].
///
/// This is designed to be replaced or augmented by a GPT/AI backend in
/// future phases while maintaining the same input/output contract.
class AgentDecisionEngine {
  const AgentDecisionEngine();

  /// Evaluate user state and produce a layout configuration.
  AgentLayoutConfig evaluate(AgentInput input) {
    final layoutMode = _determineLayoutMode(input);
    final showMotivation = _shouldShowMotivationBanner(input);
    final highlightPrimary = _shouldHighlightPrimaryTask(input);
    final showLowEnergy = _shouldShowLowEnergyTasks(input, layoutMode);
    final showStopDoing = _shouldShowStopDoingPanel(input);
    final motivationMsg = _generateMotivationMessage(input, layoutMode);
    final coachMsg = _generateCoachInsight(input, layoutMode);

    return AgentLayoutConfig(
      layoutMode: layoutMode,
      showMotivationBanner: showMotivation,
      highlightPrimaryTask: highlightPrimary,
      showLowEnergyTasks: showLowEnergy,
      showStopDoingPanel: showStopDoing,
      motivationMessage: motivationMsg,
      coachInsight: coachMsg,
    );
  }

  /// Determine the core layout mode from overall score.
  LayoutMode _determineLayoutMode(AgentInput input) {
    final overall = input.overallScore;

    if (overall < AppConstants.recoveryThreshold) {
      return LayoutMode.recovery;
    } else if (overall >= AppConstants.focusThreshold) {
      return LayoutMode.focus;
    }
    return LayoutMode.balanced;
  }

  /// Show motivation banner when user has consecutive low-performing days
  /// or is in recovery mode.
  bool _shouldShowMotivationBanner(AgentInput input) {
    return input.consecutiveLowScoreDays >=
            AppConstants.consecutiveLowDaysForMotivation ||
        input.overallScore < AppConstants.recoveryThreshold;
  }

  /// Highlight the primary task when there are pending high-impact tasks
  /// and user has energy to handle them.
  bool _shouldHighlightPrimaryTask(AgentInput input) {
    return input.pendingHighImpactTasks > 0 &&
        input.energyLevel != EnergyLevel.low;
  }

  /// Show low-energy task suggestions when:
  /// - User energy is low, OR
  /// - Layout is in recovery mode.
  bool _shouldShowLowEnergyTasks(AgentInput input, LayoutMode mode) {
    return input.energyLevel == EnergyLevel.low || mode == LayoutMode.recovery;
  }

  /// Show stop-doing panel when there are overdue tasks, indicating
  /// potential context-switching or scope creep.
  bool _shouldShowStopDoingPanel(AgentInput input) {
    return input.overdueTasks > 3;
  }

  /// Generate contextual motivation message.
  String? _generateMotivationMessage(AgentInput input, LayoutMode mode) {
    if (mode == LayoutMode.recovery) {
      return "Take it easy today. Focus on recovery and low-impact wins.";
    }
    if (input.consecutiveLowScoreDays >= 3) {
      return "You've had a tough stretch. Small consistent wins build momentum.";
    }
    if (mode == LayoutMode.focus && input.productivityScore > 90) {
      return "You're on fire! Channel this energy into your highest-impact task.";
    }
    return null;
  }

  /// Generate AI coach insight message.
  String? _generateCoachInsight(AgentInput input, LayoutMode mode) {
    if (mode == LayoutMode.focus) {
      return "You're on track for your most productive day this week. "
          "Ready for a deep work session?";
    }
    if (input.healthScore < 50) {
      return "Your health score is dropping. Consider scheduling a "
          "recovery activity today.";
    }
    if (input.growthScore < 30) {
      return "Growth is stalling. Try adding one learning task today "
          "to boost your trajectory.";
    }
    return "Stay consistent. Your patterns show steady improvement.";
  }
}
