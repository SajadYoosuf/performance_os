import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:app/core/genui/performance_os_catalog.dart';
import 'package:app/core/genui/task_tools.dart';

/// Setup for GenUI in Performance OS.
class GenUiSetup {
  static String buildSystemInstruction({
    String? taskContext,
    String? dashboardContext,
    String? reflectionContext,
  }) {
    final buf = StringBuffer();
    buf.writeln('You are the Performance OS AI Coach.');
    buf.writeln('Help the user manage tasks and improve productivity.');
    buf.writeln('You can create tasks using the "create_task" tool.');

    buf.writeln('\n--- USER STATUS & CONTEXT ---');
    buf.writeln('Current user task context:');
    buf.writeln(taskContext ?? 'No tasks currently.');

    if (dashboardContext != null && dashboardContext.isNotEmpty) {
      buf.writeln('\n$dashboardContext');
    }

    if (reflectionContext != null && reflectionContext.isNotEmpty) {
      buf.writeln('\n$reflectionContext');
    }
    buf.writeln('-----------------------------\n');
    buf.writeln(
      'When you receive user input, your primary goal is to use the "create_task" tool to extract details and CREATE THE TASK IMMEDIATELY.',
    );
    buf.writeln('Do NOT just describe how you would create it. Call the tool.');
    buf.writeln(
      'If title or domain is missing, make your best guess based on the context before asking for clarification.',
    );
    buf.writeln(
      '- Use "isProject: true" if it says it is a company/official work.',
    );
    buf.writeln('- Always confirm after successfully calling the tool.');
    return buf.toString();
  }

  static GenUiConversation createConversation({
    required ValueChanged<SurfaceAdded> onSurfaceAdded,
    required ValueChanged<SurfaceRemoved> onSurfaceDeleted,
    required BuildContext context,
    ValueChanged<String>? onTextResponse,
    ValueChanged<ContentGeneratorError>? onError,
    String? taskContext,
    String? dashboardContext,
    String? reflectionContext,
  }) {
    final catalog = PerformanceOSCatalog.asCatalog();
    final a2uiMessageProcessor = A2uiMessageProcessor(catalogs: [catalog]);
    final systemInstruction = buildSystemInstruction(
      taskContext: taskContext,
      dashboardContext: dashboardContext,
      reflectionContext: reflectionContext,
    );
    final tools = TaskTools.asTools(context);

    final contentGenerator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: systemInstruction,
      additionalTools: tools,
    );

    return GenUiConversation(
      a2uiMessageProcessor: a2uiMessageProcessor,
      contentGenerator: contentGenerator,
      onSurfaceAdded: (update) => onSurfaceAdded(update),
      onSurfaceDeleted: (update) => onSurfaceDeleted(update),
      onTextResponse: (text) => onTextResponse?.call(text),
      onError: (error) => onError?.call(error),
    );
  }
}
