/// 1:1 port of features/assistant/presentation/AssistantScreen.kt.
///
/// Layout contract (Compose parity):
///  • PageScaffold hero header "Assistant" (+ "Thinking." subtitle while
///    processing) with a DeleteSweep clear-chat action.
///  • Messages LazyColumn with Section(20) gaps and 8dp bottom padding.
///  • Suggested prompts shown while messages.size <= 1; TypingIndicator while
///    processing.
///  • InputBar pinned above the floating nav bar via inputBottomGap:
///    58 + 4 + 8 = 70 normally, or 8 when the IME is open.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../ui/theme/theme.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  final int id;
  final String role;
  final String content;
  final int createdAt;
}

class OfflineAssistantEngine {
  static String reply(String prompt) {
    final q = prompt.toLowerCase();
    if (q.contains('spend') || q.contains('expense') || q.contains('money')) {
      return 'Open Finance to see your spending this month. Your Today/Week/Month '
          'metrics are on the hero card, and category breakdowns sit below the ledger.';
    }
    if (q.contains('budget')) {
      return 'Budgets live in Finance Tools → Budget. Set a monthly limit per '
          'category and the progress bar turns orange near the limit and red when you exceed it.';
    }
    if (q.contains('task') || q.contains('todo') || q.contains('to-do')) {
      return 'Your pending tasks are on Home and under Calendar → Tasks. Tap the '
          'circle on a row to mark it complete.';
    }
    if (q.contains('event') || q.contains('calendar') || q.contains('birthday')) {
      return 'Calendar shows upcoming events by month. Use the + button to add '
          'events, birthdays or countdowns — reminders fire automatically.';
    }
    if (q.contains('fuliza')) {
      return 'Fuliza draws and repayments are tracked from your M-Pesa messages. '
          'Check Finance for the outstanding banner once activity is imported.';
    }
    if (q.contains('hello') || q.trim() == 'hi' || q.contains('hey')) {
      final h = DateTime.now().hour;
      return h < 12
          ? 'Good morning! How can I help with your day?'
          : h < 17
              ? 'Good afternoon! What would you like to check?'
              : 'Good evening! Want a quick review of today?';
    }
    if (q.contains('help') || q.contains('what can you do')) {
      return 'I can point you to spending, budgets, tasks, events and imports. '
          'Ask me things like "how is my spending?" or "where are my tasks?".';
    }
    return 'I keep everything on-device, so try asking about your spending, '
        'budgets, tasks, or calendar. You can also import M-Pesa SMS from Finance.';
  }
}

