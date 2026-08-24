/// 1:1 port of features/assistant/presentation/AssistantScreen.kt.
///
/// Layout contract (Compose parity):
///  • PageScaffold hero header "Assistant" (+ "Thinking." subtitle while
///    processing) with a DeleteSweep clear-chat action.
///  • Messages LazyColumn with Section(20) gaps and 8dp bottom padding.
///  • Suggested prompts shown while messages.size <= 1; TypingIndicator while
///    processing.
///  • InputBar pinned above the floating nav bar:
///    gap = navBar(58) + offset(4) + safeBottom + hairline(8)
///    or IME height + 8 when keyboard is open.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/drift.dart' show Variable;

import '../../../core/database/database.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/dashboard/data/providers.dart';

// ── Real-data context loaded from the DB ────────────────────────────────────

class _LiveContext {
  _LiveContext({
    this.monthSpentKsh = 0,
    this.topCategory = '',
    this.pendingTasksCount = 0,
    this.upcomingEventsCount = 0,
    this.fulizaBalance = 0,
    this.budgets = const [],
  });
  final double monthSpentKsh;
  final String topCategory;
  final int pendingTasksCount;
  final int upcomingEventsCount;
  final double fulizaBalance;
  final List<({String name, double limit, double spent})> budgets;
}

Future<_LiveContext> _loadLiveContext(LifeOsDatabase db, String userId) async {
  final now = DateTime.now();
  final monthStart =
      DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
  final sevenDays =
      now.add(const Duration(days: 7)).millisecondsSinceEpoch;

  // ── 1. Month spending total ────────────────────────────────────────────────
  double monthSpent = 0;
  String topCat = '';
  try {
    final row = await db.customSelect(
      '''SELECT COALESCE(SUM(amount),0) AS total
         FROM transactions
         WHERE user_id = ? AND date >= ? AND deleted_at IS NULL
           AND UPPER(transaction_type) IN
               ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')''',
      variables: [Variable(userId), Variable(monthStart)],
    ).getSingleOrNull();
    monthSpent = (row?.data['total'] as num?)?.toDouble() ?? 0;

    final catRow = await db.customSelect(
      '''SELECT category, SUM(amount) AS cat_total
         FROM transactions
         WHERE user_id = ? AND date >= ? AND deleted_at IS NULL
           AND UPPER(transaction_type) IN
               ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
           AND category IS NOT NULL AND category != ''
         GROUP BY category ORDER BY cat_total DESC LIMIT 1''',
      variables: [Variable(userId), Variable(monthStart)],
    ).getSingleOrNull();
    topCat = catRow?.data['category'] as String? ?? '';
  } catch (_) {}

  // ── 2. Pending tasks ───────────────────────────────────────────────────────
  int pendingTasks = 0;
  try {
    final row = await db.customSelect(
      'SELECT COUNT(*) AS c FROM tasks WHERE user_id = ? AND status != ? AND deleted_at IS NULL',
      variables: [Variable(userId), const Variable('DONE')],
    ).getSingleOrNull();
    pendingTasks = (row?.data['c'] as int?) ?? 0;
  } catch (_) {}

  // ── 3. Upcoming events (next 7 days) ──────────────────────────────────────
  int upcomingEvents = 0;
  try {
    final row = await db.customSelect(
      '''SELECT COUNT(*) AS c FROM events
         WHERE user_id = ? AND date BETWEEN ? AND ? AND deleted_at IS NULL''',
      variables: [
        Variable(userId),
        Variable(now.millisecondsSinceEpoch),
        Variable(sevenDays),
      ],
    ).getSingleOrNull();
    upcomingEvents = (row?.data['c'] as int?) ?? 0;
  } catch (_) {}

  // ── 4. Fuliza balance ─────────────────────────────────────────────────────
  double fuliza = 0;
  try {
    final row = await db.customSelect(
      'SELECT COALESCE(outstanding_balance, 0) AS bal FROM fuliza_loans WHERE user_id = ? ORDER BY id DESC LIMIT 1',
      variables: [Variable(userId)],
    ).getSingleOrNull();
    fuliza = (row?.data['bal'] as num?)?.toDouble() ?? 0;
  } catch (_) {}

  // ── 5. Budgets ────────────────────────────────────────────────────────────
  List<({String name, double limit, double spent})> budgets = [];
  try {
    final rows = await db.customSelect(
      'SELECT name, monthly_limit FROM budgets WHERE user_id = ? AND deleted_at IS NULL LIMIT 8',
      variables: [Variable(userId)],
    ).get();
    budgets = rows.map((r) {
      final name = r.data['name'] as String? ?? 'Budget';
      final limit = (r.data['monthly_limit'] as num?)?.toDouble() ?? 0;
      return (name: name, limit: limit, spent: 0.0);
    }).toList();
    // Enrich with actual spending per budget (best-effort, no error on miss).
    if (budgets.isNotEmpty) {
      for (var i = 0; i < budgets.length; i++) {
        try {
          final spentRow = await db.customSelect(
            '''SELECT COALESCE(SUM(amount), 0) AS s FROM transactions
               WHERE user_id = ? AND date >= ? AND deleted_at IS NULL
                 AND UPPER(category) = UPPER(?)''',
            variables: [Variable(userId), Variable(monthStart), Variable(budgets[i].name)],
          ).getSingleOrNull();
          final s = (spentRow?.data['s'] as num?)?.toDouble() ?? 0;
          budgets[i] = (name: budgets[i].name, limit: budgets[i].limit, spent: s);
        } catch (_) {}
      }
    }
  } catch (_) {}

  return _LiveContext(
    monthSpentKsh: monthSpent,
    topCategory: topCat,
    pendingTasksCount: pendingTasks,
    upcomingEventsCount: upcomingEvents,
    fulizaBalance: fuliza,
    budgets: budgets,
  );
}

