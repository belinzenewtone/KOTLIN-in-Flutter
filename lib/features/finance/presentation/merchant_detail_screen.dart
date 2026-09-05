/// 1:1 port of MerchantDetailScreen.kt — transactions for a single merchant,
/// with stats summary and a scrollable transaction list.
library;

import 'package:drift/drift.dart' show Variable, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/utils/date_utils.dart';
import '../../dashboard/data/providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MerchantDetailScreen extends ConsumerStatefulWidget {
  const MerchantDetailScreen({super.key, required this.merchant});

  final String merchant;

  @override
  ConsumerState<MerchantDetailScreen> createState() =>
      _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends ConsumerState<MerchantDetailScreen> {
  List<Map<String, Object?>> _transactions = [];
  bool _loading = true;
  String? _error;

  // ── derived stats ──────────────────────────────────────────────────────────
  int get _txCount => _transactions.length;

  double get _totalSpent => _transactions.fold(
        0.0,
        (sum, row) => sum + (row['amount'] as num? ?? 0).toDouble(),
      );

  double get _avgAmount => _txCount == 0 ? 0.0 : _totalSpent / _txCount;

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);

      // SELECT * FROM transactions
      // WHERE user_id = ? AND deleted_at IS NULL AND merchant = ?
      // ORDER BY date DESC
      final rows = await db.customSelect(
        'SELECT * FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND merchant = ? '
        'ORDER BY date DESC',
        variables: [
          Variable.withString(userId),
          Variable.withString(widget.merchant),
        ],
        readsFrom: {db.transactions},
      ).get();

      if (mounted) {
        setState(() {
          _transactions = rows.map((r) => r.data).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      headerEyebrow: 'Merchant',
      title: widget.merchant,
      subtitle: '$_txCount transaction${_txCount == 1 ? '' : 's'}',
      onBack: () => context.pop(),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 64),
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 64),
                  child: Center(
                    child: Text(
                      'Failed to load: $_error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                )
              : _Body(
                  transactions: _transactions,
                  txCount: _txCount,
                  totalSpent: _totalSpent,
                  avgAmount: _avgAmount,
                ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.transactions,
    required this.txCount,
    required this.totalSpent,
    required this.avgAmount,
  });

  final List<Map<String, Object?>> transactions;
  final int txCount;
  final double totalSpent;
  final double avgAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // ── Stats card ──────────────────────────────────────────────────────
        AppCard(
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MerchantStatColumn(
                label: 'Total Spend',
                value: AppDateUtils.formatCurrency(totalSpent),
              ),
              _MerchantStatColumn(
                label: 'Transactions',
                value: txCount.toString(),
              ),
              _MerchantStatColumn(
                label: 'Avg. Amount',
                value: AppDateUtils.formatCurrency(avgAmount),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Transaction list ────────────────────────────────────────────────
        if (transactions.isEmpty)
          _EmptyState()
        else
          Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _TransactionRow(row: transactions[i]),
              ],
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Stat column ───────────────────────────────────────────────────────────────

class _MerchantStatColumn extends StatelessWidget {
  const _MerchantStatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
        ),
      ],
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.row});

  final Map<String, Object?> row;

  static final _dateFmt = DateFormat('MMM dd, yyyy · h:mm a', 'en_US');

  bool get _isCredit {
    final type = ((row['transaction_type'] as String?) ?? '').toUpperCase();
    return type == 'RECEIVED' || type == 'DEPOSIT';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final rawCategory = (row['category'] as String?) ?? '';
    final displayCategory = rawCategory.isEmpty
        ? 'Uncategorized'
        : rawCategory[0].toUpperCase() + rawCategory.substring(1).toLowerCase();

    final dateMs = (row['date'] as int?) ?? 0;
    final dateLabel = _dateFmt.format(
      DateTime.fromMillisecondsSinceEpoch(dateMs),
    );

    final amount = (row['amount'] as num? ?? 0).toDouble();
    final amountLabel = _isCredit
        ? '+${AppDateUtils.formatCurrency(amount)}'
        : AppDateUtils.formatCurrency(amount);

    final amountColor = _isCredit
        ? const Color(0xFF2E7D32) // success green — mirrors Kotlin successColor
        : scheme.onSurface;

    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: category + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayCategory,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: amount
          Text(
            amountLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 40,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'No transactions found for this merchant.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
