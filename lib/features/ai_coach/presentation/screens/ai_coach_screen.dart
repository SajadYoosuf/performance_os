import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/genui/genui_setup.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:app/features/reflection/presentation/providers/reflection_provider.dart';

/// AI Coach screen — GenUI + RAG context + Speech-to-Text voice input.
class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});
  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  GenUiConversation? _conversation;
  final _inputController = TextEditingController();
  final _surfaceIds = <String>[];
  final _textResponses = <String>[];
  bool _isLoading = false;
  String? _error;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _isListening = _speech.isListening;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  void _startListening() {
    if (!_speechAvailable || _isListening) return;
    _speech.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          _inputController.text = _lastWords;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _lastWords.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
    setState(() => _isListening = true);
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initConversation();
  }

  void _initConversation() {
    _conversation?.dispose();

    final taskProvider = context.read<TaskProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final reflectionProvider = context.read<ReflectionProvider>();

    _conversation = GenUiSetup.createConversation(
      context: context,
      taskContext: taskProvider.buildTaskContextForAI(),
      dashboardContext: dashboardProvider.buildDashboardContextForAI(),
      reflectionContext: reflectionProvider.buildReflectionContextForAI(),
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
    _conversation?.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _conversation == null) return;
    _inputController.clear();
    if (_isListening) _stopListening();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _conversation!.sendRequest(UserMessage.text(text));
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
    final taskProvider = context.watch<TaskProvider>();
    final taskCount = taskProvider.tasks.length;
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
                  'Knows your $taskCount tasks • Voice enabled',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_speechAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, size: 12, color: AppColors.accentGreen),
                  const SizedBox(width: 2),
                  Text(
                    'STT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accentGreen,
                      fontSize: 9,
                    ),
                  ),
                ],
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
              'I know all your tasks. Ask me anything — type or use the mic!',
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
                  label: 'What are my tasks today?',
                  onTap: () {
                    _inputController.text = 'What are my tasks today?';
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
                  label: 'Show my weekly summary',
                  onTap: () {
                    _inputController.text = 'Show my weekly task summary';
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  label: 'Any overdue tasks?',
                  onTap: () {
                    _inputController.text = 'Do I have any overdue tasks?';
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
            child: GenUiSurface(host: _conversation!.host, surfaceId: id),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice status indicator
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Listening... Speak now',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              // Mic button
              if (_speechAvailable)
                GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:
                          _isListening
                              ? AppColors.error
                              : primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          _isListening
                              ? [
                                BoxShadow(
                                  color: AppColors.error.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: _isListening ? Colors.white : primary,
                      size: 20,
                    ),
                  ),
                ),
              // Text input
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _sendMessage(),
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText:
                        _speechAvailable
                            ? 'Type or tap mic to speak...'
                            : 'Ask about your tasks, progress...',
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
              const SizedBox(width: 8),
              // Send button
              _isLoading
                  ? const SizedBox(
                    width: 44,
                    height: 44,
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
            ],
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