// ── Offline engine (real data aware) ────────────────────────────────────────

class OfflineAssistantEngine {
  /// Reply using real [ctx] when available, falling back to generic guidance.
  static String reply(String prompt, [_LiveContext? ctx]) {
    final q = prompt.toLowerCase();

    if (q.contains('spend') || q.contains('expense') || q.contains('money') || q.contains('how much')) {
      if (ctx != null && ctx.monthSpentKsh > 0) {
        final spent = 'KSh ${ctx.monthSpentKsh.toStringAsFixed(0)}';
        final top = ctx.topCategory.isNotEmpty
            ? ' Your top spending category is ${ctx.topCategory}.'
            : '';
        return 'This month you have spent $spent.$top Check Finance for the full breakdown by category and merchant.';
      }
      return 'Open Finance to see your spending this month. Your Today/Week/Month '
          'metrics are on the hero card, and category breakdowns sit below the ledger.';
    }

    if (q.contains('budget')) {
      if (ctx != null && ctx.budgets.isNotEmpty) {
        final lines = ctx.budgets.map((b) {
          final pct = b.limit > 0 ? ((b.spent / b.limit) * 100).toInt() : 0;
          final statusEmoji = pct >= 100 ? '🔴' : pct >= 80 ? '🟠' : '🟢';
          return '$statusEmoji ${b.name}: KSh ${b.spent.toStringAsFixed(0)} / ${b.limit.toStringAsFixed(0)} ($pct%)';
        }).join('\n');
        return 'Here are your budgets this month:\n$lines\n\nTap Finance → Budget to adjust limits.';
      }
      return 'Budgets live in Finance → Budget. Set a monthly limit per '
          'category and the progress bar turns orange near the limit and red when you exceed it.';
    }

    if (q.contains('task') || q.contains('todo') || q.contains('to-do') || q.contains('pending')) {
      if (ctx != null) {
        final n = ctx.pendingTasksCount;
        if (n == 0) return 'Great news — you have no pending tasks! Tap Calendar → Tasks to add new ones.';
        return 'You have $n pending task${n == 1 ? '' : 's'}. Tap the Tasks card on Home or go to Calendar → Tasks to review them.';
      }
      return 'Your pending tasks are on Home and under Calendar → Tasks. Tap the '
          'circle on a row to mark it complete.';
    }

    if (q.contains('event') || q.contains('calendar') || q.contains('birthday') || q.contains('upcoming')) {
      if (ctx != null) {
        final n = ctx.upcomingEventsCount;
        if (n == 0) return 'No events in the next 7 days. Use the + button in Calendar to add one.';
        return 'You have $n event${n == 1 ? '' : 's'} in the next 7 days. Open Calendar to see the details.';
      }
      return 'Calendar shows upcoming events by month. Use the + button to add '
          'events, birthdays or countdowns — reminders fire automatically.';
    }

    if (q.contains('fuliza')) {
      if (ctx != null && ctx.fulizaBalance > 0) {
        return 'Your current Fuliza outstanding balance is KSh ${ctx.fulizaBalance.toStringAsFixed(0)}. '
            'Repayments are tracked automatically from your M-Pesa messages.';
      }
      if (ctx != null && ctx.fulizaBalance == 0) {
        return 'No outstanding Fuliza balance found. If you have drawn recently, import your M-Pesa SMS from Finance to update this.';
      }
      return 'Fuliza draws and repayments are tracked from your M-Pesa messages. '
          'Check Finance for the outstanding banner once activity is imported.';
    }

    if (q.contains('summary') || q.contains('overview') || q.contains('how am i doing')) {
      if (ctx != null) {
        final spent = ctx.monthSpentKsh > 0
            ? 'spent KSh ${ctx.monthSpentKsh.toStringAsFixed(0)} this month'
            : 'no spending recorded yet';
        final tasks = ctx.pendingTasksCount > 0
            ? '${ctx.pendingTasksCount} pending task${ctx.pendingTasksCount == 1 ? '' : 's'}'
            : 'no pending tasks';
        final events = ctx.upcomingEventsCount > 0
            ? '${ctx.upcomingEventsCount} event${ctx.upcomingEventsCount == 1 ? '' : 's'} coming up'
            : 'no upcoming events';
        return 'Here\'s your quick summary:\n• You\'ve $spent\n• $tasks\n• $events\n\n'
            'Need more detail on any of these?';
      }
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
      return 'I can show you real data from your app — spending totals, budget status, '
          'pending tasks, upcoming events, and Fuliza balance. Ask things like:\n'
          '• "How is my spending this month?"\n'
          '• "Show my budgets"\n'
          '• "What tasks are pending?"\n'
          '• "Give me a summary"';
    }
    return 'I have access to your real spending, budgets, tasks, and events. Try asking '
        '"How is my spending this month?", "Show my budgets", or "Give me a summary".';
  }
}

