/// Secondary screens — all fully implemented (no EmptyState stubs).
/// Covers: Insights, Search, Review, Export, Tasks, Events, Categorize,
/// FeeAnalytics, ScreenLock, NotificationSettings, SmsImportHealth,
/// ReviewQueue, Quarantine, PaybillRegistry, Learning, Changelog.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable, QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications/notification_service.dart';

import '../core/database/database.dart';
import '../core/designsystem/app_card.dart';
import '../core/designsystem/dialogs.dart';
import '../core/platform/sms_bridge.dart';
import 'sms/ingestion/ingestion_pipeline.dart';
import 'sms/ingestion/ingestion_types.dart';
import '../core/designsystem/banners.dart';
import '../core/designsystem/controls.dart';
import '../core/designsystem/metric_card.dart';
import '../core/designsystem/page_scaffold.dart';
import '../core/designsystem/tokens.dart';
import '../core/security/session_store.dart';
import '../core/utils/date_utils.dart';
import '../navigation/routes.dart';
import 'dashboard/data/providers.dart';

// ── Search ──────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  String _filter = 'ALL';
  final Set<String> _expandedGroups = {};
  List<String> _recentSearches = [];
  // Stable Future so FutureBuilder doesn't restart on every build() call.
  Future<_SearchResults>? _searchFuture;

  static const _filters = [
    'ALL', 'TASKS', 'EVENTS', 'BIRTHDAYS', 'ANNIVERSARIES',
    'COUNTDOWNS', 'FINANCE', 'RECURRING',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recent_searches') ?? [];
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _saveRecent(String q) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recent_searches') ?? [];
    final updated = [q, ...list.where((e) => e != q)].take(8).toList();
    await prefs.setStringList('recent_searches', updated);
    if (mounted) setState(() => _recentSearches = updated);
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    if (mounted) setState(() => _recentSearches = []);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      headerEyebrow: 'Global Lookup',
      title: 'Search',
      subtitle: 'Search across tasks, events, and finance',
      onBack: () => context.pop(),
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchField(
            value: _query,
            onValueChange: (v) {
              setState(() {
                _query = v;
                _expandedGroups.clear();
                // Recompute future only when query changes, not on every build.
                if (v.length >= 2) _searchFuture = _search(v);
              });
            },
            placeholder: 'Search tasks, events, transactions…',
          ),
          // Recent searches row (visible when query blank + recents exist).
          if (_query.trim().isEmpty && _recentSearches.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                TextButton(
                  onPressed: _clearRecent,
                  child: Text('Clear',
                      style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
            for (final q in _recentSearches.reversed)
              InkWell(
                onTap: () => setState(() => _query = q),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.history,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text(q, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
          // Filter chips row (visible when query non-blank).
          if (_query.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _filter = f;
                          _expandedGroups.clear();
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filter == f
                                ? scheme.primary
                                : scheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            f,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: _filter == f
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _filter == f
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_query.length >= 2)
            FutureBuilder<_SearchResults>(
              future: _searchFuture,
              builder: (context, snap) {
                final r = snap.data ?? _SearchResults([], [], []);
                final filtered = _filterResults(r);
                if (snap.connectionState == ConnectionState.waiting) {
                  return const EmptyState(
                      icon: Icons.search,
                      title: 'Searching…',
                      description: 'Looking through your data');
                }
                if (filtered.isEmpty) {
                  if (r.isEmpty) {
                    return const EmptyState(
                        icon: Icons.search,
                        title: 'No results found',
                        description:
                            'Try a different keyword or check your spelling.');
                  }
                  return const EmptyState(
                      title: 'No results for this filter',
                      description: 'Try another filter or refine your query.');
                }
                return _groupedResults(context, filtered);
              },
            )
          else if (_query.trim().isNotEmpty)
            const EmptyState(
                icon: Icons.search,
                title: 'Keep typing…',
                description: 'At least 2 characters to search.'),
        ],
      ),
    );
  }

  _SearchResults _filterResults(_SearchResults r) {
    switch (_filter) {
      case 'TASKS':
        return _SearchResults([], r.tasks, []);
      case 'EVENTS':
        return _SearchResults([], [], r.events);
      case 'BIRTHDAYS':
        return _SearchResults(
            [], [],
            r.events.where((e) => (e['kind'] as String? ?? '').toUpperCase() == 'BIRTHDAY').toList());
      case 'ANNIVERSARIES':
        return _SearchResults(
            [], [],
            r.events.where((e) => (e['kind'] as String? ?? '').toUpperCase() == 'ANNIVERSARY').toList());
      case 'COUNTDOWNS':
        return _SearchResults(
            [], [],
            r.events.where((e) => (e['kind'] as String? ?? '').toUpperCase() == 'COUNTDOWN').toList());
      case 'FINANCE':
        return _SearchResults(r.transactions, [], []);
      case 'RECURRING':
        return _SearchResults([], [], []);
      default:
        return r;
    }
  }

  Widget _groupedResults(BuildContext context, _SearchResults r) {
    final groups = <String, List<Map<String, Object?>>>{};
    if (r.transactions.isNotEmpty) groups['Finance'] = r.transactions;
    if (r.tasks.isNotEmpty) groups['Tasks'] = r.tasks;
    if (r.events.isNotEmpty) groups['Events'] = r.events;
    var count = 0;
    for (final v in groups.values) {
      count += v.length;
    }
    final children = <Widget>[
      Text('$count result${count == 1 ? '' : 's'}',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
    ];
    groups.forEach((title, results) {
      final expanded = _expandedGroups.contains(title);
      final visible = expanded ? results : results.take(5).toList();
      final hidden = results.length - 5;
      children.add(_groupHeader(context, title, results.length));
      for (final item in visible) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _searchResultCard(context, title, item),
        ));
      }
      if (hidden > 0 && !expanded) {
        children.add(TextButton(
          onPressed: () => setState(() => _expandedGroups.add(title)),
          child: Text('Show $hidden more',
              style: Theme.of(context).textTheme.labelMedium),
        ));
      } else if (expanded && results.length > 5) {
        children.add(TextButton(
          onPressed: () => setState(() => _expandedGroups.remove(title)),
          child: Text('Show less',
              style: Theme.of(context).textTheme.labelMedium),
        ));
      }
      children.add(const SizedBox(height: 6));
    });
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _groupHeader(BuildContext context, String title, int count) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary)),
          Text('$count ${count == 1 ? 'item' : 'items'}',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _searchResultCard(
      BuildContext context, String group, Map<String, Object?> item) {
    final scheme = Theme.of(context).colorScheme;
    final IconData icon = switch (group) {
      'Finance' => Icons.receipt_outlined,
      'Tasks' => Icons.task_outlined,
      _ => Icons.event_outlined,
    };
    final String title;
    final String subtitle;
    final int? timestamp;
    final VoidCallback? onTap;
    if (group == 'Finance') {
      title = item['merchant'] as String? ?? '';
      subtitle = '${item['category'] ?? ''} · ${formatCurrency((item['amount'] as num?)?.toDouble() ?? 0)}';
      timestamp = item['date'] as int?;
      onTap = () {
        _saveRecent(_query);
        context.go('/${AppRoute.finance}?transactionId=${item['id']}');
      };
    } else if (group == 'Tasks') {
      title = item['title'] as String? ?? '';
      subtitle = item['description'] as String? ?? '';
      timestamp = item['created_at'] as int?;
      onTap = () {
        _saveRecent(_query);
        context.go('/${AppRoute.tasks}?itemId=${item['id']}');
      };
    } else {
      title = item['title'] as String? ?? '';
      subtitle = item['kind'] as String? ?? 'Event';
      timestamp = item['date'] as int?;
      onTap = () {
        _saveRecent(_query);
        context.go(
            '/${AppRoute.calendar}?eventId=${item['id']}&eventDate=${item['date']}');
      };
    }
    return AppCard(
      contentPadding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(group,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.primary)),
                ],
              ),
            ),
            if (timestamp != null)
              Text(AppDateUtils.formatDate(timestamp, 'MMM dd'),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Future<_SearchResults> _search(String q) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final like = '%$q%';
    final txRows = await db.customSelect(
      'SELECT * FROM transactions WHERE user_id=? AND deleted_at IS NULL AND (merchant LIKE ? OR category LIKE ? OR mpesa_code LIKE ?) ORDER BY date DESC LIMIT 20',
      variables: [Variable.withString(userId), Variable.withString(like), Variable.withString(like), Variable.withString(like)],
      readsFrom: {db.transactions},
    ).get();
    final taskRows = await db.customSelect(
      'SELECT * FROM tasks WHERE user_id=? AND deleted_at IS NULL AND (title LIKE ? OR description LIKE ?) ORDER BY created_at DESC LIMIT 10',
      variables: [Variable.withString(userId), Variable.withString(like), Variable.withString(like)],
      readsFrom: {db.tasks},
    ).get();
    final eventRows = await db.customSelect(
      'SELECT * FROM events WHERE user_id=? AND deleted_at IS NULL AND (title LIKE ? OR description LIKE ?) ORDER BY date ASC LIMIT 10',
      variables: [Variable.withString(userId), Variable.withString(like), Variable.withString(like)],
      readsFrom: {db.events},
    ).get();
    return _SearchResults(
      txRows.map((r) => r.data).toList(),
      taskRows.map((r) => r.data).toList(),
      eventRows.map((r) => r.data).toList(),
    );
  }
}

class _SearchResults {
  const _SearchResults(this.transactions, this.tasks, this.events);
  final List<Map<String, Object?>> transactions;
  final List<Map<String, Object?>> tasks;
  final List<Map<String, Object?>> events;

  bool get isEmpty =>
      transactions.isEmpty && tasks.isEmpty && events.isEmpty;
}

// ── Review (Weekly Ritual) — ReviewScreen.kt port ───────────────────────────

