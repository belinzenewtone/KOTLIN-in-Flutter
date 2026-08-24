/// 1:1 ports of SimpleMpesaParser.kt (independent fallback parser),
/// SmsFeatureExtractor.kt and TransactionDecisionTree.kt.
library;

import 'parser_types.dart';

// ── SimpleMpesaParser ────────────────────────────────────────────────────────

class SimpleParseResult {
  const SimpleParseResult({required this.category, this.amount});
  final TxCategory category;
  final double? amount;
}

final RegExp _simpleAmount =
    RegExp(r'(?:Ksh|KES|KSH)\s?([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);

/// Returns null when the message cannot be classified. Never throws.
SimpleParseResult? simpleMpesaParse(String body) {
  try {
    final lower = body.toLowerCase();
    if (!lower.contains('mpesa') && !lower.contains('m-pesa')) return null;

    final raw = _simpleAmount.firstMatch(body)?.group(1)?.replaceAll(',', '');
    final amt = double.tryParse(raw ?? '');

    TxCategory? category;
    if (lower.contains('from your m-pesa has been used to')) {
      category = TxCategory.loan;
    } else if (lower.contains('total fuliza m-pesa outstanding amount')) {
      category = TxCategory.fulizaCharge;
    } else if (lower.contains('has been reversed')) {
      category = TxCategory.reversed;
    } else if (lower.contains('for airtime') ||
        lower.contains('of airtime') ||
        (lower.contains('bought') && lower.contains('airtime'))) {
      category = TxCategory.airtime;
    } else if (lower.contains('paybill') ||
        lower.contains('for account ') ||
        lower.contains('for meter ')) {
      category = TxCategory.paybill;
    } else if (lower.contains('deposited') ||
        lower.contains('cash deposit') ||
        lower.contains('give ksh')) {
      category = TxCategory.deposit;
    } else if (lower.contains('withdrawn from') || lower.contains('cash withdrawal')) {
      category = TxCategory.withdraw;
    } else if (lower.contains('you have received') ||
        lower.contains('received from ') ||
        lower.contains('umepokea')) {
      category = TxCategory.received;
    } else if (lower.contains('buy goods') ||
        lower.contains('till number') ||
        lower.contains('paid to')) {
      category = TxCategory.buyGoods;
    } else if (lower.contains('sent to') || lower.contains('customer transfer')) {
      category = TxCategory.sent;
    }
    if (category == null) return null;

    return SimpleParseResult(
      category: category,
      amount: (amt != null && amt > 0) ? amt : null,
    );
  } catch (_) {
    return null;
  }
}

// ── SmsFeatureExtractor ──────────────────────────────────────────────────────

class FeatureVector {
  const FeatureVector({
    required this.hasTransactionCode,
    required this.hasAmount,
    required this.amountTier,
    required this.hasDate,
    required this.hasMpesaKeyword,
    required this.numericDensity,
    required this.hasBalance,
    required this.hasFee,
    required this.hasReversalSignal,
    required this.hasFulizaSignal,
    required this.normBodyLength,
    required this.hasBothParties,
  });

  final double hasTransactionCode;
  final double hasAmount;
  final double amountTier;
  final double hasDate;
  final double hasMpesaKeyword;
  final double numericDensity;
  final double hasBalance;
  final double hasFee;
  final double hasReversalSignal;
  final double hasFulizaSignal;
  final double normBodyLength;
  final double hasBothParties;

  List<double> toList() => [
        hasTransactionCode, hasAmount, amountTier, hasDate, hasMpesaKeyword,
        numericDensity, hasBalance, hasFee, hasReversalSignal, hasFulizaSignal,
        normBodyLength, hasBothParties,
      ];

  static const int featureCount = 12;
}

class SmsFeatureExtractor {
  static final _code = RegExp(r'\b(?=[A-Za-z0-9]*[A-Za-z][A-Za-z0-9]*\d)([A-Za-z0-9]{9,10})\b');
  static final _amount = RegExp(r'(?:Ksh|KES|KSH)\s?[\d,]+(?:\.\d{1,2})?', caseSensitive: false);
  static final _date = RegExp(r'\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}|\d{4}-\d{2}-\d{2}');
  static final _balance = RegExp(r'(?:new|available)?\s*balance\s*(?:is|:)', caseSensitive: false);
  static final _fee = RegExp(r'(?:transaction\s+cost|charges?|fees?)[:\s]+', caseSensitive: false);
  static final _reversal = RegExp(r'\breversed?\b|\breversal\b', caseSensitive: false);
  static final _fuliza = RegExp(r'fuliza', caseSensitive: false);
  static final _sentTo = RegExp(r'sent\s+to\s+[A-Z][A-Za-z]', caseSensitive: false);
  static final _from = RegExp(r'(?:from|received from)\s+[A-Z][A-Za-z]', caseSensitive: false);

  static FeatureVector extract(String sms) {
    final lower = sms.toLowerCase();

    final hasCode = _code.hasMatch(sms) ? 1.0 : 0.0;
    final amountHit = _amount.firstMatch(sms);
    final hasAmt = amountHit != null ? 1.0 : 0.0;

    final rawAmtStr = amountHit?.group(0)
        ?.replaceAll(RegExp('ksh', caseSensitive: false), '')
        .replaceAll('kes', '')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final rawAmt = double.tryParse(rawAmtStr ?? '') ?? 0.0;
    final amtTier = rawAmt < 100
        ? 0.0
        : rawAmt < 1000
            ? 0.25
            : rawAmt < 10000
                ? 0.5
                : rawAmt < 100000
                    ? 0.75
                    : 1.0;

    var digitCount = 0;
    for (var i = 0; i < sms.length; i++) {
      // ASCII digits only — mirrors Kotlin Char.isDigit on common SMS input.
      final c = sms.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) digitCount++;
    }
    final numericDens = sms.isEmpty ? 0.0 : (digitCount / sms.length).clamp(0.0, 1.0);

    final hasBoth = (_sentTo.hasMatch(sms) || _from.hasMatch(sms)) ? 1.0 : 0.0;

    return FeatureVector(
      hasTransactionCode: hasCode,
      hasAmount: hasAmt,
      amountTier: amtTier,
      hasDate: _date.hasMatch(sms) ? 1.0 : 0.0,
      hasMpesaKeyword:
          (lower.contains('mpesa') || lower.contains('m-pesa')) ? 1.0 : 0.0,
      numericDensity: numericDens,
      hasBalance: _balance.hasMatch(sms) ? 1.0 : 0.0,
      hasFee: _fee.hasMatch(sms) ? 1.0 : 0.0,
      hasReversalSignal: _reversal.hasMatch(sms) ? 1.0 : 0.0,
      hasFulizaSignal: _fuliza.hasMatch(sms) ? 1.0 : 0.0,
      normBodyLength: (sms.length / 500).clamp(0.0, 1.0),
      hasBothParties: hasBoth,
    );
  }
}

