import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/models/enums.dart';
import 'package:app/shared/widgets/glass_card.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

/// Add Task screen — mapped from Stitch add_task UI.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  double _impactScore = 8.0;
  TaskUrgency _urgency = TaskUrgency.medium;
  EnergyLevel _energyRequired = EnergyLevel.low;
  TaskDomain _domain = TaskDomain.work;
  int _estimatedMinutes = 45;
  OutcomeType _outcomeType = OutcomeType.revenueGeneration;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Text(
                    'Add Intelligent Task',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                  _CircleButton(
                    icon: Icons.auto_awesome,
                    isPrimary: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Task Name
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TASK IDENTIFIER',
                            style: AppTextStyles.sectionHeader.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'What is the mission?',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Impact Slider
                    GlassCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'IMPACT SCORE',
                                style: AppTextStyles.sectionHeader.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _impactScore.toStringAsFixed(1),
                                style: AppTextStyles.heading2.copyWith(
                                  color: primary,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: primary,
                              inactiveTrackColor: Colors.grey.shade200,
                              thumbColor: primary,
                              overlayColor: primary.withValues(alpha: 0.1),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                              trackHeight: 8,
                            ),
                            child: Slider(
                              value: _impactScore,
                              min: 1,
                              max: 10,
                              divisions: 18,
                              onChanged: (v) =>
                                  setState(() => _impactScore = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LOW',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              Text(
                                'HIGH',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Urgency & Energy
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'URGENCY',
                                  style: AppTextStyles.sectionHeader.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: TaskUrgency.values.map((u) {
                                    return _ToggleChip(
                                      label: u.label,
                                      isSelected: _urgency == u,
                                      onTap: () => setState(() => _urgency = u),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ENERGY REQUIRED',
                                  style: AppTextStyles.sectionHeader.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: EnergyLevel.values.map((e) {
                                    return _ToggleChip(
                                      label: e.label,
                                      isSelected: _energyRequired == e,
                                      onTap: () =>
                                          setState(() => _energyRequired = e),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Domain Selector
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOMAIN',
                            style: AppTextStyles.sectionHeader.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: TaskDomain.values.map((d) {
                              final isSelected = _domain == d;
                              return GestureDetector(
                                onTap: () => setState(() => _domain = d),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    d.label,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Time & Outcome
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TIME ESTIMATE',
                                  style: AppTextStyles.sectionHeader.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: AppTextStyles.heading3.copyWith(
                                          fontSize: 18,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                        ),
                                        controller: TextEditingController(
                                          text: _estimatedMinutes.toString(),
                                        ),
                                        onChanged: (v) {
                                          final parsed = int.tryParse(v);
                                          if (parsed != null) {
                                            _estimatedMinutes = parsed;
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'minutes',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
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
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OUTCOME TYPE',
                                  style: AppTextStyles.sectionHeader.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<OutcomeType>(
                                      value: _outcomeType,
                                      isExpanded: true,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                      items: OutcomeType.values.map((o) {
                                        return DropdownMenuItem(
                                          value: o,
                                          child: Text(o.label),
                                        );
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _outcomeType = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Deploy Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deployTask,
                        icon: const Icon(Icons.bolt),
                        label: const Text('Deploy Task to OS'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 12,
                          shadowColor: primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Task will be prioritized using the OS weighted algorithm.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deployTask() {
    if (_titleController.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.user?.uid;
    if (userId == null) return;

    context.read<TaskProvider>().addTask(
      userId: userId,
      title: _titleController.text.trim(),
      domain: _domain,
      impactScore: _impactScore,
      urgency: _urgency,
      energyRequired: _energyRequired,
      estimatedMinutes: _estimatedMinutes,
      outcomeType: _outcomeType,
    );

    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary ? primary.withValues(alpha: 0.1) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isPrimary
                ? primary.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: isPrimary
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: isPrimary ? primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