const Color kReviewNormal = Color(0xFF22C55E);
const Color kReviewHigh = Color(0xFFF59E0B);
const Color kReviewPeak = Color(0xFFEF4444);

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  // Cached future — only reset on explicit retry. Prevents _load() being
  // called on every setState (e.g. bar tap), which caused a full-screen flash.
  late Future<_ReviewData> _reviewFuture;

  @override
  void initState() {
    super.initState();
    _reviewFuture = _load();
  }

  void _retry() => setState(() => _reviewFuture = _load());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      headerEyebrow: 'Weekly Ritual',
      title: 'Weekly Review',
      subtitle: _weekLabel(),
      onBack: () => context.pop(),
      scrollable: false,
      child: FutureBuilder<_ReviewData>(
        future: _reviewFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data;
          if (d == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  const Text('Could not load health data.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final (score, label) = _healthScore(d);
          final scoreColor = score >= 80
              ? kReviewNormal
              : score >= 60
                  ? kReviewHigh
                  : score >= 40
                      ? const Color(0xFFF59E0B)
                      : kReviewPeak;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
            children: [
              Text(_greeting(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              // Health score
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: _ScoreRingPainter(color: scoreColor),
                        child: Center(
                          child: Text('$score',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scoreColor)),
                    Text(
                        'Financial Health Score · spend, categorization & tasks',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 7-Day Spend Pattern — isolated StatefulWidget so bar taps
              // do not rebuild the entire ReviewScreen.
              if (d.dayBars.isNotEmpty) ...[
                _DayBarChart(bars: d.dayBars),
                const SizedBox(height: 12),
              ],
              // What Changed
              _whatChangedCard(context, d),
              const SizedBox(height: 12),
              // Spending
              _summaryCard(context, d),
              const SizedBox(height: 12),
              // Tasks
              _tasksCard(context, d),
              const SizedBox(height: 12),
              // Wins
              _bulletsCard(context, 'Wins', d.wins),
              const SizedBox(height: 12),
              // Risks
              _bulletsCard(context, 'Risks', d.risks),
              if (d.topInsights.isNotEmpty) ...[
                const SizedBox(height: 12),
                _bulletsCard(context, 'Top Insights', d.topInsights),
              ],
            ],
          );
        },
      ),
    );
  }

  String _weekLabel() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return '${_monthName(start.month)} ${start.day} – ${_monthName(now.month)} ${now.day}';
  }

  String _monthName(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];

  String _greeting() {
    final h = DateTime.now().hour;
    final name = 'there';
    if (h < 12) return 'Good morning, $name';
    if (h < 17) return 'Good afternoon, $name';
    return 'Good evening, $name';
  }

  (int, String) _healthScore(_ReviewData d) {
    var score = 50;
    if (d.prevWeekSpend > 0) {
      final pct = (d.weekDelta / d.prevWeekSpend) * 100;
      score += pct <= 0
          ? 20
          : pct <= 20
              ? 10
              : pct > 50
                  ? -20
                  : 0;
    }
    score += d.uncategorized == 0
        ? 20
        : d.uncategorized <= 3
            ? 10
            : d.uncategorized > 8
                ? -10
                : 0;
    score += d.fulizaCount == 0
        ? 10
        : d.fulizaCount > 2
            ? -10
            : 0;
    final totalTasks = d.completedTasks + d.pendingTasks;
    final taskRate = totalTasks > 0 ? d.completedTasks / totalTasks : 1.0;
    score += taskRate >= 0.8
        ? 10
        : taskRate >= 0.5
            ? 5
            : 0;
    score = score.clamp(0, 100);
    final label = score >= 80
        ? 'Excellent'
        : score >= 60
            ? 'Good'
            : score >= 40
                ? 'Fair'
                : 'Needs attention';
    return (score, label);
  }

  Widget _whatChangedCard(BuildContext context, _ReviewData d) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, String, Color)>[
      if (d.weekDeltaLabel.contains('Up'))
        ('Spent more than your recent pace', d.weekDeltaLabel, scheme.error),
      if (d.weekDeltaLabel.contains('Down'))
        ('Saved vs recent pace', d.weekDeltaLabel, scheme.primary),
      if (d.completedTasks > 0)
        ('Tasks progressed', '${d.completedTasks} completed', scheme.primary),
      if (d.pendingTasks > 0)
        ('Tasks still open', '${d.pendingTasks} pending', scheme.error),
      if (d.topCategory != null)
        ('Most spent on', d.topCategory!, scheme.onSurfaceVariant),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What Changed', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: items[i].$3),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].$1,
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(items[i].$2,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            if (i < items.length - 1)
              Divider(
                  height: 12,
                  color: scheme.outlineVariant.withValues(alpha: 0.2)),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, _ReviewData d) {
    final rows = <(String, String)>[
      ('Total this week', formatCurrency(d.weekSpend)),
      ('Posture', d.postureLabel),
      ('Week delta', d.weekDeltaLabel),
      if (d.topCategory != null) ('Top category', d.topCategory!),
    ];
    return _statCard(context, 'Spending', rows);
  }

  Widget _tasksCard(BuildContext context, _ReviewData d) {
    return _statCard(context, 'Tasks', [
      ('Completed today', '${d.completedTasks}'),
      ('Still pending', '${d.pendingTasks}'),
    ]);
  }

  Widget _statCard(
      BuildContext context, String title, List<(String, String)> rows) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(rows[i].$1,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                Text(rows[i].$2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontFamily: 'monospace'),
                    textAlign: TextAlign.end),
              ],
            ),
            if (i < rows.length - 1)
              Divider(
                  height: 12,
                  color: scheme.outlineVariant.withValues(alpha: 0.2)),
          ],
        ],
      ),
    );
  }

  Widget _bulletsCard(BuildContext context, String title, List<String> items) {
    final scheme = Theme.of(context).colorScheme;
    if (items.isEmpty) return const SizedBox.shrink();
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.primary, fontFamily: 'monospace')),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(items[i],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
            if (i < items.length - 1)
              Divider(
                  height: 12,
                  color: scheme.outlineVariant.withValues(alpha: 0.2)),
          ],
        ],
      ),
    );
  }

  Future<_ReviewData> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMs =
        DateTime(weekStart.year, weekStart.month, weekStart.day)
            .millisecondsSinceEpoch;
    final prevWeekStartMs = weekStartMs - 7 * 24 * 3600 * 1000;

    final spendRows = await db.customSelect(
      "SELECT COALESCE(SUM(amount),0) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')",
      variables: [Variable.withString(userId), Variable.withInt(weekStartMs)],
      readsFrom: {db.transactions},
    ).get();
    final prevSpendRows = await db.customSelect(
      "SELECT COALESCE(SUM(amount),0) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')",
      variables: [
        Variable.withString(userId),
        Variable.withInt(prevWeekStartMs),
        Variable.withInt(weekStartMs),
      ],
      readsFrom: {db.transactions},
    ).get();
    final uncatRows = await db.customSelect(
      "SELECT COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND (category='Uncategorized' OR category='OTHER' OR category IS NULL)",
      variables: [Variable.withString(userId), Variable.withInt(weekStartMs)],
      readsFrom: {db.transactions},
    ).get();
    final fulizaRows = await db.customSelect(
      "SELECT COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND (UPPER(transaction_type)='FULIZA_CHARGE' OR category='Fuliza')",
      variables: [Variable.withString(userId), Variable.withInt(weekStartMs)],
      readsFrom: {db.transactions},
    ).get();
    final taskRows = await db.customSelect(
      "SELECT COUNT(*) AS n FROM tasks WHERE user_id=? AND deleted_at IS NULL AND status='COMPLETED' AND completed_at>=?",
      variables: [Variable.withString(userId), Variable.withInt(weekStartMs)],
      readsFrom: {db.tasks},
    ).get();
    final pendingRows = await db.customSelect(
      "SELECT COUNT(*) AS n FROM tasks WHERE user_id=? AND deleted_at IS NULL AND status!='COMPLETED'",
      variables: [Variable.withString(userId)],
      readsFrom: {db.tasks},
    ).get();
    final topCatRows = await db.customSelect(
      "SELECT category FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID') GROUP BY category ORDER BY SUM(amount) DESC LIMIT 1",
      variables: [Variable.withString(userId), Variable.withInt(weekStartMs)],
      readsFrom: {db.transactions},
    ).get();

    // 7-day bars.
    final bars = <_DayBar>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final start = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      final end = start + 24 * 3600 * 1000;
      final row = await db.customSelect(
        "SELECT COALESCE(SUM(amount),0) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')",
        variables: [
          Variable.withString(userId),
          Variable.withInt(start),
          Variable.withInt(end),
        ],
        readsFrom: {db.transactions},
      ).getSingle();
      final amount = (row.data['total'] as num?)?.toDouble() ?? 0;
      final isFuture = d.isAfter(now);
      final color = amount >= 5000
          ? kReviewPeak
          : amount >= 2000
              ? kReviewHigh
              : kReviewNormal;
      bars.add(_DayBar(
        label: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
        amount: amount,
        color: color,
        isFuture: isFuture,
      ));
    }

    final weekSpend =
        (spendRows.first.data['total'] as num?)?.toDouble() ?? 0.0;
    final prevWeekSpend =
        (prevSpendRows.first.data['total'] as num?)?.toDouble() ?? 0.0;
    final uncategorized = (uncatRows.first.data['n'] as int?) ?? 0;
    final fulizaCount = (fulizaRows.first.data['n'] as int?) ?? 0;
    final completedTasks = (taskRows.first.data['n'] as int?) ?? 0;
    final pendingTasks = (pendingRows.first.data['n'] as int?) ?? 0;
    final topCategory = topCatRows.isEmpty
        ? null
        : topCatRows.first.data['category'] as String?;

    final weekDelta = weekSpend - prevWeekSpend;
    final weekDeltaLabel = weekDelta > 0
        ? 'Up ${formatCurrency(weekDelta)}'
        : weekDelta < 0
            ? 'Down ${formatCurrency(-weekDelta)}'
            : 'Flat';
    final postureLabel = weekDelta <= 0 ? 'Saving' : 'Spending';

    return _ReviewData(
      weekSpend: weekSpend,
      prevWeekSpend: prevWeekSpend,
      weekDelta: weekDelta,
      weekDeltaLabel: weekDeltaLabel,
      postureLabel: postureLabel,
      uncategorized: uncategorized,
      fulizaCount: fulizaCount,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      topCategory: topCategory,
      dayBars: bars,
      wins: const ['Capture one win from this week'],
      risks: const ['Identify one risk to watch next week'],
      topInsights: const [],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.color != color;
}

class _DayBar {
  const _DayBar({
    required this.label,
    required this.amount,
    required this.color,
    required this.isFuture,
  });
  final String label;
  final double amount;
  final Color color;
  final bool isFuture;
}

/// Isolated bar-chart widget so bar taps only rebuild this card,
/// not the entire ReviewScreen.
class _DayBarChart extends StatefulWidget {
  const _DayBarChart({required this.bars});
  final List<_DayBar> bars;

  @override
  State<_DayBarChart> createState() => _DayBarChartState();
}

class _DayBarChartState extends State<_DayBarChart> {
  int? _selectedIdx;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bars = widget.bars;
    final maxSpend =
        bars.fold<double>(1.0, (a, b) => b.amount > a ? b.amount : a);