const List<String> _kSuggestedPrompts = [
  'How is my spending this month?',
  'Show my budgets',
  'What tasks are pending?',
  'Give me a quick summary',
];

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _listController = ScrollController();
  bool _processing = false;
  bool _showClearConfirm = false;
  int _seq = 0;
  double _prevImeBottom = 0;
  bool _quickSuggestions = true;
  List<String> _suggestedPrompts = _kSuggestedPrompts;
  _LiveContext? _liveCtx;

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
    // Personalise and load live data.
    SharedPreferences.getInstance().then((prefs) async {
      if (!mounted) return;
      final goal = prefs.getString('onboarding_primary_goal') ?? 'PRODUCTIVITY';
      final greeting = switch (goal) {
        'FINANCE' =>
          'Hi! I can help you track spending, review budgets, and understand your M-Pesa activity. What would you like to know?',
        'BALANCED' =>
          'Hi! I connect your money, tasks, and calendar so nothing falls through. Ask me anything.',
        _ => null,
      };
      final prompts = switch (goal) {
        'FINANCE' => const [
            'How is my spending this month?',
            'Show my budgets',
            'Any Fuliza activity?',
            'Give me a quick summary',
          ],
        'BALANCED' => const [
            'Give me a quick summary',
            'What tasks are pending?',
            'Any events coming up?',
            'How is my spending?',
          ],
        _ => _kSuggestedPrompts,
      };
      if (!mounted) return;
      setState(() {
        _quickSuggestions = prefs.getBool('quick_suggestions') ?? true;
        _suggestedPrompts = prompts;
        if (greeting != null && _messages.length == 1) {
          _messages[0] = ChatMessage(
            id: _messages[0].id,
            role: 'assistant',
            content: greeting,
            createdAt: _messages[0].createdAt,
          );
        }
      });

      // Load real-data context from DB.
      try {
        final db = await ref.read(lifeOsDatabaseProvider.future);
        final userId = await ref.read(userIdProvider.future);
        final ctx = await _loadLiveContext(db, userId);
        if (!mounted) return;
        setState(() => _liveCtx = ctx);
      } catch (_) {
        // DB not ready yet — engine falls back to generic guidance.
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _listController.dispose();
    super.dispose();
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
    // Capture current context snapshot for the reply closure.
    final ctx = _liveCtx;
    Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: _seq++,
          role: 'assistant',
          content: OfflineAssistantEngine.reply(prompt, ctx),
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
    // resizeToAvoidBottomInset is false on MainShell's Scaffold so the keyboard
    // overlaps from below without shrinking the body. Manually compute gap.
    //
    // Closed: gap = safeBottom + navBar(58) + offset(4) + hairline(8)
    // Open  : gap = IME height + 8
    final imeBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    if (imeBottom > 0 && _prevImeBottom == 0) _autoScroll();
    _prevImeBottom = imeBottom;

    final inputBottomGap = imeBottom > 0
        ? imeBottom + AppDesignTokens.assistantInputHairlineGap
        : safeBottom +
            AppDesignTokens.floatingNavBarHeight +
            AppDesignTokens.floatingNavBarBottomOffset +
            AppDesignTokens.assistantInputHairlineGap;

    if (_showClearConfirm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_showClearConfirm) return;
        setState(() => _showClearConfirm = false);
        showDialog<void>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: Theme.of(dialogCtx).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            title: Text('Clear chat history?',
                style: Theme.of(dialogCtx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            content: const Text(
                'This will remove your current assistant conversation and start a fresh one.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  if (!mounted) return;
                  setState(() => _messages.removeRange(1, _messages.length));
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
              itemCount: _messages.length +
                  (_messages.length <= 1 && _quickSuggestions ? 1 : 0) +
                  (_processing ? 1 : 0),
              itemBuilder: (context, i) {
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
                if (_processing &&
                    i == _messages.length + (_messages.length <= 1 ? 1 : 0)) {
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
          // AnimatedContainer slides smoothly with the keyboard.
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

// ── ChatMessage model ────────────────────────────────────────────────────────

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
        child: Text(message.content, style: Theme.of(context).textTheme.bodyMedium),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                  borderSide:
                      BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                  borderSide:
                      BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
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
      ),
    );
  }
}

// ── TypingIndicator ──────────────────────────────────────────────────────────

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
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: scheme.primary),
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