// ── TransactionDecisionTree ─────────────────────────────────────────────────

enum TreeVerdict { high, medium, low }

TreeVerdict evaluateTree(FeatureVector f) {
  if (f.hasAmount < 0.5) return TreeVerdict.low;

  if (f.hasMpesaKeyword >= 0.5) {
    if (f.hasTransactionCode >= 0.5) {
      final corroborated =
          f.hasBothParties >= 0.5 || f.hasFee >= 0.5 || f.hasDate >= 0.5;
      return corroborated ? TreeVerdict.high : TreeVerdict.medium;
    }
    return f.hasDate >= 0.5 ? TreeVerdict.medium : TreeVerdict.low;
  }

  if (f.hasFulizaSignal >= 0.5) {
    return f.hasTransactionCode >= 0.5 ? TreeVerdict.medium : TreeVerdict.low;
  }
  return TreeVerdict.low;
}

bool shouldDemoteToReview(TreeVerdict verdict, PConfidence parserConfidence) =>
    verdict == TreeVerdict.low && parserConfidence == PConfidence.high;

bool treeShouldDemote(String sms, PConfidence parserConfidence) {
  final features = SmsFeatureExtractor.extract(sms);
  final verdict = evaluateTree(features);
  return shouldDemoteToReview(verdict, parserConfidence);
}
