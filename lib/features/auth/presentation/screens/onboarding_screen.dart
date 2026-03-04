import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';

/// Onboarding screen — mapped from Stitch onboarding UI.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 2;
  final int _totalSteps = 4;
  final Set<String> _selectedDomains = {'Work'};
  int _focusHours = 6;
  String _peakEnergy = 'Morning';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $_step of $_totalSteps',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: primary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Configuration',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _step / _totalSteps,
                  backgroundColor: Colors.grey.shade200,
                  color: primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
              // AI Orb
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary, AppColors.accentGreen],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Let's optimize your life.",
                style: AppTextStyles.heading1.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Tell us how you'd like to structure your peak performance system.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDomains(primary),
                      const SizedBox(height: 32),
                      _buildFocusHours(primary),
                      const SizedBox(height: 32),
                      _buildPeakEnergy(primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onComplete,
                  icon: const Text('Continue to Architecture'),
                  label: const Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 12,
                    shadowColor: primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You can adjust these parameters later in your OS settings.",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomains(Color primary) {
    final domains = [
      ('Work', Icons.work),
      ('Learning', Icons.school),
      ('Health', Icons.fitness_center),
      ('Personal', Icons.person),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Primary Domains',
              style: AppTextStyles.heading4.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: domains.map((d) {
            final sel = _selectedDomains.contains(d.$1);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel)
                  _selectedDomains.remove(d.$1);
                else
                  _selectedDomains.add(d.$1);
              }),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? primary.withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: sel
                            ? primary.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        d.$2,
                        color: sel ? primary : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      d.$1,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
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

  Widget _buildFocusHours(Color primary) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Daily Focus Hours',
                  style: AppTextStyles.heading4.copyWith(fontSize: 16),
                ),
              ],
            ),
            Text(
              '$_focusHours hrs',
              style: AppTextStyles.heading3.copyWith(
                color: primary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primary,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayColor: primary.withValues(alpha: 0.1),
            trackHeight: 8,
          ),
          child: Slider(
            value: _focusHours.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            onChanged: (v) => setState(() => _focusHours = v.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['1h', '4h', '8h', '12h+']
              .map(
                (t) => Text(
                  t,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPeakEnergy(Color primary) {
    final options = [
      ('Morning', Icons.light_mode),
      ('Afternoon', Icons.wb_sunny),
      ('Evening', Icons.dark_mode),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, color: primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Peak Energy Time',
              style: AppTextStyles.heading4.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: options.map((o) {
              final sel = _peakEnergy == o.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _peakEnergy = o.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          o.$2,
                          color: sel ? primary : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          o.$1.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sel ? primary : AppColors.textTertiary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