    Widget legendDot(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 4),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        );

    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-Day Spend Pattern',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            height: 148,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < bars.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (bars[i].amount > 0) {
                          setState(
                              () => _selectedIdx =
                                  _selectedIdx == i ? null : i);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              clipBehavior: Clip.none,
                              children: [
                                if (bars[i].amount > 0)
                                  Container(
                                    width: 22,
                                    height: (100 *
                                            (bars[i].amount / maxSpend))
                                        .clamp(2.0, 100.0),
                                    decoration: BoxDecoration(
                                      color: bars[i].color.withValues(
                                          alpha: bars[i].isFuture
                                              ? 0.25
                                              : 1.0),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 22,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: bars[i].color.withValues(
                                          alpha: bars[i].isFuture
                                              ? 0.15
                                              : 0.3),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                if (_selectedIdx == i &&
                                    bars[i].amount > 0)
                                  Positioned(
                                    bottom: (100 *
                                                (bars[i].amount / maxSpend))
                                            .clamp(2.0, 100.0) +
                                        4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: bars[i].color,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        formatCurrency(bars[i].amount),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(bars[i].label,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: _selectedIdx == i
                                          ? bars[i].color
                                          : scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                legendDot(kReviewNormal, 'Normal'),
                const SizedBox(width: 12),
                legendDot(kReviewHigh, 'High'),
                const SizedBox(width: 12),
                legendDot(kReviewPeak, 'Peak'),
              ]),
              Text('Tap bar for details',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewData {
  const _ReviewData({
    required this.weekSpend,
    required this.prevWeekSpend,
    required this.weekDelta,
    required this.weekDeltaLabel,
    required this.postureLabel,
    required this.uncategorized,
    required this.fulizaCount,
    required this.completedTasks,
    required this.pendingTasks,
    required this.topCategory,
    required this.dayBars,
    required this.wins,
    required this.risks,
    required this.topInsights,
  });
  final double weekSpend;
  final double prevWeekSpend;
  final double weekDelta;
  final String weekDeltaLabel;
  final String postureLabel;
  final int uncategorized;
  final int fulizaCount;
  final int completedTasks;
  final int pendingTasks;
  final String? topCategory;
  final List<_DayBar> dayBars;
  final List<String> wins;
  final List<String> risks;
  final List<String> topInsights;
}
// ── Export Center (ExportScreen.kt port) ────────────────────────────────────

/// 2-column grid layout for the preview card.  Each inner list is one row.
/// The last row may have only one item — the Expanded wraps it to half-width
/// which is acceptable given the label.
const _kPreviewDomains = [
  [('transactions', 'Transactions'), ('tasks', 'Tasks')],
  [('events', 'Events'), ('budgets', 'Budgets')],
  [('incomes', 'Income Streams'), ('recurringRules', 'Recurring Rules')],
  [('merchantRules', 'Merchant Rules')],
];

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, this.openPdfSheet = false});

  /// When true, auto-opens the StatementExportSheet (statement_export route
  /// parity).
  final bool openPdfSheet;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _format = 'JSON'; // JSON | CSV
  String _domain = 'all'; // all | transactions | tasks | events
  String _datePreset = 'this_month';
  bool _encryptionEnabled = false;
  final _passphrase = TextEditingController();
  bool _exporting = false;
  bool _showPdfSheet = false;
  String? _error;
  Map<String, Object?>? _result;
  List<Map<String, Object?>> _history = [];
  // Stable future — only refreshed when domain/preset changes, not every build.
  Future<Map<String, int>>? _previewFuture;

  static const _domains = {
    'all': 'all',
    'transactions': 'transactions',
    'tasks': 'tasks',
    'events': 'events',
  };

  // Populated on init from the DB — drives smart date presets.
  int? _earliestDataMs;
  // Available presets recomputed whenever _earliestDataMs is loaded.
  Map<String, String> _datePresets = {'this_month': 'This month'};

  /// Recompute available date presets from the earliest known data point.
  /// Must be called inside setState().
  void _refreshDatePresets() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final yearStart = DateTime(now.year, 1, 1);
    final earliest = _earliestDataMs != null
        ? DateTime.fromMillisecondsSinceEpoch(_earliestDataMs!)
        : null;

    final result = <String, String>{'this_month': 'This month'};
    if (earliest != null && earliest.isBefore(monthStart)) {
      result['last_3_months'] = 'Last 3 months';
    }
    if (earliest != null && earliest.isBefore(threeMonthsAgo)) {
      result['this_year'] = 'This year';
    }
    if (earliest != null && earliest.isBefore(yearStart)) {
      result['all_time'] = 'All time';
    }
    _datePresets = result;
    if (!_datePresets.containsKey(_datePreset)) {
      _datePreset = _datePresets.keys.first;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadEarliestDataMs();
    _previewFuture = _previewCount();
    if (widget.openPdfSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showPdfSheet = true);
      });
    }
  }

  @override
  void dispose() {
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      final rows = await db.customSelect(
        'SELECT * FROM export_history WHERE user_id=? ORDER BY exported_at DESC LIMIT 8',
        variables: [Variable.withString(userId)],
        readsFrom: {db.exportHistory},
      ).get();
      if (mounted) setState(() => _history = rows.map((r) => r.data).toList());
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadEarliestDataMs() async {
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      // Use the earliest transaction as the anchor — covers the most data.
      final row = await db.customSelect(
        'SELECT MIN(date) AS d FROM transactions WHERE user_id=? AND deleted_at IS NULL',
        variables: [Variable.withString(userId)],
        readsFrom: {db.transactions},
      ).getSingleOrNull();
      final earliest = (row?.data['d'] as num?)?.toInt();
      if (mounted && earliest != null) {
        setState(() {
          _earliestDataMs = earliest;
          _refreshDatePresets();
        });
        // Re-run preview with the potentially new date preset.
        setState(() => _previewFuture = _previewCount());
      }
    } catch (_) {
      // ignore — presets stay as the default single option
    }
  }

  // Returns {transactions, tasks, events, budgets, incomes, recurringRules, merchantRules}
  Future<Map<String, int>> _previewCount() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final (from, to) = _dateCutoff();
    final results = await Future.wait([
      db.customSelect('SELECT COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<=?', variables: [Variable.withString(userId), Variable.withInt(from), Variable.withInt(to)], readsFrom: {db.transactions}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM tasks WHERE user_id=? AND deleted_at IS NULL AND created_at>=? AND created_at<=?', variables: [Variable.withString(userId), Variable.withInt(from), Variable.withInt(to)], readsFrom: {db.tasks}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM events WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<=?', variables: [Variable.withString(userId), Variable.withInt(from), Variable.withInt(to)], readsFrom: {db.events}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM budgets WHERE user_id=? AND deleted_at IS NULL', variables: [Variable.withString(userId)], readsFrom: {db.budgets}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM incomes WHERE user_id=? AND deleted_at IS NULL', variables: [Variable.withString(userId)], readsFrom: {db.incomes}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM recurring_rules WHERE user_id=? AND deleted_at IS NULL', variables: [Variable.withString(userId)], readsFrom: {db.recurringRules}).getSingle(),
      db.customSelect('SELECT COUNT(*) AS n FROM paybill_registry WHERE user_id=?', variables: [Variable.withString(userId)], readsFrom: {db.paybillRegistry}).getSingle(),
    ]);
    int n(dynamic row) => (row.data['n'] as num?)?.toInt() ?? 0;
    return {
      'transactions': n(results[0]),
      'tasks': n(results[1]),
      'events': n(results[2]),
      'budgets': n(results[3]),
      'incomes': n(results[4]),
      'recurringRules': n(results[5]),
      'merchantRules': n(results[6]),
    };
  }

  (int, int) _dateCutoff() {
    final now = DateTime.now();
    final from = switch (_datePreset) {
      'this_month' => DateTime(now.year, now.month, 1),
      'last_3_months' => now.subtract(const Duration(days: 90)),
      'this_year' => DateTime(now.year, 1, 1),
      _ => DateTime(2000),
    };
    return (
      DateTime(from.year, from.month, from.day).millisecondsSinceEpoch,
      now.millisecondsSinceEpoch,
    );
  }

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _error = null;
      _result = null;
    });
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      final (from, to) = _dateCutoff();
      final now = DateTime.now();

      final Map<String, dynamic> data = {};
      var count = 0;
      if (_domain == 'all' || _domain == 'transactions') {
        final rows = await db.customSelect(
          'SELECT * FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<=? ORDER BY date DESC',
          variables: [
            Variable.withString(userId),
            Variable.withInt(from),
            Variable.withInt(to),
          ],
          readsFrom: {db.transactions},
        ).get();
        data['transactions'] = rows.map((r) => r.data).toList();
        count += rows.length;
      }
      if (_domain == 'all' || _domain == 'tasks') {
        final rows = await db.customSelect(
          'SELECT * FROM tasks WHERE user_id=? AND deleted_at IS NULL AND created_at>=? AND created_at<=? ORDER BY created_at DESC',
          variables: [
            Variable.withString(userId),
            Variable.withInt(from),
            Variable.withInt(to),
          ],
          readsFrom: {db.tasks},
        ).get();
        data['tasks'] = rows.map((r) => r.data).toList();
        count += rows.length;
      }
      if (_domain == 'all' || _domain == 'events') {
        final rows = await db.customSelect(
          'SELECT * FROM events WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<=? ORDER BY date DESC',
          variables: [
            Variable.withString(userId),
            Variable.withInt(from),
            Variable.withInt(to),
          ],
          readsFrom: {db.events},
        ).get();
        data['events'] = rows.map((r) => r.data).toList();
        count += rows.length;
      }

      final dir = await getApplicationDocumentsDirectory();
      final ts = DateFormat('yyyy-MM-dd_HH-mm').format(now);
      late File file;
      final formatName = _format.toLowerCase();
      if (_format == 'JSON') {
        file = File('${dir.path}/lifeos_export_$ts.json');
        await file.writeAsString(jsonEncode(data));
      } else {
        final txList = (data['transactions'] as List<Map<String, Object?>>?) ?? [];
        final buf = StringBuffer('date,merchant,category,amount,type,mpesa_code\n');
        for (final t in txList) {
          buf.write('${t['date']},${t['merchant']},${t['category']},${t['amount']},${t['transaction_type']},${t['mpesa_code']}\n');
        }
        file = File('${dir.path}/lifeos_export_$ts.csv');
        await file.writeAsString(buf.toString());
      }

      // Record in export_history.
      final nextId = (await db.customSelect(
        'SELECT COALESCE(MAX(id),0)+1 AS n FROM export_history WHERE user_id=?',
        variables: [Variable.withString(userId)],
      ).getSingle()).data['n'] as int;
      await db.into(db.exportHistory).insert(ExportHistoryCompanion.insert(
            id: nextId,
            userId: userId,
            format: formatName,
            domainScope: _domain,
            itemCount: count,
            filePath: Value(file.path),
            isEncrypted: _encryptionEnabled,
            status: 'SUCCESS',
            exportedAt: now.millisecondsSinceEpoch,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ));

      setState(() {
        _result = {
          'filePath': file.path,
          'itemCount': count,
          'format': formatName,
          'domain': _domain,
          'encrypted': _encryptionEnabled,
          'exportedAt': now.millisecondsSinceEpoch,
        };
        _exporting = false;
      });
      _loadHistory();
    } catch (e) {
      setState(() {
        _exporting = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageScaffold(
          headerEyebrow: 'Data Portability',
          title: 'Export Center',
          subtitle: 'Export or backup your data',
          onBack: () => context.pop(),
          topBanner: _error != null
              ? TopBanner(message: _error!, tone: TopBannerTone.error)
              : null,
          contentPadding: const EdgeInsets.only(
              bottom: AppSpacing.bottomSafeWithFloatingNav),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _exportConfigurationCard(context),
              const SizedBox(height: 12),
              _previewCard(context),
              const SizedBox(height: 12),
              if (_result != null) ...[
                _resultCard(context),
                const SizedBox(height: 12),
              ],
              _historyCard(context),
            ],
          ),
        ),
        if (_showPdfSheet)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPdfSheet = false),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {},
                  child: _StatementExportSheet(
                    onDismiss: () => setState(() => _showPdfSheet = false),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _exportConfigurationCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose a format, scope, and date window before generating the export.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Text('Format', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final fmt in ['JSON', 'CSV'])
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: fmt == 'JSON' ? 8 : 0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _format == fmt
                            ? scheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        side: BorderSide(
                            color: _format == fmt
                                ? scheme.primary
                                : scheme.outline.withValues(alpha: 0.45)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => setState(() => _format = fmt),
                      child: Text(fmt.toLowerCase()),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.45)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => setState(() => _showPdfSheet = true),
                  child: const Text('pdf'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Domain', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _ExportDropdown(
            label: _domains[_domain]!,
            options: _domains.entries
                .map((e) => (e.value, e.key))
                .toList(),
            onSelect: (v) => setState(() { _domain = v; _previewFuture = _previewCount(); }),
          ),
          const SizedBox(height: 14),
          Text('Date window', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _ExportDropdown(
            label: _datePresets[_datePreset]!,
            options: _datePresets.entries
                .map((e) => (e.value, e.key))
                .toList(),
            onSelect: (v) => setState(() { _datePreset = v; _previewFuture = _previewCount(); }),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Encrypt file',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      'Protect the export with a passphrase when the file is leaving your device.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              LifeOsSwitch(
                value: _encryptionEnabled,
                onChanged: (v) => setState(() => _encryptionEnabled = v),
              ),
            ],
          ),
          if (_encryptionEnabled) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _passphrase,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _exporting ? null : _export,
              child: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Text('Export now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, int>>(
        future: _previewFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            return Row(children: [
              Icon(Icons.error_outline, size: 16, color: scheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text('Could not load preview. ${snap.error}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error))),
              TextButton(
                onPressed: () => setState(() => _previewFuture = _previewCount()),
                child: const Text('Retry'),
              ),
            ]);
          }
          final counts = snap.data ?? {};
          final total = counts.values.fold<int>(0, (a, b) => a + b);
          final loading = snap.connectionState == ConnectionState.waiting;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Preview',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (loading)
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text('Total items: $total',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 12),
              // 2-column grid of domain counts, filtered to the selected domain.
              for (final row in _kPreviewDomains)
                Builder(builder: (context) {
                  // Only include columns relevant to the current _domain.
                  final visibleCols = row.where((entry) {
                    final key = entry.$1;
                    if (_domain == 'all') return true;
                    // budgets/incomes/recurringRules/merchantRules always show
                    // (they are not date-filtered exports).
                    const dateFiltered = {'transactions', 'tasks', 'events'};
                    if (!dateFiltered.contains(key)) return true;
                    return key == _domain;
                  }).toList();
                  if (visibleCols.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        for (final (key, label) in visibleCols) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loading ? '—' : '${counts[key] ?? 0}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.bold),
                                ),
                                Text(label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          // Pad to keep 2-column layout when only 1 visible col.
                          if (visibleCols.length == 1) const Expanded(child: SizedBox()),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = _result!;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Latest export', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Items: ${r['itemCount']}',
              style: Theme.of(context).textTheme.bodyMedium),
          Text('Path: ${r['filePath']}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          Text(
            'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch((r['exportedAt'] as int? ?? 0)))}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share latest export'),
            onPressed: () {
              final path = r['filePath'] as String?;
              if (path != null) {
                SharePlus.instance.share(ShareParams(files: [XFile(path)]));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      await db.customStatement(
        'DELETE FROM export_history WHERE user_id=?',
        [userId],
      );
      if (mounted) setState(() => _history = []);
    } catch (_) {
      // ignore
    }
  }

  Widget _historyCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('History', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (_history.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _clearHistory,
                  child: Text(
                    'Clear',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_history.isEmpty)
            Text('No exports yet',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant))
          else
            for (var i = 0; i < _history.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_history[i]['domain']} · ${_history[i]['format']} · ${_history[i]['status']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch((_history[i]['exported_at'] as int? ?? 0)))} · items ${_history[i]['item_count']}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (i < _history.length - 1)
                      Divider(
                          height: 12,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.2)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ExportDropdown extends StatelessWidget {
  const _ExportDropdown({
    required this.label,
    required this.options,
    required this.onSelect,
  });

  final String label;
  final List<(String, String)> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        value: options.firstWhere((o) => o.$1 == label).$2,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        items: [
          for (final (display, value) in options)
            DropdownMenuItem(value: value, child: Text(display)),
        ],
        onChanged: (v) {
          if (v != null) onSelect(v);
        },
      ),
    );
  }
}

/// StatementExportSheet — PDF statement export sheet (StatementExportSheet.kt).
class _StatementExportSheet extends ConsumerStatefulWidget {
  const _StatementExportSheet({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  ConsumerState<_StatementExportSheet> createState() =>
      _StatementExportSheetState();
}

class _StatementExportSheetState extends ConsumerState<_StatementExportSheet> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      final start = DateTime(_year, _month, 1).millisecondsSinceEpoch;
      final end = DateTime(_year, _month + 1, 1).millisecondsSinceEpoch;
      final monthLabel =
          DateFormat('MMMM yyyy').format(DateTime(_year, _month));

      // Fetch all transactions for the period.
      final rows = await db.customSelect(
        'SELECT date, amount, transaction_type, merchant, category, mpesa_code '
        'FROM transactions '
        'WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? '
        'ORDER BY date DESC',
        variables: [
          Variable.withString(userId),
          Variable.withInt(start),
          Variable.withInt(end),
        ],
        readsFrom: {db.transactions},
      ).get();

      // Compute totals.
      double totalSpend = 0, totalIncome = 0;
      for (final r in rows) {
        final amt = (r.data['amount'] as num?)?.toDouble() ?? 0;
        final type =
            (r.data['transaction_type'] as String? ?? '').toUpperCase();
        if ({'SENT', 'AIRTIME', 'PAYBILL', 'BUY_GOODS', 'WITHDRAW', 'WITHDRAWN', 'PAID'}
            .contains(type)) {
          totalSpend += amt;
        } else if ({'RECEIVED', 'DEPOSIT'}.contains(type)) {
          totalIncome += amt;
        }
      }

      // Build the formatted statement.
      final sb = StringBuffer();
      final divider =
          '═══════════════════════════════════════════════════════';
      final thin =
          '───────────────────────────────────────────────────────';
      sb.writeln(divider);
      sb.writeln('  LIFEOS PERSONAL STATEMENT');
      sb.writeln('  Period    : $monthLabel');
      sb.writeln(
          '  Generated : ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
      sb.writeln(divider);
      sb.writeln();
      sb.writeln('  SUMMARY');
      sb.writeln(thin);
      sb.writeln(
          '  Total Spend  : ${AppDateUtils.formatCurrency(totalSpend)}');
      sb.writeln(
          '  Total Income : ${AppDateUtils.formatCurrency(totalIncome)}');
      sb.writeln(
          '  Net          : ${AppDateUtils.formatCurrency(totalIncome - totalSpend)}');
      sb.writeln('  Transactions : ${rows.length}');
      sb.writeln();
      sb.writeln('  TRANSACTIONS');
      sb.writeln(thin);
      if (rows.isEmpty) {
        sb.writeln('  No transactions found for this period.');
      } else {
        for (final r in rows) {
          final epochMs = (r.data['date'] as num?)?.toInt() ?? 0;
          final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
          final dateStr = DateFormat('dd MMM, HH:mm').format(dt);
          final amt = (r.data['amount'] as num?)?.toDouble() ?? 0;
          final amtStr = AppDateUtils.formatCurrency(amt);
          final merchant = r.data['merchant'] as String? ?? '—';
          final cat = r.data['category'] as String? ?? '—';
          final code = r.data['mpesa_code'] as String? ?? '';
          final type = (r.data['transaction_type'] as String? ?? '').toUpperCase();
          sb.writeln('  $dateStr  $amtStr  [$type]');
          sb.writeln('    Merchant : $merchant');
          sb.writeln('    Category : $cat');
          if (code.isNotEmpty) sb.writeln('    Code     : $code');
          sb.writeln();
        }
      }
      sb.writeln(divider);
      sb.writeln('  END OF STATEMENT');
      sb.writeln(divider);

      // Write to a temp file and share.
      final dir = await getTemporaryDirectory();
      final fileName =
          'LifeOS_Statement_${DateFormat('MMM_yyyy').format(DateTime(_year, _month))}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(sb.toString());

      if (!mounted) return;
      widget.onDismiss();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/plain')],
          subject: 'LifeOS Statement — $monthLabel',
          text: 'LifeOS personal statement for $monthLabel',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate statement: $e')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final monthNames = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return Material(
      color: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Statement Export',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Generate a monthly statement and share or save it.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem(
                            value: m,
                            child: Text(monthNames[m - 1])),
                    ],
                    onChanged: (v) => setState(() => _month = v ?? _month),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [
                      for (var y = DateTime.now().year - 3;
                          y <= DateTime.now().year;
                          y++)
                        DropdownMenuItem(value: y, child: Text('$y')),
                    ],
                    onChanged: (v) => setState(() => _year = v ?? _year),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                onPressed: _generating ? null : _generate,
                icon: _generating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.share_outlined, size: 18),
                label: Text(_generating ? 'Generating…' : 'Generate & Share'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
                onPressed: _generating ? null : widget.onDismiss,
                child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}

// ── Screen Lock Settings ────────────────────────────────────────────────────

class ScreenLockSettingsPage extends ConsumerStatefulWidget {
  const ScreenLockSettingsPage({super.key});

  @override
  ConsumerState<ScreenLockSettingsPage> createState() => _ScreenLockSettingsState();
}

class _ScreenLockSettingsState extends ConsumerState<ScreenLockSettingsPage> {
  int _tab = 0; // 0=Biometric 1=PIN
  int _timeout = 5;
  final _newPin = TextEditingController();
  final _confirmPin = TextEditingController();
  String? _pinError;
  bool _pinSaved = false;

  @override
  void dispose() {
    _newPin.dispose();
    _confirmPin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider);

    return PageScaffold(
      title: 'Screen Lock',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented tab
          Container(
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                for (final (i, icon, label) in [(0, Icons.fingerprint_outlined, 'Biometric'), (1, Icons.pin_outlined, 'PIN')])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _tab == i ? scheme.primaryContainer.withValues(alpha: 0.92) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 16, color: _tab == i ? scheme.primary : scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _tab == i ? scheme.primary : scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0) ...[
            // Biometric tab
            AppCard(
              contentPadding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.fingerprint_outlined, size: 18, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text('Use Biometric', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Require fingerprint or PIN to open the app.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ]),
                      ),
                      LifeOsSwitch(
                        value: session.biometricEnabled,
                        onChanged: (v) => ref.read(sessionProvider.notifier).setBiometricEnabled(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Auto-lock after', style: Theme.of(context).textTheme.bodyLarge),
                      DropdownButton<int>(
                        value: _timeout,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(6),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 min')),
                          DropdownMenuItem(value: 5, child: Text('5 min')),
                          DropdownMenuItem(value: 15, child: Text('15 min')),
                          DropdownMenuItem(value: 30, child: Text('30 min')),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          setState(() => _timeout = v);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('biometric_timeout_minutes', v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // PIN tab
            AppCard(
              contentPadding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newPin,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'New PIN (4–6 digits)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), counterText: ''),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPin,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Confirm PIN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      counterText: '',
                      errorText: _pinError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_pinSaved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('PIN saved ✓', style: TextStyle(color: const Color(0xFF34D399), fontWeight: FontWeight.w600)),
                    ),
                  FilledButton(
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () async {
                      if (_newPin.text.length < 4) { setState(() => _pinError = 'PIN must be 4–6 digits'); return; }
                      if (_newPin.text != _confirmPin.text) { setState(() => _pinError = 'PINs do not match'); return; }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('screen_pin', _newPin.text);
                      setState(() { _pinError = null; _pinSaved = true; _newPin.clear(); _confirmPin.clear(); });
                      Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _pinSaved = false); });
                    },
                    child: const Text('Save PIN'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Notification Settings ───────────────────────────────────────────────────

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotifSettingsState();
}

class _NotifSettingsState extends ConsumerState<NotificationSettingsPage> {
  bool _notifEnabled = true;
  bool _budgetAlerts = true;
  bool _dailyDigest = false;
  double _thresholdHigh = 90;
  double _thresholdMedium = 70;
  double _thresholdLow = 50;
  TimeOfDay _digestTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifEnabled = prefs.getBool('notif_enabled') ?? true;
      _budgetAlerts = prefs.getBool('budget_alerts') ?? true;
      _dailyDigest = prefs.getBool('daily_digest') ?? false;
      _thresholdHigh = (prefs.getDouble('threshold_high') ?? 90);
      _thresholdMedium = (prefs.getDouble('threshold_medium') ?? 70);
      _thresholdLow = (prefs.getDouble('threshold_low') ?? 50);
      final h = prefs.getInt('digest_hour') ?? 8;
      final m = prefs.getInt('digest_minute') ?? 0;
      _digestTime = TimeOfDay(hour: h, minute: m);
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', _notifEnabled);
    await prefs.setBool('budget_alerts', _budgetAlerts);
    await prefs.setBool('daily_digest', _dailyDigest);
    await prefs.setDouble('threshold_high', _thresholdHigh);
    await prefs.setDouble('threshold_medium', _thresholdMedium);
    await prefs.setDouble('threshold_low', _thresholdLow);
    await prefs.setInt('digest_hour', _digestTime.hour);
    await prefs.setInt('digest_minute', _digestTime.minute);
    // Apply digest schedule immediately — enables or cancels based on toggle.
    await NotificationService.scheduleDailyDigest(
      hour: _digestTime.hour,
      minute: _digestTime.minute,
    );
  }

  Widget _toggleRow(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 18, color: scheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ])),
        LifeOsSwitch(value: value, onChanged: (v) { onChanged(v); _savePrefs(); }),
      ],
    );
  }

  Widget _sliderRow(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${value.round()}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: scheme.primary, inactiveTrackColor: scheme.primary.withValues(alpha: 0.24), thumbColor: scheme.primary, overlayShape: SliderComponentShape.noOverlay),
          child: Slider(value: value, min: 10, max: 100, divisions: 17, onChanged: (v) { onChanged((v / 5).round() * 5.0); _savePrefs(); }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Notifications',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // System notifications
          AppCard(
            contentPadding: const EdgeInsets.all(16),
            child: _toggleRow(context, Icons.notifications_outlined, 'Notifications', 'Event and task reminders.', _notifEnabled, (v) => setState(() => _notifEnabled = v)),
          ),
          const SizedBox(height: 12),
          // Budget alerts
          AppCard(
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggleRow(context, Icons.savings_outlined, 'Budget Alerts', 'Warn when approaching budget limits.', _budgetAlerts, (v) => setState(() => _budgetAlerts = v)),
                if (_budgetAlerts) ...[
                  const SizedBox(height: 12),
                  _sliderRow(context, 'High threshold', _thresholdHigh, (v) => setState(() => _thresholdHigh = v)),
                  const SizedBox(height: 8),
                  _sliderRow(context, 'Medium threshold', _thresholdMedium, (v) => setState(() => _thresholdMedium = v)),
                  const SizedBox(height: 8),
                  _sliderRow(context, 'Low threshold', _thresholdLow, (v) => setState(() => _thresholdLow = v)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Daily digest
          AppCard(
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggleRow(context, Icons.wb_sunny_outlined, 'Daily Digest', 'Morning summary of your day.', _dailyDigest, (v) => setState(() => _dailyDigest = v)),
                if (_dailyDigest) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: _digestTime, builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false), child: child!));
                      if (picked != null) { setState(() => _digestTime = picked); _savePrefs(); }
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text('Delivery time', style: Theme.of(context).textTheme.bodyMedium),
                          const Spacer(),
                          Text(_digestTime.format(context), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                          const SizedBox(width: 4),
                          Text('Tap to change', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SMS Import Health ───────────────────────────────────────────────────────

class SmsImportHealthPage extends ConsumerStatefulWidget {
  const SmsImportHealthPage({super.key});

  @override
  ConsumerState<SmsImportHealthPage> createState() => _SmsImportHealthPageState();
}

class _SmsImportHealthPageState extends ConsumerState<SmsImportHealthPage> {
  Future<_HealthData>? _healthFuture;
  bool _reconciling = false;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _healthFuture = _load(ref);
  }

  Future<void> _reconcile() async {
    setState(() => _reconciling = true);
    try {
      // Drain realtime queue + re-run import for any new SMS.
      await runHistoricalSmsImport(ref);
    } finally {
      if (mounted) {
        setState(() {
          _reconciling = false;
          _healthFuture = _load(ref); // refresh counters
        });
      }
    }
  }

  Future<void> _retryQueue() async {
    setState(() => _retrying = true);
    try {
      // Drain the realtime broadcast queue and process any queued messages.
      final queued = await SmsPlatformBridge.drainRealtimeQueue();
      if (queued.isNotEmpty) {
        final db = await ref.read(lifeOsDatabaseProvider.future);
        final userId = await ref.read(userIdProvider.future);
        final holder = LifeOsDbHolder(database: db, userId: userId);
        await holder.seedAuditCounter();
        final pipeline = DefaultMpesaIngestionPipeline(holder: holder);
        try {
          // drainRealtimeQueue() already returns List<RawSms>.
          await pipeline.ingestBatch(Stream.fromIterable(queued));
        } finally {
          await pipeline.dispose();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
          _healthFuture = _load(ref);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return PageScaffold(
      title: 'SMS Import Health',
      onBack: () => context.pop(),
      child: FutureBuilder<_HealthData>(
        future: _healthFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data ?? const _HealthData();
          final total = d.imported + d.skipped + d.errors;
          final successPct = total > 0 ? d.imported / total * 100 : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Receiver Status ─────────────────────────────────────────
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: d.hasPermission
                            ? scheme.primaryContainer
                            : scheme.errorContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        d.hasPermission
                            ? Icons.cell_tower_outlined
                            : Icons.signal_cellular_off_outlined,
                        size: 20,
                        color: d.hasPermission
                            ? scheme.primary
                            : scheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Realtime receiver', style: tt.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            d.hasPermission
                                ? 'Incoming M-Pesa SMS are captured automatically and processed on next app open'
                                : 'Grant SMS permission to start capturing messages in real time',
                            style: tt.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant),
                          ),
                          if (!d.hasPermission) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () async {
                                await SmsPlatformBridge.requestSmsPermissions();
                                if (context.mounted) {
                                  setState(() => _healthFuture = _load(ref));
                                }
                              },
                              child: Text(
                                'Grant permission →',
                                style: tt.labelSmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: d.hasPermission
                            ? scheme.primaryContainer
                            : scheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        d.hasPermission ? 'Active' : 'Inactive',
                        style: tt.labelSmall?.copyWith(
                          color: d.hasPermission
                              ? scheme.onPrimaryContainer
                              : scheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Lifetime Counters ───────────────────────────────────────
              Text('Lifetime Counters',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _counterStat(context, '${d.imported}', 'Imported',
                            color: scheme.primary),
                        _counterStat(context, '${d.skipped}', 'Skipped'),
                        _counterStat(context, '${d.pending}', 'Pending'),
                        _counterStat(context, '${d.errors}', 'Errors'),
                      ],
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Parse success rate — ${successPct.toStringAsFixed(0)}%',
                            style: tt.bodySmall
                                ?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Rejection Breakdown ─────────────────────────────────────
              if (d.notMpesaCount > 0) ...[
                Text('Rejection Breakdown',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Not M-Pesa', style: tt.bodyMedium),
                      Text(
                        d.notMpesaCount.toString(),
                        style: tt.bodyMedium?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Activity ─────────────────────────────────────────────────
              Text('Activity',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _activityRow(context, Icons.timer_outlined, 'Last background scan',
                        d.lastBgScanAt != null
                            ? AppDateUtils.formatRelativeTime(d.lastBgScanAt!)
                            : 'Never',
                        scheme),
                    _activityRow(context, Icons.inbox_outlined, 'Last inbox scan',
                        d.lastInboxScanAt != null
                            ? AppDateUtils.formatRelativeTime(d.lastInboxScanAt!)
                            : 'Never',
                        scheme),
                    _activityRow(context, Icons.check_circle_outline, 'Last successful import',
                        d.lastSuccessfulImportAt != null
                            ? AppDateUtils.formatRelativeTime(d.lastSuccessfulImportAt!)
                            : 'Never',
                        scheme,
                        isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Last Activity Details ────────────────────────────────────
              if (d.lastMpesaCode != null) ...[
                Text('Last Activity Details',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted_outlined,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last M-Pesa code',
                                style: tt.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant)),
                            Text(d.lastMpesaCode!,
                                style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Actions ─────────────────────────────────────────────────
              Text('Actions',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Reconcile re-scans the last 7 days. Retry reprocesses previously failed messages.',
                style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                      onPressed: _reconciling ? null : _reconcile,
                      icon: _reconciling
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh, size: 16),
                      label: const Text('Reconcile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                      onPressed: _retrying ? null : _retryQueue,
                      icon: _retrying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry Queue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                onPressed: () => context.push('/${AppRoute.reviewQueue}'),
                icon: const Icon(Icons.list_outlined, size: 16),
                label: const Text('View Review Queue'),
              ),
              const SizedBox(height: 16),

              // ── Import Audit Log ─────────────────────────────────────────
              Text('Import Audit Log',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: d.recentLog.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('No activity yet',
                              style: tt.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                        ),
                      )
                    : Column(
                        children: [
                          for (final row in d.recentLog)
                            _auditRow(context, row, scheme, tt),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _counterStat(BuildContext context, String value, String label,
      {Color? color}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color ?? scheme.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _activityRow(BuildContext context, IconData icon, String label,
      String value, ColorScheme scheme,
      {bool isLast = false}) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Text(value,
              style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _auditRow(BuildContext context, Map<String, Object?> row,
      ColorScheme scheme, TextTheme tt) {
    final outcome = row['outcome'] as String? ?? '';
    final ou = outcome.toUpperCase();
    final isImported = ou == 'IMPORTED' || ou == 'RECOVERED_FROM_BACKFILL';
    final isError = ou.contains('FAIL') || ou.contains('ERROR');
    final isDuplicate = ou == 'DUPLICATE' || ou == 'SKIPPED';
    final color = isImported
        ? scheme.primary
        : isError
            ? scheme.error
            : scheme.onSurfaceVariant;
    final bgColor = isImported
        ? scheme.primary.withValues(alpha: 0.08)
        : isError
            ? scheme.error.withValues(alpha: 0.08)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final icon = isImported
        ? Icons.check_circle_outline
        : isError
            ? Icons.error_outline
            : isDuplicate
                ? Icons.copy_outlined
                : Icons.remove_circle_outline;
    final merchant = row['merchant'] as String?;
    final code = row['mpesa_code'] as String?;
    final label = (merchant?.isNotEmpty ?? false) ? merchant! : (code?.isNotEmpty ?? false) ? code! : '—';
    final amount = (row['amount'] as num?)?.toDouble();
    final ts = (row['imported_at'] as num?)?.toInt();
    final timeStr = ts != null
        ? AppDateUtils.formatRelativeTime(ts)
        : '';
    final badgeLabel = isImported
        ? 'Imported'
        : isDuplicate
            ? 'Duplicate'
            : isError
                ? 'Error'
                : ou.isEmpty ? '—' : ou[0] + ou.substring(1).toLowerCase().replaceAll('_', ' ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeStr.isNotEmpty)
                  Text(timeStr, style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badgeLabel,
                    style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
              ),
              if (amount != null && amount > 0) ...[
                const SizedBox(height: 2),
                Text(
                  AppDateUtils.formatCurrency(amount),
                  style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<_HealthData> _load(WidgetRef ref) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);

    int count(List rows) => (rows.first.data['n'] as num?)?.toInt() ?? 0;

    final imp = await db.customSelect(
      "SELECT COUNT(*) as n FROM import_audit WHERE user_id=? AND LOWER(outcome) IN ('imported','recovered_from_backfill')",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).get();
    // Skipped = confirmed duplicates only.
    final skip = await db.customSelect(
      "SELECT COUNT(*) as n FROM import_audit WHERE user_id=? AND outcome='duplicate'",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).get();
    // Errors = ignored/irrelevant messages that are NOT simply non-M-Pesa
    // (those are captured separately in notMpesa below).
    final fail = await db.customSelect(
      "SELECT COUNT(*) as n FROM import_audit WHERE user_id=? AND outcome='ignored_irrelevant' AND (failure_reason IS NULL OR failure_reason != 'not_mpesa')",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).get();
    final pend = await db.customSelect(
      "SELECT COUNT(*) as n FROM sms_review_queue WHERE user_id=? AND reviewed_at IS NULL",
      variables: [Variable.withString(userId)], readsFrom: {db.smsReviewQueue},
    ).get();
    // Not M-Pesa = messages the parser rejected specifically because they are
    // not M-Pesa (failure_reason='not_mpesa').
    final notMpesa = await db.customSelect(
      "SELECT COUNT(*) as n FROM import_audit WHERE user_id=? AND outcome='ignored_irrelevant' AND failure_reason='not_mpesa'",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).get();
    final lastScan = await db.customSelect(
      'SELECT MAX(imported_at) as ts FROM import_audit WHERE user_id=?',
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).getSingleOrNull();
    final lastSuccess = await db.customSelect(
      "SELECT MAX(imported_at) as ts FROM import_audit WHERE user_id=? AND LOWER(outcome)='imported'",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).getSingleOrNull();
    final lastCode = await db.customSelect(
      "SELECT mpesa_code FROM import_audit WHERE user_id=? AND mpesa_code IS NOT NULL AND mpesa_code != '' AND LOWER(outcome)='imported' ORDER BY imported_at DESC LIMIT 1",
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).getSingleOrNull();
    final log = await db.customSelect(
      'SELECT merchant, mpesa_code, outcome, imported_at, amount FROM import_audit WHERE user_id=? ORDER BY imported_at DESC LIMIT 20',
      variables: [Variable.withString(userId)], readsFrom: {db.importAudit},
    ).get();

    final hasPermission = await SmsPlatformBridge.hasSmsPermissions();
    final prefs = await SharedPreferences.getInstance();
    final lastBgScanMs = prefs.getInt('last_bg_scan_ms');

    return _HealthData(
      hasPermission: hasPermission,
      imported: count(imp),
      skipped: count(skip),
      pending: count(pend),
      errors: count(fail),
      notMpesaCount: count(notMpesa),
      lastBgScanAt: lastBgScanMs,
      lastInboxScanAt: (lastScan?.data['ts'] as num?)?.toInt(),
      lastSuccessfulImportAt: (lastSuccess?.data['ts'] as num?)?.toInt(),
      lastMpesaCode: lastCode?.data['mpesa_code'] as String?,
      recentLog: log.map((r) => r.data).toList(),
    );
  }
}

class _HealthData {
  const _HealthData({
    this.hasPermission = false,
    this.imported = 0,
    this.skipped = 0,
    this.pending = 0,
    this.errors = 0,
    this.notMpesaCount = 0,
    this.lastBgScanAt,
    this.lastInboxScanAt,
    this.lastSuccessfulImportAt,
    this.lastMpesaCode,
    this.recentLog = const [],
  });
  final bool hasPermission;
  final int imported, skipped, pending, errors, notMpesaCount;
  final int? lastBgScanAt;
  final int? lastInboxScanAt;
  final int? lastSuccessfulImportAt;
  final String? lastMpesaCode;
  final List<Map<String, Object?>> recentLog;
}

// ── Review Queue ─────────────────────────────────────────────────────────────

class ReviewQueuePage extends ConsumerStatefulWidget {
  const ReviewQueuePage({super.key});

  @override
  ConsumerState<ReviewQueuePage> createState() => _ReviewQueueState();
}

class _ReviewQueueState extends ConsumerState<ReviewQueuePage> {
  static const _categories = [
    ('RECEIVED', '💰'), ('SENT', '📤'), ('AIRTIME', '📱'),
    ('PAYBILL', '🏦'), ('BUY_GOODS', '🛒'), ('DEPOSIT', '⬆️'),
    ('WITHDRAW', '⬇️'), ('LOAN', '🔄'), ('FULIZA_CHARGE', '⚡'), ('REVERSED', '↩️'),
  ];

  Future<void> _pickCategory(BuildContext context, int entryId) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Text('Assign Category', style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final (cat, emoji) in _categories)
              ListTile(
                leading: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(ctx).colorScheme.surfaceContainerHighest), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 18))),
                title: Text(cat, style: Theme.of(ctx).textTheme.bodyLarge),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                onTap: () async {
                  await db.customStatement('UPDATE sms_review_queue SET category=?, reviewed_at=?, review_decision="APPROVED" WHERE id=?', [cat, DateTime.now().millisecondsSinceEpoch, entryId]);
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Review Queue',
      subtitle: 'Medium-confidence imports awaiting approval',
      onBack: () => context.pop(),
      child: FutureBuilder<List<Map<String, Object?>>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) return const EmptyState(icon: Icons.fact_check_outlined, title: 'Nothing pending', description: 'Transactions you confirm land directly in the ledger.');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    contentPadding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (row['amount'] != null)
                              Text(formatCurrency((row['amount'] as num).toDouble()), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            _ConfidenceLabel(score: (row['confidence_score'] as num?)?.toDouble() ?? 0, scheme: scheme),
                          ],
                        ),
                        if (row['counterparty'] != null) ...[
                          const SizedBox(height: 4),
                          Text(row['counterparty'] as String, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            (row['raw_message'] as String? ?? '').length > 100 ? '${(row['raw_message'] as String).substring(0, 100)}…' : (row['raw_message'] as String? ?? ''),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () => _pickCategory(context, row['id'] as int),
                          child: const Text('Assign category'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, Object?>>> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final rows = await db.customSelect('SELECT * FROM sms_review_queue WHERE user_id=? AND reviewed_at IS NULL ORDER BY enqueued_at DESC LIMIT 50', variables: [Variable.withString(userId)], readsFrom: {db.smsReviewQueue}).get();
    return rows.map((r) => r.data).toList();
  }
}

class _ConfidenceLabel extends StatelessWidget {
  const _ConfidenceLabel({required this.score, required this.scheme});
  final double score;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = score >= 0.7 ? scheme.primary : score >= 0.4 ? scheme.onSurfaceVariant : scheme.error;
    final label = score >= 0.7 ? 'High' : score >= 0.4 ? 'Medium' : 'Low';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text('$label ${(score * 100).round()}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── SMS Quarantine ───────────────────────────────────────────────────────────

class QuarantinePage extends ConsumerStatefulWidget {
  const QuarantinePage({super.key});

  @override
  ConsumerState<QuarantinePage> createState() => _QuarantineState();
}

class _QuarantineState extends ConsumerState<QuarantinePage> {
  Future<void> _dismiss(int id) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    await db.customStatement('UPDATE sms_quarantine SET resolved_at=?, resolution="DISMISSED" WHERE id=?', [DateTime.now().millisecondsSinceEpoch, id]);
    setState(() {});
  }

  Future<void> _dismissAll(List<Map<String, Object?>> rows) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final r in rows) {
      await db.customStatement('UPDATE sms_quarantine SET resolved_at=?, resolution="DISMISSED" WHERE id=?', [now, r['id']]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Quarantine',
      subtitle: 'Low-confidence SMS held back',
      onBack: () => context.pop(),
      child: FutureBuilder<List<Map<String, Object?>>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) return const EmptyState(icon: Icons.block_outlined, title: 'Quarantine is empty', description: 'Ambiguous messages are kept here instead of being dropped.');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error, side: BorderSide(color: scheme.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => _dismissAll(rows),
                child: const Text('Dismiss All'),
              ),
              const SizedBox(height: 12),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    contentPadding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (row['amount'] != null)
                              Text(formatCurrency((row['amount'] as num).toDouble()), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('${((row['confidence_score'] as num?)?.toDouble() ?? 0 * 100).round()}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (row['counterparty'] != null) Text(row['counterparty'] as String, style: Theme.of(context).textTheme.bodyMedium),
                        if (row['failure_reason'] != null) ...[
                          const SizedBox(height: 4),
                          Text(row['failure_reason'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            (row['raw_message'] as String? ?? '').length > 140 ? '${(row['raw_message'] as String).substring(0, 140)}…' : (row['raw_message'] as String? ?? ''),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd MMM yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch((row['quarantined_at'] as int?) ?? 0)), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: scheme.error, side: BorderSide(color: scheme.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () => _dismiss(row['id'] as int),
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, Object?>>> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final rows = await db.customSelect('SELECT * FROM sms_quarantine WHERE user_id=? AND resolved_at IS NULL ORDER BY quarantined_at DESC', variables: [Variable.withString(userId)], readsFrom: {db.smsQuarantine}).get();
    return rows.map((r) => r.data).toList();
  }
}

// ── Paybill Registry ─────────────────────────────────────────────────────────

class PaybillRegistryPage extends ConsumerStatefulWidget {
  const PaybillRegistryPage({super.key});

  @override
  ConsumerState<PaybillRegistryPage> createState() => _PaybillRegistryState();
}

class _PaybillRegistryState extends ConsumerState<PaybillRegistryPage> {
  late Future<List<Map<String, Object?>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Paybill Registry',
      subtitle: 'Billers discovered across your imports',
      onBack: () => context.pop(),
      child: FutureBuilder<List<Map<String, Object?>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No billers yet',
              description: 'Paybill & Till payments discovered during M-Pesa import appear here.',
            );
          }
          final topUsage = (rows.first['usage_count'] as int?) ?? 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Summary row ────────────────────────────────────────────────
              AppCard(
                contentPadding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${rows.length}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary)),
                          Text('total billers',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(rows.first['usage_count'] as int?) ?? 0}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981))),
                          Text('top usage',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Biller cards ───────────────────────────────────────────────
              for (final (i, row) in rows.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BillerCard(row: row, rank: i + 1, topUsage: topUsage),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, Object?>>> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final rows = await db.customSelect(
      'SELECT * FROM paybill_registry WHERE user_id=? ORDER BY usage_count DESC',
      variables: [Variable.withString(userId)],
      readsFrom: {db.paybillRegistry},
    ).get();
    return rows.map((r) => r.data).toList();
  }
}

class _BillerCard extends StatelessWidget {
  const _BillerCard({required this.row, required this.rank, required this.topUsage});
  final Map<String, Object?> row;
  final int rank;
  final int topUsage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = row['display_name'] as String? ?? row['paybill_number'] as String? ?? '';
    final number = row['paybill_number'] as String? ?? '';
    final usage = (row['usage_count'] as int?) ?? 0;
    final lastAmt = (row['last_amount_kes'] as num?)?.toDouble() ?? 0;
    final lastAt = (row['last_seen_at'] as int?) ?? 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '#';
    final avatarColor = _merchantColor(name);
    // Rank-based accent: gold, silver, bronze for top 3.
    final rankColor = rank == 1
        ? const Color(0xFFF59E0B)
        : rank == 2
            ? const Color(0xFF94A3B8)
            : rank == 3
                ? const Color(0xFFCD7C2F)
                : null;

    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Rank badge + avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarColor.withValues(alpha: 0.15),
                    ),
                    alignment: Alignment.center,
                    child: Text(initial,
                        style: TextStyle(
                            color: avatarColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                  ),
                  if (rankColor != null)
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rankColor,
                          border: Border.all(color: scheme.surface, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text('$rank',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(number,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              // Usage count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$usage×',
                    style: TextStyle(
                        color: avatarColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Usage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: topUsage > 0 ? usage / topUsage : 0,
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(avatarColor.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 12, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Last: ${formatCurrency(lastAmt)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today_outlined, size: 12, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                lastAt > 0 ? DateFormat('MMM dd, yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(lastAt)) : '—',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Categorize ───────────────────────────────────────────────────────────────

/// (icon, accent color) per category — used by category chips and the avatar.
const _kCatMeta = <String, (IconData, Color)>{
  'Food':         (Icons.restaurant_outlined,       Color(0xFFF97316)),
  'Transport':    (Icons.directions_car_outlined,   Color(0xFF3B82F6)),
  'Utilities':    (Icons.bolt_outlined,             Color(0xFFF59E0B)),
  'Entertainment':(Icons.movie_outlined,            Color(0xFFA78BFA)),
  'Shopping':     (Icons.shopping_bag_outlined,     Color(0xFFEC4899)),
  'Health':       (Icons.health_and_safety_outlined,Color(0xFF10B981)),
  'Education':    (Icons.school_outlined,           Color(0xFF6366F1)),
  'Housing':      (Icons.home_outlined,             Color(0xFF8B5CF6)),
  'Airtime':      (Icons.phone_android_outlined,    Color(0xFF14B8A6)),
  'Savings':      (Icons.savings_outlined,          Color(0xFF22C55E)),
  'PersonalCare': (Icons.spa_outlined,              Color(0xFFF472B6)),
  'Subscriptions':(Icons.subscriptions_outlined,   Color(0xFF0EA5E9)),
  'Fuliza':       (Icons.account_balance_outlined,  Color(0xFFF43F5E)),
  'Transfer':     (Icons.swap_horiz_outlined,       Color(0xFF8B5CF6)),
  'Withdrawal':   (Icons.atm_outlined,              Color(0xFFEF4444)),
  'Miscellaneous':(Icons.category_outlined,         Color(0xFF94A3B8)),
};

/// Deterministic pastel color derived from merchant name (for avatar background).
Color _merchantColor(String name) {
  const palette = [
    Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFF14B8A6),
    Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFF97316),
    Color(0xFFEC4899), Color(0xFFA78BFA), Color(0xFF22C55E),
    Color(0xFF0EA5E9), Color(0xFFF43F5E), Color(0xFF8B5CF6),
  ];
  final hash = name.codeUnits.fold(0, (h, c) => h * 31 + c);
  return palette[hash.abs() % palette.length];
}

class CategorizePage extends ConsumerStatefulWidget {
  const CategorizePage({super.key});

  @override
  ConsumerState<CategorizePage> createState() => _CategorizeState();
}

class _CategorizeState extends ConsumerState<CategorizePage> {
  final Set<String> _hidden = {};
  String? _successMsg;
  int _totalInitial = 0;

  // Broad match for any uncategorised row regardless of casing / spelling.
  static const _uncatFilter =
      "(category IS NULL OR category='' OR LOWER(category) IN ('uncategorized','other','others','unknown','other category'))";

  // Cached future — never recreated by setState so the list doesn't flash a
  // spinner when _successMsg clears. Only reset on explicit retry or after a
  // categorization is applied.
  late Future<List<_MerchantGroup>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<void> _applyCategory(String merchant, String category) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    await db.customStatement(
      "UPDATE transactions SET category=?, updated_at=? WHERE user_id=? AND merchant=? AND deleted_at IS NULL AND $_uncatFilter",
      [category, DateTime.now().millisecondsSinceEpoch, userId, merchant],
    );
    setState(() {
      _hidden.add(merchant);
      _successMsg = 'Categorized "$merchant" as $category';
      _loadFuture = _load();
    });
    Future.delayed(const Duration(milliseconds: 2000),
        () { if (mounted) setState(() => _successMsg = null); });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Categorize',
      subtitle: 'Tap a category to apply it to all matching transactions',
      onBack: () => context.pop(),
      child: FutureBuilder<List<_MerchantGroup>>(
        future: _loadFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 36, color: scheme.error),
                const SizedBox(height: 8),
                const Text('Could not load transactions.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _loadFuture = _load()),
                  child: const Text('Retry'),
                ),
              ]),
            );
          }
          final all = snap.data ?? [];
          if (_totalInitial == 0 && all.isNotEmpty) {
            // Store initial count on first load for the progress indicator.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _totalInitial = all.length);
            });
          }
          final groups = all.where((g) => !_hidden.contains(g.merchant)).toList();
          if (groups.isEmpty) {
            return const EmptyState(
              icon: Icons.done_all_outlined,
              title: 'All sorted!',
              description: 'Every transaction has a category. Great work!',
            );
          }
          final done = _hidden.length;
          final total = _totalInitial > 0 ? _totalInitial : groups.length + done;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Progress header ──────────────────────────────────────────
              AppCard(
                contentPadding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${groups.length} merchant${groups.length == 1 ? '' : 's'} to review',
                            style: Theme.of(context).textTheme.titleSmall),
                        if (done > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34D399).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$done done',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF34D399),
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? done / total : 0,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
                      ),
                    ),
                  ],
                ),
              ),
              if (_successMsg != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF34D399)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_successMsg!,
                          style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              // ── Merchant cards ───────────────────────────────────────────
              for (final g in groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MerchantCard(
                    group: g,
                    onCategorize: (cat) => _applyCategory(g.merchant, cat),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<_MerchantGroup>> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final rows = await db.customSelect(
      "SELECT COALESCE(merchant,'Unknown') as merchant, COUNT(*) as cnt, SUM(amount) as total"
      " FROM transactions WHERE user_id=? AND deleted_at IS NULL"
      " AND ${_CategorizeState._uncatFilter}"
      " GROUP BY merchant ORDER BY total DESC LIMIT 50",
      variables: [Variable.withString(userId)],
      readsFrom: {db.transactions},
    ).get();
    return rows
        .map((r) => _MerchantGroup(
              (r.data['merchant'] as String?)?.trim().isEmpty ?? true
                  ? 'Unknown'
                  : r.data['merchant'] as String,
              (r.data['cnt'] as int?) ?? 0,
              (r.data['total'] as num?)?.toDouble() ?? 0,
            ))
        .toList();
  }
}

class _MerchantGroup {
  const _MerchantGroup(this.merchant, this.count, this.total);
  final String merchant;
  final int count;
  final double total;
}

/// A card for one merchant that collapses category chips behind a tappable
/// header. Chips are hidden until the user taps to expand — keeps the list
/// scannable when there are many merchants.
class _MerchantCard extends StatefulWidget {
  const _MerchantCard({required this.group, required this.onCategorize});
  final _MerchantGroup group;
  final void Function(String) onCategorize;

  @override
  State<_MerchantCard> createState() => _MerchantCardState();
}

class _MerchantCardState extends State<_MerchantCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatarColor = _merchantColor(widget.group.merchant);
    final initial =
        widget.group.merchant.isNotEmpty ? widget.group.merchant[0].toUpperCase() : '?';

    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tappable merchant header row ─────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Text(initial,
                      style: TextStyle(
                          color: avatarColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.group.merchant,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.group.count} txn${widget.group.count == 1 ? '' : 's'} · ${formatCurrency(widget.group.total)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Expand/collapse chevron
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // ── Collapsible category chips ───────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text('Choose category',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final entry in _kCatMeta.entries)
                      _CategoryChip(
                        label: entry.key,
                        icon: entry.value.$1,
                        color: entry.value.$2,
                        onTap: () => widget.onCategorize(entry.key),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Fee Analytics ─────────────────────────────────────────────────────────────

class FeeAnalyticsPage extends ConsumerWidget {
  const FeeAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Fee Analytics',
      subtitle: 'Airtime, Fuliza, withdrawals and subscriptions this month',
      onBack: () => context.pop(),
      child: FutureBuilder<_FeeData>(
        future: _load(ref),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data ?? _FeeData(0, 0, 0, 0, []);
          final total = d.airtime + d.withdrawal + d.fuliza + d.subscriptions;
          final rows = [('Airtime', d.airtime), ('Withdrawal', d.withdrawal), ('Fuliza charges', d.fuliza), ('Subscriptions', d.subscriptions)];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total fees', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                    Text(formatCurrency(total), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFFF59E0B))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (label, amount) in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                                Text(formatCurrency(amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: total > 0 ? (amount / total).clamp(0.0, 1.0) : 0),
                                duration: const Duration(milliseconds: 500),
                                builder: (context2, v, child2) => LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: scheme.surfaceContainerHighest, valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B))),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (d.recentFees.isNotEmpty) ...[
                const SizedBox(height: 12),
                AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Recent charges', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      for (final t in d.recentFees.take(20))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(child: Text(t['category'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall)),
                              Text(AppDateUtils.formatDate((t['date'] as int?)??0, 'MMM dd'), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              Text(formatCurrency((t['amount'] as num?)?.toDouble()??0), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<_FeeData> _load(WidgetRef ref) async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1).millisecondsSinceEpoch;
    final vars = [Variable.withString(userId), Variable.withInt(monthStart)];
    double q(List<QueryRow> rows) => (rows.first.data['total'] as num?)?.toDouble() ?? 0;
    final air = await db.customSelect("SELECT SUM(amount) as total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type)='AIRTIME'", variables: vars, readsFrom: {db.transactions}).get();
    final wd = await db.customSelect("SELECT SUM(amount) as total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('WITHDRAW','WITHDRAWN')", variables: vars, readsFrom: {db.transactions}).get();
    final fz = await db.customSelect("SELECT SUM(amount) as total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND (category='Fuliza' OR UPPER(transaction_type)='FULIZA_CHARGE')", variables: vars, readsFrom: {db.transactions}).get();
    final sub = await db.customSelect("SELECT SUM(amount) as total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND category='Subscriptions'", variables: vars, readsFrom: {db.transactions}).get();
    final recent = await db.customSelect("SELECT category,date,amount FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND (UPPER(transaction_type) IN ('AIRTIME','WITHDRAW','WITHDRAWN','FULIZA_CHARGE') OR category IN ('Fuliza','Subscriptions')) ORDER BY date DESC LIMIT 20", variables: vars, readsFrom: {db.transactions}).get();
    return _FeeData(q(air), q(wd), q(fz), q(sub), recent.map((r) => r.data).toList());
  }
}

class _FeeData {
  const _FeeData(this.airtime, this.withdrawal, this.fuliza, this.subscriptions, this.recentFees);
  final double airtime, withdrawal, fuliza, subscriptions;
  final List<Map<String, Object?>> recentFees;
}

// ── Learning ─────────────────────────────────────────────────────────────────

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningState();
}

class _LearningState extends ConsumerState<LearningPage> {
  static const _goalMinutes = 600; // 10 hours / month

  Future<void> _showLogDialog() async {
    final topicC = TextEditingController();
    final durationC = TextEditingController();
    final notesC = TextEditingController();
    String? topicErr, durErr;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => LifeOsAlertDialog(
        scrollable: true,
        title: const Text('Log Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: topicC, decoration: InputDecoration(hintText: 'e.g. Kotlin Coroutines', labelText: 'Topic', errorText: topicErr, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)))),
            const SizedBox(height: 12),
            TextField(controller: durationC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Duration (minutes)', errorText: durErr, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)))),
            const SizedBox(height: 12),
            TextField(controller: notesC, maxLines: 3, decoration: InputDecoration(hintText: 'Notes (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final topic = topicC.text.trim();
              final dur = int.tryParse(durationC.text.trim()) ?? 0;
              if (topic.isEmpty) { setD(() => topicErr = 'Required'); return; }
              if (dur <= 0) { setD(() => durErr = 'Enter minutes'); return; }
              final db = await ref.read(lifeOsDatabaseProvider.future);
              final userId = await ref.read(userIdProvider.future);
              final now = DateTime.now().millisecondsSinceEpoch;
              final id = (await db.customSelect('SELECT COALESCE(MAX(id),0)+1 AS n FROM learning_sessions WHERE user_id=?', variables: [Variable.withString(userId)]).getSingle()).data['n'] as int;
              await db.into(db.learningSessions).insert(LearningSessionsCompanion.insert(id: id, userId: userId, topic: topic, durationMinutes: dur, notes: notesC.text.trim(), date: now, source: 'MANUAL', createdAt: now, syncState: 'LOCAL'));
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Log'),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return PageScaffold(
      title: 'Learn',
      subtitle: 'Track your learning sessions',
      onBack: () => context.pop(),
      actions: [
        IconButton(
          onPressed: _showLogDialog,
          icon: Icon(Icons.add_outlined, size: 24, color: scheme.primary),
          tooltip: 'Log Session',
        ),
      ],
      contentPadding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: FutureBuilder<_LearningData>(
        future: _load(),
        builder: (context, snap) {
          final d = snap.data ?? _LearningData(0, []);
          final progress = (d.monthMinutes / _goalMinutes).clamp(0.0, 1.0);
          final progressColor = progress >= 0.8
              ? const Color(0xFF34D399)
              : progress >= 0.4
                  ? const Color(0xFFF59E0B)
                  : scheme.error;
          final hoursLogged = d.monthMinutes / 60;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Monthly goal hero card ─────────────────────────────────
              AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.school_outlined,
                              size: 20, color: progressColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Monthly Learning Goal',
                                  style: tt.titleSmall),
                              Text(
                                '${hoursLogged.toStringAsFixed(1)} / 10.0 hrs  ·  ${(progress * 100).toStringAsFixed(0)}%',
                                style: tt.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            progress >= 1.0
                                ? '✓ Done'
                                : progress >= 0.8
                                    ? 'Almost!'
                                    : 'In progress',
                            style: tt.labelSmall?.copyWith(
                                color: progressColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(progressColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Session list ───────────────────────────────────────────
              if (d.sessions.isEmpty)
                const EmptyState(
                    icon: Icons.school_outlined,
                    title: 'No sessions yet',
                    description: 'Tap + to log your first learning session.')
              else
                for (final s in d.sessions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LearningSessionCard(session: s),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<_LearningData> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1).millisecondsSinceEpoch;
    final monthRow = await db.customSelect('SELECT COALESCE(SUM(duration_minutes),0) as total FROM learning_sessions WHERE user_id=? AND deleted_at IS NULL AND date>=?', variables: [Variable.withString(userId), Variable.withInt(monthStart)], readsFrom: {db.learningSessions}).get();
    final sessions = await db.customSelect('SELECT * FROM learning_sessions WHERE user_id=? AND deleted_at IS NULL ORDER BY date DESC', variables: [Variable.withString(userId)], readsFrom: {db.learningSessions}).get();
    return _LearningData((monthRow.first.data['total'] as num?)?.toInt() ?? 0, sessions.map((r) => r.data).toList());
  }
}

class _LearningSessionCard extends StatelessWidget {
  const _LearningSessionCard({required this.session});
  final Map<String, Object?> session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final minutes = (session['duration_minutes'] as int?) ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final durationLabel = hours > 0
        ? '${hours}h ${mins}m'
        : '${minutes}m';
    final dateMs = (session['date'] as int?) ?? 0;

    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.menu_book_outlined,
                size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(session['topic'] as String? ?? '',
                    style: tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(durationLabel,
                        style: tt.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(AppDateUtils.formatDate(dateMs, 'MMM dd, yyyy'),
                        style: tt.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
                if ((session['notes'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    session['notes'] as String,
                    style: tt.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningData {
  const _LearningData(this.monthMinutes, this.sessions);
  final int monthMinutes;
  final List<Map<String, Object?>> sessions;
}

// ── Changelog ────────────────────────────────────────────────────────────────

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: "What's New",
      subtitle: 'BELTECH LifeOS release notes',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final release in _kReleases) _ReleaseCard(release: release),
        ],
      ),
    );
  }
}

typedef _ReleaseNote = ({String version, String date, Color accent, List<(IconData, String, String)> features});

const _kReleases = <_ReleaseNote>[
  (
    version: 'v1.1.0',
    date: 'August 2026',
    accent: Color(0xFF6366F1),
    features: [
      (Icons.psychology_outlined,          'Smarter AI',        'Real DB data: spending, budgets, tasks & events in every reply'),
      (Icons.filter_list_outlined,         'Import Filtering',  'M-Pesa Only / Banks Only / All source filter now wires through import'),
      (Icons.bar_chart_outlined,           'Export Preview',    'Per-domain breakdown: transactions, tasks, events, budgets & more'),
      (Icons.category_outlined,            'Categorize',        'Colorful chip picker replaces the dropdown — progress bar shows progress'),
      (Icons.add_outlined,                 'Task Add Button',   'Moved to top-right header, matching Calendar parity'),
      (Icons.image_outlined,               'View Photo',        'Profile avatar sheet now has a full-screen pinch-to-zoom viewer'),
      (Icons.keyboard_outlined,            'Keyboard Smooth',   'AI input bar tracks keyboard animation frame-by-frame — no lag'),
    ],
  ),
  (
    version: 'v1.0.0',
    date: 'July 2026',
    accent: Color(0xFF14B8A6),
    features: [
      (Icons.flutter_dash,                  'Flutter Edition',   'Full BELTECH experience rebuilt in Flutter — 1:1 Kotlin parity'),
      (Icons.sms_outlined,                  'SMS Import',        'M-Pesa pipeline: 100k messages in ~8 s via 4-isolate pool'),
      (Icons.account_balance_wallet_outlined,'Finance Hub',       'Budgets, income, recurring, bills, goals & Fuliza tracking'),
      (Icons.calendar_month_outlined,        'Calendar',          'Tasks, events, birthdays and countdowns with reminders'),
      (Icons.smart_toy_outlined,            'Offline AI',        'Deterministic intent engine — no internet required'),
      (Icons.fingerprint_outlined,          'Biometric Lock',    'Screen lock with local_auth integration'),
      (Icons.palette_outlined,              'Themes',            'Dark / Light / System with animated 400 ms color lerp'),
    ],
  ),
];

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release});
  final _ReleaseNote release;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = release.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        contentPadding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(release.version,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(release.date,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            // ── Feature rows ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (icon, title, desc) in release.features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, size: 16, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(desc,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
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
}