const List<String> _kSuggestedPrompts = [
  'How is my spending this month?',
  'Show my budgets',
  'What tasks are pending?',
  'Any events coming up?',
];

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _listController = ScrollController();
  bool _processing = false;
  bool _showClearConfirm = false;
  int _seq = 0;
  double _prevImeBottom = 0;
  bool _quickSuggestions = true;
  List<String> _suggestedPrompts = _kSuggestedPrompts;

  @override
  void initState() {
    super.initState();
    // Add default greeting synchronously so the list is never empty.
    _messages.add(ChatMessage(
      id: _seq++,
      role: 'assistant',
      content: 'Hi! I am your local assistant. Ask about spending, budgets, tasks or events.',
      createdAt: AppDateUtils.nowMillis,
    ));
    // Then personalise based on onboarding goal and read quick_suggestions pref.
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final goal = prefs.getString('onboarding_primary_goal') ?? 'PRODUCTIVITY';
      final greeting = switch (goal) {
        'FINANCE' =>
          'Hi! I can help you track spending, review budgets, and understand your M-Pesa activity. What would you like to know?',
        'BALANCED' =>
          'Hi! I connect your money, tasks, and calendar so nothing falls through. Ask me anything.',
        _ => null, // keep the default already added
      };
      final prompts = switch (goal) {
        'FINANCE' => const [
            'How is my spending this month?',
            'Show my budgets',
            'Any Fuliza activity?',
            'Top merchants this month?',
          ],
        'BALANCED' => const [
            'How is my spending this month?',
            'What tasks are pending?',
            'Any events coming up?',
            'Show my budgets',
          ],
        _ => _kSuggestedPrompts,
      };
      setState(() {
        _quickSuggestions = prefs.getBool('quick_suggestions') ?? true;
        _suggestedPrompts = prompts;
        if (greeting != null && _messages.length == 1) {
          // Replace the default greeting with the goal-specific one.
          _messages[0] = ChatMessage(
            id: _messages[0].id,
            role: 'assistant',
            content: greeting,
            createdAt: _messages[0].createdAt,
          );
        }
      });
    });
  }

  void _send(String text) {
    final prompt = text.trim();
    if (prompt.isEmpty || _processing) return;
    setState(() {
      _messages.add(ChatMessage(
          id: _seq++, role: 'user', content: prompt, createdAt: AppDateUtils.nowMillis));
      _input.clear();
      _processing = true;
    });
    _autoScroll();
    Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: _seq++,
          role: 'assistant',
          content: OfflineAssistantEngine.reply(prompt),
          createdAt: AppDateUtils.nowMillis,
        ));
        _processing = false;
      });
      _autoScroll();
    });
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.hasClients) {
        _listController.animateTo(
          _listController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // resizeToAvoidBottomInset is false on MainShell's Scaffold, so the keyboard
    // overlaps from the bottom without shrinking the body. We must manually
    // account for keyboard height in the InputBar's bottom gap.
    //
    // Closed: gap = navBar(58) + offset(4) + hairline(8) = 70 dp
    //         → InputBar floats just above the pill bar with a 1-pt hairline.
    // Open  : gap = keyboard height + 8 dp
    //         → InputBar sits flush 8 dp above the keyboard top edge.
    final imeBottom = MediaQuery.viewInsetsOf(context).bottom;
    // When the keyboard opens, scroll the message list so the last message
    // is visible above the input bar (keyboard pushes content up).
    if (imeBottom > 0 && _prevImeBottom == 0) {
      _autoScroll();
    }
    _prevImeBottom = imeBottom;
    final inputBottomGap = imeBottom > 0
        ? imeBottom + AppDesignTokens.assistantInputHairlineGap
        : AppDesignTokens.floatingNavBarHeight +
            AppDesignTokens.floatingNavBarBottomOffset +
            AppDesignTokens.assistantInputHairlineGap;

    if (_showClearConfirm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            title: Text('Clear chat history?',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            content: const Text(
                'This will remove your current assistant conversation and start a fresh one.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.removeRange(1, _messages.length);
                    _showClearConfirm = false;
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        );
      });
    }

    return PageScaffold(
      title: 'Assistant',
      subtitle: _processing ? 'Thinking.' : null,
      scrollable: false,
      contentPadding: EdgeInsets.zero,
      actions: [
        IconButton(
          onPressed: () => setState(() => _showClearConfirm = true),
          icon: Icon(Icons.delete_sweep_outlined,
              size: 22, color: Theme.of(context).colorScheme.onSurface),
          tooltip: 'Clear chat',
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _listController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount:
                  _messages.length + (_messages.length <= 1 && _quickSuggestions ? 1 : 0) + (_processing ? 1 : 0),
              itemBuilder: (context, i) {
                // Suggested prompts slot after the single greeting message
                // (only when the Quick Suggestions toggle is enabled in Settings).
                if (_messages.length <= 1 && _quickSuggestions && i == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.section),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in _suggestedPrompts)
                          ActionChip(label: Text(p), onPressed: () => _send(p)),
                      ],
                    ),
                  );
                }
                if (_processing && i == _messages.length + (_messages.length <= 1 ? 1 : 0)) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.section),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingIndicator(),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.section),
                  child: ChatBubble(message: _messages[i]),
                );
              },
            ),
          ),
          InputBar(
            controller: _input,
            onSend: () => _send(_input.text),
            isProcessing: _processing,
          ),
          // Animated so the InputBar slides with the keyboard instead of jumping.
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: inputBottomGap,
          ),
        ],
      ),
    );
  }
}

// ── ChatBubble ──────────────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isUser ? scheme.primaryContainer : scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(14),
        child: Text(message.content,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

// ── InputBar ────────────────────────────────────────────────────────────────

class InputBar extends StatelessWidget {
  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isProcessing,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 1,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            style: TextStyle(color: scheme.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ask anything...',
              isDense: true,
              filled: true,
              fillColor: scheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                borderSide: BorderSide(color: scheme.primary),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: isProcessing ? null : onSend,
          icon: Icon(Icons.send_outlined, color: scheme.primary),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Opacity(
                  opacity: ((i / 3 - _c.value) % 1).abs().clamp(0.25, 1.0),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
