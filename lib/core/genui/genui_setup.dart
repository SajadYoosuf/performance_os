import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:app/core/genui/performance_os_catalog.dart';

/// Factory for creating and configuring the GenUI conversation
/// for the Performance OS AI Coach.
class GenUiSetup {
  GenUiSetup._();

  /// Base system instruction that tells the AI how to behave.
  static const String _baseSystemInstruction = '''
You are the AI Coach for Performance OS, an AI-powered Personal Performance Operating System.

Your role:
- Analyze the user's productivity data, tasks, scores, and habits.
- Provide actionable insights and suggestions to improve their performance.
- Dynamically generate UI using the available widget catalog.
- You have FULL knowledge of the user's tasks, completed items, and schedule below.

Available widgets you can use:
- **ScoreCard**: Display a metric with title, score value, and optional trend.
- **InsightCard**: Show an AI-generated insight with title, description, and type.
- **MotivationBanner**: Display an encouraging or motivational message.
- **MetricRow**: Show a label-value pair with optional change percentage.
- **ActionSuggestion**: Recommend a specific action with reason and priority level.
- **Text**: Standard text display.
- **Markdown**: Rich formatted text.

When the user asks about their performance, generate a mix of ScoreCards, InsightCards, and ActionSuggestions.
When the user needs motivation, use MotivationBanner.
When showing detailed metrics, use MetricRow.
Always be encouraging, data-driven, and actionable.
When the user asks about tasks, use the task data provided below to give accurate, personalized answers.
''';

  /// Build the full system instruction with dynamic task context.
  static String buildSystemInstruction({String? taskContext}) {
    if (taskContext == null || taskContext.isEmpty) {
      return _baseSystemInstruction;
    }
    return '$_baseSystemInstruction\n\n$taskContext';
  }

  /// Creates a fully configured [GenUiConversation].
  ///
  /// [taskContext] — structured text summary of user tasks injected
  /// as part of the system instruction (RAG-like context).
  static GenUiConversation createConversation({
    required ValueChanged<SurfaceAdded> onSurfaceAdded,
    required ValueChanged<SurfaceRemoved> onSurfaceDeleted,
    ValueChanged<String>? onTextResponse,
    ValueChanged<ContentGeneratorError>? onError,
    String? taskContext,
  }) {
    final catalog = PerformanceOSCatalog.asCatalog();

    final a2uiMessageProcessor = A2uiMessageProcessor(catalogs: [catalog]);

    final systemInstruction = buildSystemInstruction(taskContext: taskContext);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: systemInstruction,
    );

    return GenUiConversation(
      a2uiMessageProcessor: a2uiMessageProcessor,
      contentGenerator: contentGenerator,
      onSurfaceAdded: onSurfaceAdded,
      onSurfaceDeleted: onSurfaceDeleted,
      onTextResponse: onTextResponse,
      onError: onError,
    );
  }
}
