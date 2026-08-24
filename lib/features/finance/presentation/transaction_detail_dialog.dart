/// 1:1 port of TransactionDetailDialog.kt — the small AlertDialog popup that
/// opens when a transaction row is tapped in Finance.
///
/// Behavior contract (matches Compose): centered modal dialog, 6dp corners,
/// surface container, title = merchant + Share/Edit icon buttons, amount block,
/// divider, detail rows, full-width red delete TextButton, Close confirm.
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
    final tx = transaction;

    return AlertDialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(tx.merchant,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 18),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit',
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              Text(
                AppDateUtils.formatCurrency(tx.amount),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tx.amount < 0 ? scheme.primary : scheme.error,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 12),
          DetailRow(context, 'Category', tx.category.toUpperCase()),
          DetailRow(context, 'Type', tx.transactionType),
          DetailRow(context, 'Date', formatDateFull(tx.date)),
          if (tx.mpesaCode != null) DetailRow(context, 'M-Pesa Code', tx.mpesaCode!),
          if (tx.notes != null && tx.notes!.trim().isNotEmpty)
            DetailRow(context, 'Notes', tx.notes!),
          if (tx.fee != 0.0)
            DetailRow(context, 'Fee', AppDateUtils.formatCurrency(tx.fee)),
          if (tx.balanceAfter != null)
            DetailRow(context, 'Balance After', AppDateUtils.formatCurrency(tx.balanceAfter!)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onDelete,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: Icon(Icons.delete_outline,
                  size: 16, color: scheme.error),
              label: Text('Delete transaction',
                  style: TextStyle(color: scheme.error)),
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

/// "EEEE, MMM d, yyyy · h:mm a" — used by the dialog's Date row.
String formatDateFull(int ms) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  var hour = d.hour;
  final ampm = hour >= 12 ? 'PM' : 'AM';
  if (hour == 0) hour = 12;
  if (hour > 12) hour -= 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year} · $hour:$minute $ampm';
}

Widget DetailRow(BuildContext context, String label, String value) {
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        Expanded(
          flex: 3,
          child: Text(value,
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

