import 'dart:ui';
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

class QuickAIOverlay extends StatefulWidget {
  final bool startWithVoice;
  final VoidCallback onClose;

  const QuickAIOverlay({
    super.key,
    this.startWithVoice = false,
    required this.onClose,
  });

  @override
  State<QuickAIOverlay> createState() => _QuickAIOverlayState();
}

class _QuickAIOverlayState extends State<QuickAIOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _textController = TextEditingController();
  final List<String> _surfaceIds = [];
  final List<String> _messages = [];
  GenUiConversation? _conversation;
  bool _isLoading = false;

  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentWords = '';
  bool _isProject = false; // "Project" vs "Basic" for company tasks

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _blurAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    if (widget.startWithVoice) {
      _initSpeechAndListen();
    }
    _initConversation();
  }

  void _initConversation() {
    final taskProvider = context.read<TaskProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final reflectionProvider = context.read<ReflectionProvider>();

    _conversation = GenUiSetup.createConversation(
      context: context,
      taskContext: taskProvider.buildTaskContextForAI(),
      dashboardContext: dashboardProvider.buildDashboardContextForAI(),
      reflectionContext: reflectionProvider.buildReflectionContextForAI(),
      onSurfaceAdded:
          (event) => setState(() => _surfaceIds.add(event.surfaceId)),
      onSurfaceDeleted:
          (event) => setState(() => _surfaceIds.remove(event.surfaceId)),
      onTextResponse: (text) => setState(() => _messages.add(text)),
    );
  }

  Future<void> _initSpeechAndListen() async {
    bool available = await _speech.initialize(
      onError: (val) {
        // Handle STT error if needed
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onResult: (result) {
          setState(() {
            _currentWords = result.recognizedWords;
            if (result.finalResult) {
              _textController.text = _currentWords;
              _isListening = false;
              _sendMessage();
            }
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      // Handle speech recognition denial silently or show a snag
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _conversation == null) return;
    _textController.clear();
    setState(() => _isLoading = true);
    // Add context about project status if it's a creation request
    // Add explicit instructions to create a task
    String finalRequest = 'Please create a task based on this input: "$text".';
    if (_isProject) {
      finalRequest += ' (This is a company project task)';
    }
    await _conversation!.sendRequest(UserMessage.text(finalRequest));
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _conversation?.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _blurAnimation.value,
            sigmaY: _blurAnimation.value,
          ),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildBody()),
                    _buildInputArea(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Quick AI',
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _animationController.reverse().then((_) => widget.onClose());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_surfaceIds.isEmpty &&
        _messages.isEmpty &&
        !_isLoading &&
        !_isListening) {
      return Center(
        child: Text(
          widget.startWithVoice ? 'Listening...' : 'How can I help you today?',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (_isListening)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              _currentWords,
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ..._messages.map((m) => _buildMessageBubble(m)),
        ..._surfaceIds.map(
          (id) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GenUiSurface(host: _conversation!.host, surfaceId: id),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTaskTypeSelector(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 16),
              _buildVoiceButton(),
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TaskTypeChip(
          label: 'Basic Task',
          isSelected: !_isProject,
          onTap: () => setState(() => _isProject = false),
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        _TaskTypeChip(
          label: 'Project',
          isSelected: _isProject,
          onTap: () => setState(() => _isProject = true),
          icon: Icons.account_tree_outlined,
        ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: _isListening ? () => _speech.stop() : _initSpeechAndListen,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _isListening ? Colors.red : AppColors.accentBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
      ),
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      icon: const Icon(Icons.send, color: AppColors.accentBlue),
      onPressed: _sendMessage,
    );
  }
}

class _TaskTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _TaskTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.accentBlue
                  : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
