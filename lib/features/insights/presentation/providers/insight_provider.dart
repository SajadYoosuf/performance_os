import 'package:flutter/material.dart';

/// Insight provider for AI-generated insights.
///
/// Currently uses static/computed insights.
/// Prepared for future GPT/Cloud Functions integration.
class InsightProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // ── Static insights (to be replaced by AI backend) ──
  List<InsightItem> _insights = [
    const InsightItem(
      title: 'Behavior Analysis',
      description:
          'You are 24% more efficient in the first 3 hours after your morning coffee. '
          'Your flow state is most vulnerable to notifications between 10 AM and 11:30 AM.',
      icon: 'psychology',
      type: InsightType.behavioral,
    ),
    const InsightItem(
      title: 'Stop-Doing: Context Switching',
      description:
          'You\'ve opened 12 tabs in the last 15 mins. Focus on one task.',
      icon: 'block',
      type: InsightType.stopDoing,
    ),
    const InsightItem(
      title: 'Cognitive Load Optimization',
      description:
          'Your deep work consistency has increased by 18% this week. '
          'Primary bottleneck identified in Meetings—consider shifting creative tasks to Tuesday morning.',
      icon: 'auto_awesome',
      type: InsightType.aiSummary,
    ),
  ];

  List<InsightItem> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<InsightItem> get stopDoingInsights =>
      _insights.where((i) => i.type == InsightType.stopDoing).toList();

  List<InsightItem> get behavioralInsights =>
      _insights.where((i) => i.type == InsightType.behavioral).toList();

  /// Refresh insights — placeholder for future AI call.
  Future<void> refreshInsights(String userId) async {
    _isLoading = true;
    notifyListeners();

    // TODO: Replace with Cloud Functions / GPT API call
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}

enum InsightType { behavioral, stopDoing, aiSummary, suggestion }

class InsightItem {
  final String title;
  final String description;
  final String icon;
  final InsightType type;

  const InsightItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}
