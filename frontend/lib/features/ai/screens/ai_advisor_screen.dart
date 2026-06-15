import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/ai_message.dart';
import '../providers/ai_provider.dart';

class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text.trim());
    Future.delayed(const Duration(milliseconds: 300), _scrollBottom);
  }

  void _scrollBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(aiChatProvider);

    return Scaffold(
      backgroundColor: SedixColors.bg,
      appBar: AppBar(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.wandMagicSparkles,
                size: 18, color: SedixColors.accent),
            SizedBox(width: 8),
            Text('AI Advisor'),
          ],
        ),
        actions: [
          if (chat.messages.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(aiChatProvider.notifier).clear(),
              child: const Text('Clear',
                  style: TextStyle(color: SedixColors.textSecondary)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty
                ? _WelcomeView(onSend: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length +
                        (chat.loading ? 1 : 0) +
                        (chat.suggestions.isNotEmpty ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i < chat.messages.length) {
                        return _MessageBubble(msg: chat.messages[i]);
                      }
                      if (chat.loading) return const _TypingIndicator();
                      return _SuggestionsRow(
                        suggestions: chat.suggestions,
                        onTap: _send,
                      );
                    },
                  ),
          ),

          if (chat.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(chat.error!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12)),
            ),

          _InputBar(
            controller: _ctrl,
            loading: chat.loading,
            onSend: () => _send(_ctrl.text),
          ),
        ],
      ),
    );
  }
}

// ── Welcome view ──────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  final void Function(String) onSend;

  const _WelcomeView({required this.onSend});

  static const _starters = [
    'How can I save faster?',
    'What should I prioritize?',
    'Give me 3 saving tips',
    'How do I stay motivated?',
  ];

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: clayBox(radius: 50),
                child: const FaIcon(FontAwesomeIcons.wandMagicSparkles,
                    size: 48, color: SedixColors.accent),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sedix AI Advisor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SedixColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask me anything about your saving goals.',
                style: TextStyle(
                  color: SedixColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _starters
                    .map((s) => GestureDetector(
                          onTap: () => onSend(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: clayBox(radius: 20),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: SedixColors.textPrimary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final AiMessage msg;

  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SedixColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const FaIcon(FontAwesomeIcons.wandMagicSparkles,
                  size: 13, color: SedixColors.accent),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? SedixColors.accent : SedixColors.surfaceHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color:
                      isUser ? Colors.white : SedixColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SedixColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const FaIcon(FontAwesomeIcons.wandMagicSparkles,
                  size: 13, color: SedixColors.accent),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: SedixColors.surfaceHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  backgroundColor: SedixColors.shadowDark,
                  color: SedixColors.accent,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Suggestion chips ──────────────────────────────────────────────────────────

class _SuggestionsRow extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const _SuggestionsRow(
      {required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map((s) => GestureDetector(
                    onTap: () => onTap(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: SedixColors.accentLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: SedixColors.accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SedixColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;

  const _InputBar(
      {required this.controller,
      required this.loading,
      required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        color: SedixColors.bg,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: clayBox(radius: 28),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask your saving advisor...',
                    hintStyle:
                        TextStyle(color: SedixColors.textSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: (_) => onSend(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: loading ? null : onSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: loading
                      ? SedixColors.shadowDark
                      : SedixColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: loading
                      ? []
                      : [
                          BoxShadow(
                            color: SedixColors.accent.withOpacity(0.38),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: const FaIcon(FontAwesomeIcons.paperPlane,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
}
