import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/shared/models/enums.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Define tools for the AI coach.
class TaskTools {
  static List<AiTool> asTools(BuildContext context) {
    return [
      DynamicAiTool(
        name: 'create_task',
        description: 'Create a new task in Performance OS.',
        parameters: S.object(
          properties: {
            'title': S.string(description: 'The title of the task'),
            'description': S.string(description: 'Detailed description'),
            'domain': S.string(
              description: 'Category (work, growth, health, personal)',
              enumValues: ['work', 'growth', 'health', 'personal'],
            ),
            'impactScore': S.number(description: 'Impact score 1-10'),
            'urgency': S.string(
              description: 'Urgency level',
              enumValues: ['low', 'medium', 'high'],
            ),
            'isProject': S.boolean(
              description: 'Whether this is a company project task',
            ),
          },
          required: ['title', 'domain'],
        ),
        invokeFunction: (args) async {
          final title = args['title'] as String;
          final desc = args['description'] as String?;
          final domainStr = args['domain'] as String;
          final impact = (args['impactScore'] as num? ?? 5).toDouble();
          final urgencyStr = args['urgency'] as String? ?? 'medium';
          final isProject = args['isProject'] as bool? ?? false;

          final task = TaskEntity(
            id: const Uuid().v4(),
            userId: 'current-user-id',
            title: title,
            description: desc,
            domain: TaskDomain.values.firstWhere(
              (e) => e.name == domainStr,
              orElse: () => TaskDomain.work,
            ),
            impactScore: impact,
            urgency: TaskUrgency.values.firstWhere(
              (e) => e.name == urgencyStr,
              orElse: () => TaskUrgency.medium,
            ),
            energyRequired: EnergyLevel.medium,
            createdAt: DateTime.now(),
            isProject: isProject,
          );

          await context.read<TaskProvider>().addTaskInstance(task);
          return {'status': 'success', 'taskId': task.id};
        },
      ),
    ];
  }
}
