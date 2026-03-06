import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'dart:math' as math;

class AnimatedFloatingMenu extends StatefulWidget {
  final VoidCallback onChatPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onAddPressed;

  const AnimatedFloatingMenu({
    super.key,
    required this.onChatPressed,
    required this.onVoicePressed,
    required this.onAddPressed,
  });

  @override
  State<AnimatedFloatingMenu> createState() => _AnimatedFloatingMenuState();
}

class _AnimatedFloatingMenuState extends State<AnimatedFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChild(
          icon: Icons.add_rounded,
          color: AppColors.accentBlue,
          onPressed: () {
            _toggle();
            widget.onAddPressed();
          },
          index: 2,
        ),
        const SizedBox(height: 16),
        _buildChild(
          icon: Icons.mic_rounded,
          color: AppColors.accentOrange,
          onPressed: () {
            _toggle();
            widget.onVoicePressed();
          },
          index: 1,
        ),
        const SizedBox(height: 16),
        _buildChild(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.accentGreen,
          onPressed: () {
            _toggle();
            widget.onChatPressed();
          },
          index: 0,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi * 0.75,
                child: Icon(
                  _isOpen ? Icons.add : Icons.bolt,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChild({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        // Staggered reveal
        final double opacity = Curves.easeOut.transform(
          (value - (index * 0.2)).clamp(0.0, 1.0),
        );
        final double scale = 0.5 + (0.5 * opacity);
        final double translateY = (1.0 - opacity) * 20;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale,
              child: FloatingActionButton.small(
                onPressed: _isOpen ? onPressed : null,
                backgroundColor: color,
                elevation: 2,
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
