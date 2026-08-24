library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart' show Variable;
import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/metric_card.dart' show formatCurrency;
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../../dashboard/data/providers.dart';

// ---------------------------------------------------------------------------
// Colour tokens matching the Kotlin spec
// ---------------------------------------------------------------------------
const _kWarning = Color(0xFFF59E0B);
const _kSuccess = Color(0xFF34D399);

// ---------------------------------------------------------------------------
// LoansScreen
// ---------------------------------------------------------------------------

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static double _drawAmount(Map<String, Object?> row) =>
      (row['draw_amount_kes'] as num?)?.toDouble() ?? 0.0;

  static double _totalRepaid(Map<String, Object?> row) =>
      (row['total_repaid_kes'] as num?)?.toDouble() ?? 0.0;

  static double _outstanding(Map<String, Object?> row) =>
      (_drawAmount(row) - _totalRepaid(row)).clamp(0.0, double.infinity);

  static String _drawId(Map<String, Object?> row) =>
      (row['id'] ?? '').toString();

  static String _drawCode(Map<String, Object?> row) =>
      (row['draw_code'] ?? '').toString();

  static String _status(Map<String, Object?> row) =>
      (row['status'] ?? '').toString();

  static DateTime? _drawDate(Map<String, Object?> row) {
    final ms = row['draw_date'] as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static String _formatDrawDate(Map<String, Object?> row) {
    final dt = _drawDate(row);
    return dt == null ? '—' : DateFormat('dd MMM yyyy').format(dt);
  }

  // -------------------------------------------------------------------------
  // Repay dialog
  // -------------------------------------------------------------------------

  Future<void> _showRepayDialog(
    BuildContext context,
    LifeOsDatabase db,
    String userId,
    Map<String, Object?> loan,
  ) async {
    final outstanding = _outstanding(loan);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor:
              Theme.of(dialogCtx).colorScheme.surfaceContainerHighest,
          title: const Text('Log Repayment'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding: ${formatCurrency(outstanding)}',
                  style: Theme.of(dialogCtx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount (KSh)',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter an amount';
                    }
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid positive amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final amount = double.parse(controller.text.trim());
                await _logRepayment(db, userId, loan, amount);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              },
              child: const Text('Log'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logRepayment(
    LifeOsDatabase db,
    String userId,
    Map<String, Object?> loan,
    double amount,
  ) async {
    final drawAmount = _drawAmount(loan);
    final totalRepaid = _totalRepaid(loan);
    final newRepaid = totalRepaid + amount;
    final newStatus =
        newRepaid >= drawAmount ? 'REPAID' : _status(loan);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _drawId(loan);

    await db.customUpdate(
      'UPDATE fuliza_loans '
      'SET total_repaid_kes = ?, '
      '    status = ?, '
      '    updated_at = ? '
      'WHERE user_id = ? AND id = ?',
      variables: [
        Variable.withReal(newRepaid),
        Variable.withString(newStatus),
        Variable.withInt(now),
        Variable.withString(userId),
        Variable.withString(id),
      ],
      updates: {db.fulizaLoans},
    );
  }

  Future<void> _markRepaid(
    LifeOsDatabase db,
    String userId,
    Map<String, Object?> loan,
  ) async {
    final drawAmount = _drawAmount(loan);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _drawId(loan);

    await db.customUpdate(
      'UPDATE fuliza_loans '
      'SET status = "REPAID", '
      '    total_repaid_kes = ?, '
      '    last_repayment_date = ?, '
      '    updated_at = ? '
      'WHERE user_id = ? AND id = ?',
      variables: [
        Variable.withReal(drawAmount),
        Variable.withInt(now),
        Variable.withInt(now),
        Variable.withString(userId),
        Variable.withString(id),
      ],
      updates: {db.fulizaLoans},
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(lifeOsDatabaseProvider);
    final userIdAsync = ref.watch(userIdProvider);

    return dbAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (db) => userIdAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
        data: (userId) => _LoansBody(
          db: db,
          userId: userId,
          onRepay: (loan) =>
              _showRepayDialog(context, db, userId, loan),
          onMarkRepaid: (loan) => _markRepaid(db, userId, loan),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LoansBody — watches DB streams and renders content
// ---------------------------------------------------------------------------

class _LoansBody extends StatelessWidget {
  const _LoansBody({
    required this.db,
    required this.userId,
    required this.onRepay,
    required this.onMarkRepaid,
  });

  final LifeOsDatabase db;
  final String userId;
  final Future<void> Function(Map<String, Object?> loan) onRepay;
  final Future<void> Function(Map<String, Object?> loan) onMarkRepaid;

  Stream<List<Map<String, Object?>>> _openLoansStream() {
    return db
        .customSelect(
          'SELECT * FROM fuliza_loans '
          'WHERE user_id = ? AND status != "REPAID" '
          'ORDER BY draw_date DESC',
          variables: [Variable.withString(userId)],
          readsFrom: {db.fulizaLoans},
        )
        .watch()
        .map((rows) => rows.map((r) => r.data).toList());
  }

  Stream<List<Map<String, Object?>>> _closedLoansStream() {
    return db
        .customSelect(
          'SELECT * FROM fuliza_loans '
          'WHERE user_id = ? AND status = "REPAID" '
          'ORDER BY last_repayment_date DESC '
          'LIMIT 10',
          variables: [Variable.withString(userId)],
          readsFrom: {db.fulizaLoans},
        )
        .watch()
        .map((rows) => rows.map((r) => r.data).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, Object?>>>(
      stream: _openLoansStream(),
      builder: (context, openSnap) {
        return StreamBuilder<List<Map<String, Object?>>>(
          stream: _closedLoansStream(),
          builder: (context, closedSnap) {
            final openLoans = openSnap.data ?? [];
            final closedLoans = closedSnap.data ?? [];
            return _LoansContent(
              openLoans: openLoans,
              closedLoans: closedLoans,
              onRepay: onRepay,
              onMarkRepaid: onMarkRepaid,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _LoansContent — pure UI, receives resolved data
// ---------------------------------------------------------------------------

class _LoansContent extends StatelessWidget {
  const _LoansContent({
    required this.openLoans,
    required this.closedLoans,
    required this.onRepay,
    required this.onMarkRepaid,
  });

  final List<Map<String, Object?>> openLoans;
  final List<Map<String, Object?>> closedLoans;
  final Future<void> Function(Map<String, Object?>) onRepay;
  final Future<void> Function(Map<String, Object?>) onMarkRepaid;

  double get _netOutstanding => openLoans.fold(
        0.0,
        (sum, loan) =>
            sum + (_LoansScreenState._outstanding(loan)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAny = openLoans.isNotEmpty || closedLoans.isNotEmpty;
    final netOutstanding = _netOutstanding;
    final outstandingColor =
        netOutstanding > 0 ? _kWarning : _kSuccess;

    return PageScaffold(
      title: 'Loans & Fuliza',
      subtitle: 'Track outstanding draws and repayment history',
      onBack: () => context.pop(),
      child: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 220, // BottomSafeWithFloatingNav
        ),
        children: [
          // ----------------------------------------------------------------
          // Net Outstanding card
          // ----------------------------------------------------------------
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Outstanding',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(netOutstanding),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: outstandingColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    openLoans.isNotEmpty
                        ? '${openLoans.length} open draw(s) · Pay to avoid daily interest.'
                        : 'All Fuliza draws are fully repaid.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------------------
          // Empty state
          // ----------------------------------------------------------------
          if (!hasAny) ...[
            const SizedBox(height: 48),
            _EmptyState(),
          ],

          // ----------------------------------------------------------------
          // Open draws section
          // ----------------------------------------------------------------
          if (openLoans.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Open Draws',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _kWarning,
                ),
              ),
            ),
            ...openLoans.map(
              (loan) => _OpenLoanCard(
                loan: loan,
                onRepay: () => onRepay(loan),
                onMarkRepaid: () => onMarkRepaid(loan),
              ),
            ),
          ],

          // ----------------------------------------------------------------
          // Repaid section
          // ----------------------------------------------------------------
          if (closedLoans.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Repaid',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...closedLoans.map(
              (loan) => _RepaidLoanCard(loan: loan),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _OpenLoanCard
// ---------------------------------------------------------------------------

class _OpenLoanCard extends StatelessWidget {
  const _OpenLoanCard({
    required this.loan,
    required this.onRepay,
    required this.onMarkRepaid,
  });

  final Map<String, Object?> loan;
  final VoidCallback onRepay;
  final VoidCallback onMarkRepaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawAmount = _LoansScreenState._drawAmount(loan);
    final outstanding = _LoansScreenState._outstanding(loan);
    final dateStr = _LoansScreenState._formatDrawDate(loan);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: draw info + outstanding amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: draw amount + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Draw: ${formatCurrency(drawAmount)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right: outstanding
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(outstanding),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _kWarning,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'outstanding',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color: theme.colorScheme.outlineVariant
                    .withOpacity(0.3),
                height: 1,
              ),
              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: onRepay,
                    child: Text(
                      'Log Repayment',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onMarkRepaid,
                    child: const Text(
                      'Mark Repaid',
                      style: TextStyle(color: _kSuccess),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RepaidLoanCard
// ---------------------------------------------------------------------------

class _RepaidLoanCard extends StatelessWidget {
  const _RepaidLoanCard({required this.loan});

  final Map<String, Object?> loan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawAmount = _LoansScreenState._drawAmount(loan);
    final dateStr = _LoansScreenState._formatDrawDate(loan);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency(drawAmount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      dateStr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Repaid',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _kSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No Fuliza activity',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fuliza draws detected from M-PESA SMS appear here.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
