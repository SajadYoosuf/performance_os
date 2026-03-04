import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/genui/genui_setup.dart';

/// AI Coach screen — powered by GenUI.
///
/// Uses [GenUiConversation] + [GenUiSurface] to render dynamic,
/// AI-generated UI in real time based on the user's conversation.
class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});
  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  late final GenUiConversation _conversation;
  final _inputController = TextEditingController();
  final _surfaceIds = <String>[];
  final _textResponses = <String>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _conversation = GenUiSetup.createConversation(
      onSurfaceAdded: (SurfaceAdded event) {
        setState(() => _surfaceIds.add(event.surfaceId));
      },
      onSurfaceDeleted: (SurfaceRemoved event) {
        setState(() => _surfaceIds.remove(event.surfaceId));
      },
      onTextResponse: (text) {
        setState(() => _textResponses.add(text));
      },
      onError: (error) {
        setState(() {
          _error = error.error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _conversation.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _conversation.sendRequest(UserMessage.text(text));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primary),
            Expanded(
              child:
                  _surfaceIds.isEmpty && _textResponses.isEmpty
                      ? _buildEmptyState(primary)
                      : _buildConversationView(primary),
            ),
            if (_error != null) _buildErrorBar(),
            _buildInputBar(primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, AppColors.accentGreen],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Coach',
                  style: AppTextStyles.heading4.copyWith(fontSize: 16),
                ),
                Text(
                  'Powered by GenUI',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LIVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accentGreen,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, AppColors.accentGreen],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your AI Performance Coach',
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me about your productivity, get insights on your performance, or request personalized suggestions.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'How am I doing today?',
                  onTap: () {
                    _inputController.text = 'How am I doing today?';
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  label: 'What should I focus on?',
                  onTap: () {
                    _inputController.text = 'What should I focus on?';
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  label: 'Show my weekly trends',
                  onTap: () {
                    _inputController.text = 'Show my weekly trends';
                    _sendMessage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationView(Color primary) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        ..._textResponses.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(text, style: AppTextStyles.bodyMedium),
            ),
          ),
        ),
        ..._surfaceIds.map(
          (id) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GenUiSurface(host: _conversation.host, surfaceId: id),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _error = null),
            child: const Icon(Icons.close, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onSubmitted: (_) => _sendMessage(),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Ask your AI Coach...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _isLoading
              ? const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
              : GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: primary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
