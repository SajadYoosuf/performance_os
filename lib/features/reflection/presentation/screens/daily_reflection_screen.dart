import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/models/enums.dart';
import 'package:app/shared/widgets/glass_card.dart';
import 'package:app/features/reflection/presentation/providers/reflection_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

/// Daily Reflection screen — mapped from Stitch daily_reflection UI.
class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.focused;
  double _distractionHours = 1.5;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildHeader(context, primary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How was your day?',
                      style: AppTextStyles.heading1.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(context),
                    const SizedBox(height: 32),
                    _buildMoodSelector(context, primary),
                    const SizedBox(height: 32),
                    _buildDistractionSlider(context, primary),
                    const SizedBox(height: 32),
                    _buildAIAnalysis(context, primary),
                    const SizedBox(height: 24),
                    _buildSaveButton(primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.close, color: AppColors.textTertiary),
          ),
          Text(
            'REFLECTION',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Icon(Icons.auto_awesome, color: primary),
        ],
      ),
    );
  }

  Widget _buildTextArea(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        maxLines: 6,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Type your thoughts here...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOOD & ENERGY',
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MoodType.values.map((mood) {
            final sel = _selectedMood == mood;
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel ? primary : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMoodIcon(mood),
                      size: 20,
                      color: sel ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mood.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: sel ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistractionSlider(BuildContext context, Color primary) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DISTRACTION HOURS',
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '${_distractionHours.toStringAsFixed(1)}h',
              style: AppTextStyles.heading4.copyWith(
                color: primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, color: AppColors.textTertiary),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _distractionHours,
                  min: 0,
                  max: 8,
                  divisions: 16,
                  activeColor: primary,
                  onChanged: (v) => setState(() => _distractionHours = v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysis(BuildContext context, Color primary) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: GlassCard(
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: AppTextStyles.heading4.copyWith(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AnalysisRow(
              icon: Icons.check_circle,
              iconColor: AppColors.accentGreen,
              bgColor: AppColors.successLight,
              title: 'What went well',
              desc:
                  'Deep work session in the morning led to 3 high-priority tasks completed.',
            ),
            const SizedBox(height: 12),
            _AnalysisRow(
              icon: Icons.trending_up,
              iconColor: AppColors.warning,
              bgColor: AppColors.warningLight,
              title: 'What to improve',
              desc:
                  'Context switching increased after 2 PM. Try batching communications.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOMORROW SUGGESTION',
                    style: AppTextStyles.labelSmall.copyWith(color: primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Block out 9:00 - 11:00 AM for the Product Roadmap draft."',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveReflection,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: primary.withValues(alpha: 0.3),
        ),
        child: const Text('Save Reflection'),
      ),
    );
  }

  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.focused:
        return Icons.sentiment_very_satisfied;
      case MoodType.highEnergy:
        return Icons.bolt;
      case MoodType.calm:
        return Icons.sentiment_neutral;
      case MoodType.tired:
        return Icons.battery_1_bar;
    }
  }

  void _saveReflection() {
    if (_contentController.text.trim().isEmpty) return;
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;
    context.read<ReflectionProvider>().saveReflection(
      userId: userId,
      content: _contentController.text.trim(),
      mood: _selectedMood,
      distractionHours: _distractionHours,
    );
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

class _AnalysisRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bgColor;
  final String title, desc;
  const _AnalysisRow({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.desc,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
