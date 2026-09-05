/// 1:1 port of MpesaParserEnhanced.kt — the 6-stage M-Pesa parser.
///
/// Stage 0  Fast filter (is this even an M-Pesa SMS?)
/// Stage 1  Extract transaction code (required)
/// Stage 2  Extract amount (required, positive)
/// Stage 3  Classify intent via DETECTION_RULES (3-phase + keyword hints)
/// Stage 4  Extract counterparty
/// Stage 5  Confidence score (6-factor) + parse route
/// Stage 6  Build human-readable description
library;

import 'dart:convert';

import 'cross_parser_voter.dart' show ParsedTransactionBase, resolveMerchantCategory;
import 'institution_detector.dart' show classifySenderTrust;
import 'mpesa_date_parser.dart';
import 'mpesa_parsing_config.dart';
import 'parser_types.dart';
import 'service_notice_filter.dart';
import 'simple_parser_and_tree.dart'
    show SmsFeatureExtractor, evaluateTree, shouldDemoteToReview;
import 'sms_confidence_scorer.dart';
import 'sms_normalizer.dart';

export 'cross_parser_voter.dart' show ParsedTransactionBase;

class MpesaParsedTransaction implements ParsedTransactionBase {
  MpesaParsedTransaction({
    required this.mpesaCode,
    required this.amount,
    required this.category,
    required this.confidence,
    required this.counterparty,
    required this.description,
    required this.balanceAfter,
    required this.fee,
    required this.date,
    required this.rawSms,
    required this.parseRoute,
    required this.semanticHash,
    required this.matchedRulePhase,
    required this.merchantCategory,
    this.fulizaOutstandingKes,
    this.fulizaAvailableLimitKes,
    this.isReceivedReversal = false,
  });

  final String mpesaCode;
  @override
  final double amount;
  @override
  final TxCategory category;
  final PConfidence confidence;
  @override
  final String? counterparty;
  final String description;
  final double? balanceAfter;
  final double fee;
  final int date;
  final String rawSms;
  @override
  final ParseRoute parseRoute;

  /// Authoritative cumulative Fuliza debt from a charge notice.
  final double? fulizaOutstandingKes;

  /// Available Fuliza credit after repayment.
  final double? fulizaAvailableLimitKes;

  /// REVERSED of a received payment → net expense (Gap 6).
  final bool isReceivedReversal;

  /// Inline semantic hash — pre-computed for dedupe (Gap 7).
  final String semanticHash;

  /// Which detection phase matched (0=no-rule, 1=primary, 2=fallback, 3=last-resort).
  final int matchedRulePhase;

  final MerchantCategory merchantCategory;

  bool get isIncome =>
      !isReceivedReversal &&
      (category == TxCategory.received || category == TxCategory.deposit);

  bool get isExpense =>
      isReceivedReversal ||
      switch (category) {
        TxCategory.sent ||
        TxCategory.airtime ||
        TxCategory.paybill ||
        TxCategory.buyGoods ||
        TxCategory.withdraw => true,
        _ => false,
      };
}

/// Fuliza charge-notice result — NOT a transaction; updates balance tracker.
class FulizaChargeNoticeResult {
  const FulizaChargeNoticeResult({
    required this.outstandingKes,
    required this.accessFeeKes,
    required this.amountUsedKes,
    required this.dueDate,
    required this.date,
    required this.rawSms,
  });

  final double outstandingKes;
  final double accessFeeKes;
  final double amountUsedKes;
  final int? dueDate;
  final int date;
  final String rawSms;
}

sealed class MpesaParseResult {
  const MpesaParseResult();
}

class MpesaSuccess extends MpesaParseResult {
  const MpesaSuccess(this.transaction);
  final MpesaParsedTransaction transaction;
}

class MpesaFulizaNotice extends MpesaParseResult {
  const MpesaFulizaNotice(this.notice);
  final FulizaChargeNoticeResult notice;
}

