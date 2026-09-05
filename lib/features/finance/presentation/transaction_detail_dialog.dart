/// 1:1 port of TransactionDetailDialog.kt — the small AlertDialog popup that
/// opens when a transaction row is tapped in Finance.
///
/// Behavior contract (matches Compose): centered modal dialog, surface
/// container, title = merchant + Share/Edit icon buttons, inline amount row,
/// divider, detail rows (Type hidden when same as Category), full-width red
/// delete TextButton, Close action.
library;

import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../domain/finance_models.dart';

class TransactionDetailDialog extends StatelessWidget {
  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.onDismiss,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  final FinanceTransaction transaction;
  final VoidCallback onDismiss;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tx = transaction;

    return AlertDialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Tighter title padding — less air above merchant name.
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      title: Row(
        children: [
          Expanded(
            child: Text(tx.merchant,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: onShare,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.share_outlined, size: 18),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit',
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount as an inline row — saves ~20dp vs the stacked layout.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Amount',
                  style: tt.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 0.4)),
              Text(
                AppDateUtils.formatCurrency(tx.amount),
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tx.amount < 0 ? scheme.primary : scheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 8),
          _detailRow(context, 'Category', tx.category.toUpperCase()),
          // Type row hidden when identical to Category — avoids redundant row.
          if (tx.transactionType.toUpperCase() != tx.category.toUpperCase())
            _detailRow(context, 'Type', tx.transactionType),
          _detailRow(context, 'Date', _formatDateCompact(tx.date)),
          if (tx.mpesaCode != null) _detailRow(context, 'M-Pesa Code', tx.mpesaCode!),
          if (tx.notes != null && tx.notes!.trim().isNotEmpty)
            _detailRow(context, 'Notes', tx.notes!),
          if (tx.fee != 0.0)
            _detailRow(context, 'Fee', AppDateUtils.formatCurrency(tx.fee)),
          if (tx.balanceAfter != null)
            _detailRow(context, 'Balance After',
                AppDateUtils.formatCurrency(tx.balanceAfter!)),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onDelete,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.delete_outline, size: 16, color: scheme.error),
              label:
                  Text('Delete transaction', style: TextStyle(color: scheme.error)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Close')),
      ],
    );
  }
}

/// "Mon, Aug 24, 2026 · 9:18 AM" — shorter than the full weekday to save space.
String _formatDateCompact(int ms) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  var hour = d.hour;
  final ampm = hour >= 12 ? 'PM' : 'AM';
  if (hour == 0) hour = 12;
  if (hour > 12) hour -= 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year} · $hour:$minute $ampm';
}

// Keep the old export for any callsites that reference it.
String formatDateFull(int ms) => _formatDateCompact(ms);

Widget _detailRow(BuildContext context, String label, String value) {
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

// Keep old export for any remaining callsites.
// ignore: non_constant_identifier_names
Widget DetailRow(BuildContext context, String label, String value) =>
    _detailRow(context, label, value);
