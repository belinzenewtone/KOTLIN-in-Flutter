/// 1:1 port of core/ui/designsystem/MetricCard.kt + DateUtils.formatCurrency.
library;

import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../ui/theme/theme.dart';
import 'app_card.dart';
import 'tokens.dart';

/// Formats currency exactly like Kotlin's `DateUtils.formatCurrency`
/// ("KSh 1,234" — grouped integer, decimals truncated).
String formatCurrency(double amount) => AppDateUtils.formatCurrency(amount);

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    this.value,
    this.amount,
    this.delta,
    this.deltaPositive,
    this.elevated = true,
  }) : assert((value == null) != (amount == null), 'Provide either value or amount');

  final String title;
  final String? value;
  final double? amount;
  final String? delta;
  final bool? deltaPositive;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      elevated: elevated,
      contentPadding: AppDesignTokens.metricCardContentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.left),
          const SizedBox(height: 4),
          Text(
            value ?? formatCurrency(amount ?? 0),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.left,
          ),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: switch (deltaPositive) {
                      true => LifeOsColors.success,
                      false => scheme.error,
                      null => scheme.onSurfaceVariant,
                    },
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