class MpesaError extends MpesaParseResult {
  const MpesaError(this.error);
  final SmsParseError error;
}

// ── Extraction regexes ───────────────────────────────────────────────────────

final RegExp _codeRe =
    RegExp(r'\b(?=[A-Za-z0-9]*[A-Za-z][A-Za-z0-9]*\d)([A-Za-z0-9]{9,10})\b');
final RegExp _codeStartRe = RegExp(r'^([A-Za-z]{9,10})(?=\s+[Cc]onfirmed)');
final RegExp _amountRe =
    RegExp(r'(?:Ksh|KES|KSH)\s?([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);

final RegExp _actionVerbRe = RegExp(
  r'(?:sent\s+to|received\s+from|you\s+have\s+received|paid\s+to|pay(?:ing)?\s+to|bought|purchased|withdrawn|cash\s+withdrawal|deposited|charged|used\s+to|repaid|fulfil)',
  caseSensitive: false,
);

final RegExp _balanceMarkerRe = RegExp(
  r'(?:New\s+M-PESA\s+balance|New\s+balance|New\s+business\s+balance|Available\s+balance|balance\s+is|transaction\s+cost|Transaction\s+fee|access\s+fee|withdrawal\s+charge)[,.]?\s*(?:Ksh|KES|KSH)?\s?',
  caseSensitive: false,
);

final RegExp _fulizaOutstandingRe = RegExp(
  r'Total Fuliza M-PESA outstanding amount is\s*(?:Ksh|KES|KSH)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _fulizaAvailLimitRe = RegExp(
  r'available Fuliza M-PESA limit is\s*(?:Ksh|KES|KSH)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _balanceRe = RegExp(
  r'(?:new\s*)?(?:m-pesa\s*)?(?:available\s*)?balance\s*(?:is\s*)?\s*(?:Ksh|KES|KSH)?\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _txCostRe = RegExp(
  r'(?:transaction\s+(?:cost|fee)|withdrawal\s+charges?|agent\s+fee(?:\s+is)?|charge)[,.:s]?\s*(?:(?:Ksh|KES|KSH|Kshs?)\s?)?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _accessFeeRe = RegExp(
  r'Access\s+Fee\s+(?:charged\s+)?(?:Ksh|KES|KSH|Kshs?)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _fulizaAmountRe = RegExp(
  r'Fuliza\s+M-PESA\s+amount\s+is\s+(?:Ksh|KES|KSH|Kshs?)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final RegExp _dueOnRe = RegExp(r'due on\s+([\d/]+)', caseSensitive: false);

final RegExp _receivedReversedRe = RegExp(
  r'(?:received|you have received)\s+(?:Ksh|KES|KSH)\s?[\d,.]+.+has been reversed|(?:Ksh|KES|KSH)\s?[\d,.]+\s+received from.+has been reversed',
  caseSensitive: false,
);

/// Keyword-hints fast path — most-specific first. Cuts average regex
/// evaluations from ~32 to ~3–5 in the common case.
const List<(String, String)> _keywordHints = [
  ('from your m-pesa has been used to', 'fuliza_repayment'),
  ('total fuliza m-pesa outstanding amount', 'fuliza_charge'),
  ('has been reversed', 'reversal'),
  ('for airtime', 'airtime'),
  ('of airtime', 'airtime'),
  ('airtime for ', 'airtime'),
  ('paybill', 'paybill'),
  ('for account ', 'paybill'),
  ('for meter ', 'paybill'),
  ('deposited by', 'deposit'),
  ('cash deposit', 'deposit'),
  ('give ksh', 'deposit'),
  ('withdrawn from', 'withdrawal'),
  ('cash withdrawal', 'withdrawal'),
  ('you have received', 'received'),
  ('received from ', 'received'),
  ('umepokea', 'received'),
  ('buy goods', 'buy_goods'),
  ('till number', 'buy_goods'),
  ('paid to', 'buy_goods'),
  ('customer transfer', 'sent_p2p'),
  ('sent to', 'sent_p2p'),
];

double? _toDouble(String? raw) {
  if (raw == null) return null;
  final v = double.tryParse(raw.replaceAll(',', ''));
  return v;
}

bool isMpesaSms(String sms) {
  final upper = sms.toUpperCase();
  if (upper.contains('MPESA') || upper.contains('M-PESA')) return true;
  final t = sms.trim();
  return (_codeRe.hasMatch(t) || _codeStartRe.hasMatch(t)) && _amountRe.hasMatch(sms);
}

String _buildDescription(TxCategory category, String? counterparty, double amount) {
  switch (category) {
    case TxCategory.received:
      return counterparty != null ? 'Received from $counterparty' : 'M-Pesa received';
    case TxCategory.deposit:
      return counterparty != null ? 'Cash deposit by $counterparty' : 'Cash deposit';
    case TxCategory.airtime:
      if (counterparty != null && counterparty != 'Airtime Purchase') {
        return 'Airtime for $counterparty';
      }
      return 'Airtime purchase';
    case TxCategory.loan:
      return 'Fuliza repayment';
    case TxCategory.fulizaCharge:
      return 'Fuliza charge notice';
    case TxCategory.paybill:
      return counterparty != null ? 'Paid to $counterparty (Paybill)' : 'Paybill payment';
    case TxCategory.buyGoods:
      return counterparty != null ? 'Bought goods at $counterparty' : 'Buy Goods';
    case TxCategory.withdraw:
      if (counterparty != null && counterparty != 'ATM Withdrawal') {
        return 'Withdrawal at $counterparty';
      }
      return 'Cash withdrawal';
    case TxCategory.reversed:
      return counterparty != null ? 'Reversal for $counterparty' : 'Transaction reversed';
    case TxCategory.sent:
      return counterparty != null ? 'Sent to $counterparty' : 'M-Pesa sent';
    case TxCategory.unknown:
      return 'M-Pesa KES ${amount.round()}';
  }
}

String? _cleanCounterparty(String value) {
  var v = value
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s+\d{9,12}$'), '')
      .replaceAll(RegExp(r'\s+via\s+kopo\s+kopo.*$', caseSensitive: false), '')
      .trim();
  while (v.endsWith('.')) {
    v = v.substring(0, v.length - 1);
  }
  v = v.replaceAll(RegExp(r'\s+New M-PESA.*$', caseSensitive: false), '').trim();
  if (v.isEmpty) return null;
  if (v.toLowerCase().startsWith('on ')) return null;
  return v;
}

class _Match {
  const _Match(this.rule, this.confidence, this.phase);
  final DetectionRule rule;
  final PConfidence confidence;
  final int phase;
}

_Match? _detectRule(String body) {
  final lower = body.toLowerCase();

  // Fast path via keyword hints.
  String? hintRuleId;
  for (final (hint, id) in _keywordHints) {
    if (lower.contains(hint)) {
      hintRuleId = id;
      break;
    }
  }
  if (hintRuleId != null) {
    DetectionRule? hintRule;
    for (final r in activeRules()) {
      if (r.id == hintRuleId) {
        hintRule = r;
        break;
      }
    }
    if (hintRule != null) {
      if (hintRule.patterns.any((p) => p.hasMatch(body))) {
        return _Match(hintRule, PConfidence.high, 1);
      }
      if (hintRule.fallbackPatterns.any((p) => p.hasMatch(body))) {
        return _Match(hintRule, PConfidence.medium, 2);
      }
    }
  }

  // Phase 1: primary structural scan.
  for (final rule in activeRules()) {
    if (rule.patterns.any((p) => p.hasMatch(body))) {
      return _Match(rule, PConfidence.high, 1);
    }
  }

  // Phase 2: fallback keyword scan.
  for (final rule in activeRules()) {
    if (rule.fallbackPatterns.any((p) => p.hasMatch(body))) {
      return _Match(rule, PConfidence.medium, 2);
    }
  }

  // Phase 3: last-resort keyword classification.
  String? lastResortId;
  if (lower.contains('has been reversed')) {
    lastResortId = 'reversal';
  } else if (lower.contains(' deposited') || lower.contains('cash deposit')) {
    lastResortId = 'deposit';
  } else if (lower.contains('for airtime') ||
      (lower.contains('bought') && lower.contains('airtime'))) {
    lastResortId = 'airtime';
  } else if ((lower.contains('sent to') || lower.contains('paid to')) &&
      (lower.contains(' account ') || lower.contains('for account'))) {
    lastResortId = 'paybill';
  } else if (lower.contains('paid to')) {
    lastResortId = 'buy_goods';
  } else if (lower.contains('withdrawn from agent') || lower.contains('cash withdrawal')) {
    lastResortId = 'withdrawal';
  } else if (lower.contains('from your m-pesa has been used to') &&
      lower.contains('outstanding fuliza')) {
    lastResortId = 'fuliza_repayment';
  } else if (lower.contains('received from') || lower.contains('you have received')) {
    lastResortId = 'received';
  } else if (lower.contains('sent to') || lower.contains('customer transfer')) {
    lastResortId = 'sent_p2p';
  }

  if (lastResortId == null) return null;
  for (final r in activeRules()) {
    if (r.id == lastResortId) return _Match(r, PConfidence.medium, 3);
  }
  return null;
}

String? _extractCounterparty(String body, DetectionRule rule) {
  for (final pattern in rule.counterpartyPatterns) {
    final m = pattern.firstMatch(body);
    final candidate = m?.group(1);
    if (candidate != null && candidate.trim().isNotEmpty) {
      return _cleanCounterparty(candidate);
    }
  }
  switch (rule.category) {
    case TxCategory.deposit:
      return 'Cash Deposit';
    case TxCategory.airtime:
      return 'Airtime Purchase';
    case TxCategory.withdraw:
      return 'ATM Withdrawal';
    default:
      return null;
  }
}

double? _parseBalance(String body) =>
    _toDouble(_balanceRe.firstMatch(body)?.group(1));

double _parseFee(String body) => _toDouble(_txCostRe.firstMatch(body)?.group(1)) ?? 0.0;

/// Semantic hash — SHA-256 over normalized properties ("sem_" + 16 hex chars).
String buildSemanticHash(TxCategory category, double amount, int dateMs, String? counterparty) {
  final local = DateTime.fromMillisecondsSinceEpoch(dateMs).toLocal();
  final localDate =
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final amtStr = amount.toStringAsFixed(2);
  final key = '${category.wireName}|$amtStr|$localDate|${(counterparty ?? '').toLowerCase()}';
  final digest = sha256Hex(key);
  return 'sem_${digest.substring(0, 16)}';
}

/// Phase 1.3 amount disambiguation: excludes amounts after balance/fee markers
/// then picks the one nearest an action verb.
double? _pickTransactionAmount(String body) {
  final allMatches = _amountRe.allMatches(body).toList();
  if (allMatches.isEmpty) return null;
  double valOf(RegExpMatch m) => double.tryParse(m.group(1)!.replaceAll(',', '')) ?? -1;
  if (allMatches.length == 1) {
    final v = valOf(allMatches[0]);
    return v > 0 ? v : null;
  }

  final excludeAfter = <int>{
    for (final m in _balanceMarkerRe.allMatches(body)) m.end - 1,
  };

  var candidates = allMatches.where((m) {
    final start = m.start;
    return !excludeAfter.any((ep) => start > ep && start <= ep + 20);
  }).toList();
  if (candidates.isEmpty) candidates = allMatches;

  if (candidates.length == 1) {
    final v = valOf(candidates[0]);
    return v > 0 ? v : null;
  }

  final verbPositions = [for (final m in _actionVerbRe.allMatches(body)) m.start];
  RegExpMatch best;
  if (verbPositions.isEmpty) {
    best = candidates.first;
  } else {
    best = candidates.reduce((a, b) {
      double dist(RegExpMatch m) {
        // Start at max-finite so every real distance beats the sentinel —
        // mirrors Kotlin's Int.MAX_VALUE initialiser in the equivalent loop.
        var min = double.maxFinite;
        for (final vp in verbPositions) {
          final d = (m.start - vp).abs().toDouble();
          if (d < min) min = d;
        }
        return min;
      }

      return dist(a) <= dist(b) ? a : b;
    });
  }
  final v = valOf(best);
  return v > 0 ? v : null;
}

/// The main parse entry point.
MpesaParseResult mpesaParserParse(String sms, String? sender, int smsTimestampMs) {
  try {
    // Phase 0.1 — strip Unicode artefacts + promo tails.
    final normalized = SmsNormalizer.normalize(sms);

    // Phase 0.3 — sender trust.
    final senderTrust = classifySenderTrust(sender);

    // Stage 0a — M-Pesa signal check.
    if (!isMpesaSms(normalized)) {
      return MpesaError(SmsParseError(reason: 'not_mpesa', rawSms: sms));
    }

    // Stage 0b — Fuliza charge notices carry the authoritative balance.
    // isFulizaServiceNotice() explicitly returns false for the "total fuliza
    // outstanding" template, so we must check the regex FIRST, then fall
    // through to the general service-notice drop. Kotlin parity.
    if (_fulizaOutstandingRe.hasMatch(normalized) &&
        normalized.toLowerCase().contains('total fuliza')) {
      final outstanding = _toDouble(_fulizaOutstandingRe.firstMatch(normalized)?.group(1));
      if (outstanding != null) {
        final accessFee = _toDouble(_accessFeeRe.firstMatch(normalized)?.group(1)) ?? 0.0;
        final amountUsed = _toDouble(_fulizaAmountRe.firstMatch(normalized)?.group(1)) ?? 0.0;
        int? dueMs;
        final dueStr = _dueOnRe.firstMatch(normalized)?.group(1);
        if (dueStr != null) dueMs = parseMpesaDateMatch(dueStr, null);
        return MpesaFulizaNotice(FulizaChargeNoticeResult(
          outstandingKes: outstanding,
          accessFeeKes: accessFee,
          amountUsedKes: amountUsed,
          dueDate: dueMs,
          date: extractMpesaDateMs(normalized, smsTimestampMs),
          rawSms: sms,
        ));
      }
    }
    if (isFulizaServiceNotice(normalized)) {
      return MpesaError(SmsParseError(reason: 'fuliza_service_notice', rawSms: sms));
    }

    // Stage 0c — failed transactions.
    if (ServiceNoticeFilter.isFailedTransaction(normalized)) {
      return MpesaError(SmsParseError(reason: 'failed_transaction', rawSms: sms));
    }

    // Stage 0d — ambiguous success receipts (Gap 1).
    if (ServiceNoticeFilter.isAmbiguousSuccessReceipt(normalized)) {
      return MpesaError(SmsParseError(reason: 'ambiguous_receipt', rawSms: sms));
    }

    // Stage 1 — code (required, or synthesised F-code for trusted senders).
    final code = _codeRe.firstMatch(normalized)?.group(1) ??
        _codeStartRe.firstMatch(normalized)?.group(1) ??
        (senderTrust == SenderTrustLevel.officialMpesa
            ? 'F${sha256Hex(normalized).substring(0, 10)}'
            : null);
    if (code == null) {
      return MpesaError(SmsParseError(reason: 'no_code', rawSms: sms));
    }

    // Stage 2 — positive amount required.
    final amount = _pickTransactionAmount(normalized);
    if (amount == null) {
      return MpesaError(SmsParseError(reason: 'no_amount', rawSms: sms));
    }

    final date = extractMpesaDateMs(normalized, smsTimestampMs);

    // Stage 3 — classify; unknown formats quarantine (no data loss).
    final match = _detectRule(normalized);
    if (match == null) {
      final semHash = buildSemanticHash(TxCategory.unknown, amount, date, null);
      return MpesaSuccess(MpesaParsedTransaction(
        mpesaCode: code,
        amount: amount,
        category: TxCategory.unknown,
        confidence: PConfidence.low,
        counterparty: null,
        description: _buildDescription(TxCategory.unknown, null, amount),
        balanceAfter: _parseBalance(normalized),
        fee: _parseFee(normalized),
        date: date,
        rawSms: sms,
        parseRoute: ParseRoute.quarantine,
        matchedRulePhase: 0,
        semanticHash: semHash,
        merchantCategory: resolveMerchantCategory(null, TxCategory.unknown),
      ));
    }

    // Stage 4 — counterparty.
    final counterparty = _extractCounterparty(normalized, match.rule);

    // Stage 5 — enrichment.
    final balance = _parseBalance(normalized);

    double? fulizaOutstanding;
    if (match.rule.category == TxCategory.fulizaCharge) {
      fulizaOutstanding = _toDouble(_fulizaOutstandingRe.firstMatch(normalized)?.group(1));
    }
    double? fulizaAvailLimit;
    if (match.rule.category == TxCategory.loan) {
      fulizaAvailLimit = _toDouble(_fulizaAvailLimitRe.firstMatch(normalized)?.group(1));
    }

    // Phase 1.4 — 6-factor weighted confidence scoring.
    final breakdown = SmsConfidenceScorer.score(
      mpesaCode: code,
      amount: amount,
      dateMs: date,
      counterparty: counterparty,
      category: match.rule.category,
      senderTrust: senderTrust,
      nowMs: smsTimestampMs,
    );
    final finalConfidence = SmsConfidenceScorer.mapToConfidence(breakdown);

    final parseRoute = switch (finalConfidence) {
      PConfidence.high => ParseRoute.directLedger,
      PConfidence.medium => ParseRoute.reviewQueue,
      PConfidence.low => ParseRoute.quarantine,
    };

    // Stage 5d — Gap 6 reversal direction flip.
    final isReceivedReversal = match.rule.category == TxCategory.reversed &&
        _receivedReversedRe.hasMatch(normalized);

    // Stage 5e — Gap 7 inline semantic hash.
    final semanticHash =
        buildSemanticHash(match.rule.category, amount, date, counterparty);

    return MpesaSuccess(MpesaParsedTransaction(
      mpesaCode: code,
      amount: amount,
      category: match.rule.category,
      confidence: finalConfidence,
      counterparty: counterparty,
      description: _buildDescription(match.rule.category, counterparty, amount),
      balanceAfter: balance,
      fee: _parseFee(normalized),
      date: date,
      rawSms: sms,
      parseRoute: parseRoute,
      semanticHash: semanticHash,
      matchedRulePhase: match.phase,
      merchantCategory: resolveMerchantCategory(counterparty, match.rule.category),
      fulizaOutstandingKes: fulizaOutstanding,
      fulizaAvailableLimitKes: fulizaAvailLimit,
      isReceivedReversal: isReceivedReversal,
    ));
  } catch (e) {
    return MpesaError(SmsParseError(reason: 'parse_exception: $e', rawSms: sms));
  }
}

/// Decision-tree demotion helper used by ParserPipeline (parity with
/// TransactionDecisionTree.shouldDemote).
bool decisionTreeShouldDemote(String body, PConfidence confidence) {
  final features = SmsFeatureExtractor.extract(body);
  final verdict = evaluateTree(features);
  return shouldDemoteToReview(verdict, confidence);
}
