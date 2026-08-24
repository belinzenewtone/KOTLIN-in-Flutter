/// 1:1 port of GenericBankParser.kt — semantic token extractor for Kenyan
/// commercial bank SMS + AirtelMoneyParser.kt.
library;

import 'dart:convert';
import 'cross_parser_voter.dart' show ParsedTransactionBase, resolveMerchantCategory;
import 'institution_detector.dart';
import 'mpesa_date_parser.dart';
import 'parser_types.dart';
import 'sms_normalizer.dart' show normalizeForHash, sha256Hex;

class BankParseError {
  BankParseError(this.reason, this.rawSms, [int? timestampMs])
      : timestampMs = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
  final String reason;
  final String rawSms;
  final int timestampMs;
}

sealed class BankParseResult {
  const BankParseResult();
}

class BankSuccess extends BankParseResult {
  const BankSuccess(this.transaction);
  final ParsedBankTransaction transaction;
}

class BankError extends BankParseResult {
  const BankError(this.error);
  final BankParseError error;
}

class ParsedBankTransaction implements ParsedTransactionBase {
  const ParsedBankTransaction({
    required this.externalRef,
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
    required this.sourceHash,
    required this.institutionId,
    required this.rawSender,
    this.currency = 'KES',
    this.crossRefMpesaCode,
    this.merchantCategory = MerchantCategory.other,
  });

  final String externalRef;
  @override
  final double amount;
  @override
  final TxCategory category;
  final PConfidence confidence;
  @override
  final String? counterparty;
  final String description;
  final double? balanceAfter;
  final double? fee;
  final int date;
  final String rawSms;
  @override
  final ParseRoute parseRoute;
  final String semanticHash;
  final String sourceHash;
  final String institutionId;
  final String currency;
  final String rawSender;
  final String? crossRefMpesaCode;
  final MerchantCategory merchantCategory;

  bool get isIncome =>
      category == TxCategory.received || category == TxCategory.deposit;

  bool get isExpense => switch (category) {
        TxCategory.sent ||
        TxCategory.airtime ||
        TxCategory.paybill ||
        TxCategory.buyGoods ||
        TxCategory.withdraw => true,
        _ => false,
      };
}

// ── Regexes (verbatim from Kotlin) ───────────────────────────────────────────

final _amountCrdrPrefix = RegExp(
  r'\b(?:cr|dr)[:\s]+(?:k\.?shs?\.?|kes\.?)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);
final _amountCurrency = RegExp(
  r'(?:k\.?shs?\.?|kes\.?)\s*([0-9,]+(?:\.[0-9]{1,2})?)(?:\s*(?:cr|dr))?',
  caseSensitive: false,
);
final _amountReverse = RegExp(
  r'([0-9,]+(?:\.[0-9]{1,2})?)\s+(?:k\.?shs?\.?|kes)\b',
  caseSensitive: false,
);
final _amountLabel = RegExp(
  r'(?:amount|principal|value|sum)[:\s]+([0-9,]+(?:\.[0-9]{1,2})?)(?!\s*[A-Za-z])',
  caseSensitive: false,
);
final _amountBare = RegExp(
  r'([0-9,]{3,}(?:\.[0-9]{1,2})?)\s+(?:has been\s+)?(?:debited|credited|deducted|charged)',
  caseSensitive: false,
);

final _crSuffix = RegExp(r'(?:k\.?shs?\.?|kes\.?)\s*[0-9,]+(?:\.[0-9]{1,2})?\s+cr\b', caseSensitive: false);
final _drSuffix = RegExp(r'(?:k\.?shs?\.?|kes\.?)\s*[0-9,]+(?:\.[0-9]{1,2})?\s+dr\b', caseSensitive: false);
final _crPrefix = RegExp(r'\bcr[:\s]+(?:k\.?shs?\.?|kes\.?)', caseSensitive: false);
final _drPrefix = RegExp(r'\bdr[:\s]+(?:k\.?shs?\.?|kes\.?)', caseSensitive: false);

final _creditRe = RegExp(
  r'\b(?:received?|credited?|deposited?|deposit|credit|funds?\s+received|payment\s+received|inward\s+(?:transfer|remittance))\b',
  caseSensitive: false,
);
final _debitRe = RegExp(
  r'\b(?:sent|send\s+to|paid|payment|debited?|deducted?|purchas\w+|bought|outward\s+(?:transfer|remittance)|funds?\s+(?:sent|transferred))\b',
  caseSensitive: false,
);
final _cardDebitRe = RegExp(
  r'(?:(?:transaction|payment)\s+(?:of\s+(?:k\.?shs?\.?|kes\.?).*)?(?:was\s+made|has\s+been\s+(?:made|processed))\s+on\s+(?:your\s+)?card|approved\s+on\s+(?:your\s+)?card\s+ending)',
  caseSensitive: false,
);
final _transferRe =
    RegExp(r'\b(?:transferr?ed?|transfer\s+to|transfer\s+from|funds?\s+transfer)\b', caseSensitive: false);
final _withdrawRe = RegExp(
  r'\b(?:withdraw(?:al|n)?|cash\s*out|atm\s*(?:withdrawal)?|agent\s+(?:cash\s*out|withdrawal))\b',
  caseSensitive: false,
);
final _paybillRe = RegExp(
  r'\b(?:paybill|pay\s*bill|utility|bill\s+payment|merchant|buy\s+goods|airtime|till\s+(?:no\.?|number))\b',
  caseSensitive: false,
);
final _reversalRe =
    RegExp(r'\b(?:reversed?|reversal|refund(?:ed)?|chargeback)\b', caseSensitive: false);

final _accountCredited =
    RegExp(r'\baccount\s+(?:[0-9X*]+\s+)?(?:has been\s+)?credited\b', caseSensitive: false);
final _accountDebited =
    RegExp(r'\baccount\s+(?:[0-9X*]+\s+)?(?:has been\s+)?debited\b', caseSensitive: false);

final _refRe = RegExp(
  r'(?:ref(?:erence)?(?:\s*(?:no\.?|num(?:ber)?|id))?'
  r'|txn\s*(?:id|no\.?|ref)'
  r'|trans(?:action)?\s*(?:id|no\.?|ref\.?)'
  r'|receipt\s*(?:no\.?|id)'
  r'|payment\s*(?:ref|id|code)'
  r'|confirmation\s*(?:no\.?|code)'
  r'|auth(?:orisation|orization)?\s*(?:code|no\.?)'
  r'|approval\s*(?:code|no\.?)'
  r'|trn|tran\s*id|trace\s*(?:no\.?|id)'
  r'|narration)[:\s#]+([A-Z0-9]{5,25})',
  caseSensitive: false,
);

final _narrationRe = RegExp(r'narration[:\s]+([^\n.;]{3,60})', caseSensitive: false);

final _balanceRe = RegExp(
  r'(?:(?:new|closing|running|available|current|book|ledger)\s+)?'
  r'(?:(?:a\/?c|account|acc\.?)\s+)?'
  r'bal(?:ance)?\s*(?:is|:|\s)\s*'
  r'(?:k\.?shs?\.?|kes\.?)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);

final _balanceAfterRe = RegExp(
  r'bal(?:ance)?\s+after\s+(?:transaction\s+)?[:\s]*(?:k\.?shs?\.?|kes\.?)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);

final _feeRe = RegExp(
  r'(?:charges?|fees?|commission|levy|excise)(?:\s+charged\s+is)?[:\s]+(?:k\.?shs?\.?|kes\.?)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);

final _fromRe = RegExp(r"\bfrom\s+([A-Za-z][A-Za-z0-9 .&'/\-]{1,40})", caseSensitive: false);
final _toRe = RegExp(r"\bto\s+([A-Za-z][A-Za-z0-9 .&'/\-]{1,40})", caseSensitive: false);
final _accountNumRe =
    RegExp(r'(?:a\/?c|account|acct)\.?\s*(?:no\.?\s*)?([0-9X*]{4,20})', caseSensitive: false);
final _mpesaCrossrefRe =
    RegExp(r'(?:m-?pesa|loop)\s+ref\s+([A-Z0-9]{9,12})', caseSensitive: false);
final _paybillNumRe =
    RegExp(r'(?:paybill|till)\s*(?:no\.?)?\s*:?\s*([0-9]{4,10})', caseSensitive: false);
final _partyTail = RegExp(
  r'\s*(?:\(.*|\bon\s+\d|\bat\s+\d|ref|txn|trans|balance|bal\b|your|k\.?shs?\.?|kes|\d{5,}|a\/?c|account).*$',
  caseSensitive: false,
);

final _serviceNoticeRe = RegExp(
  r'(?:one[\s-]?time\s+password|your\s+otp\s+is|verification\s+code|security\s+code|'
  r'never\s+share\s+this\s+code|'
  r'will\s+never\s+(?:call|ask)\s+you|do\s+not\s+share|'
  r'scheduled\s+(?:system\s+)?(?:maintenance|enhancements?|upgrade)|'
  r'(?:temporarily|currently)\s+unavailable|services?\s+(?:have\s+been|has\s+been)\s+restored|'
  r'branches?\s+will\s+(?:be\s+closed|remain\s+closed)|'
  r'we\s+are\s+(?:building|working\s+to\s+resolve)|'
  r'dear\s+customer,?\s+(?:in\s+celebration|in\s+observation|please\s+do\s+not\s+share)|'
  r'increased\s+our\s+daily\s+(?:atm|withdrawal)\s+limit|'
  r'make\s+the\s+most\s+out\s+of|'
  r'we\s+are\s+delighted\s+to\s+inform|'
  r'your\s+security\s+is\s+our\s+priority|'
  r'use\s+code\s+\d|'
  r'will\s+be\s+under\s+maintenance|'
  r'all\s+(?:our\s+)?services\s+are\s+fully\s+accessible|'
  r'successfully\s+(?:registered|de-registered)\s+for\s+sc\s+mobile\s+key|'
  r'account\s+will\s+become\s+dormant|'
  r'partnered\s+with\s+kenswitch|'
  r'access\s+to\s+investment\s+profiling|'
  r'a\s+better,\s+smarter\s+loop\s+app|'
  r'new\s+(?:security\s+)?app\s+update|'
  r'hey\s+looper|'
  r'loop\s+stores\s+will|'
  r'service\s+interruption\s+on\s+all\s+loop|'
  r'our\s+technical\s+team\s+is\s+actively\s+working|'
  r'base\s+lending\s+rate\s+shall\s+be\s+revised|'
  r'cbk.s\s+decision\s+to\s+reduce|'
  r'savings\s+challenge\s+from\s+kes|'
  r'you\s+have\s+entered\s+the\s+wrong\s+pin|'
  r'kaa\s+chonjo|'
  r'has\s+been\s+Declined\s+on\s+your\s+card|'
  r'Online\s+transaction\s+of\s+.*\s+has\s+been\s+Declined|'
  r'your\s+payment\s+for\s+the\s+(?:airtel|safaricom)\s+airtime\s+was\s+unsuccessful|'
  r'we\s+have\s+received\s+your\s+service\s+request\s+tracking\s+number)',
  caseSensitive: false,
);

bool isServiceNotice(String message) => _serviceNoticeRe.hasMatch(message);

bool bankCanParse(Detection? detection) {
  if (detection == null) return false;
  return detection.institutionId != 'mpesa' && detection.institutionId != 'airtel';
}

double? _extractAmount(String body) {
  double? v;
  if ((v = _toDouble(_amountCrdrPrefix.firstMatch(body)?.group(1))) != null) return v;
  if ((v = _toDouble(_amountCurrency.firstMatch(body)?.group(1))) != null) return v;

  final rev = _toDouble(_amountReverse.firstMatch(body)?.group(1));
  if (rev != null && rev > 0) return rev;

  final label = _toDouble(_amountLabel.firstMatch(body)?.group(1));
  if (label != null && label > 0) return label;

  if ((v = _toDouble(_amountBare.firstMatch(body)?.group(1))) != null) return v;
  return null;
}

double? _toDouble(String? raw) {
  if (raw == null) return null;
  return double.tryParse(raw.replaceAll(',', ''));
}

String? _cleanParty(String raw) {
  final cleaned = raw.replaceFirst(_partyTail, '').trim();
  return cleaned.length >= 2 ? cleaned : null;
}

String? _extractCounterparty(String body, TxCategory category, bool isPaybill) {
  if (isPaybill) {
    final paybillNum = _paybillNumRe.firstMatch(body)?.group(1);
    if (paybillNum != null && paybillNum.isNotEmpty) return 'Paybill $paybillNum';
  }

  String? named;
  switch (category) {
    case TxCategory.received:
      named = _cleanParty(_fromRe.firstMatch(body)?.group(1) ?? '');
      break;
    case TxCategory.sent:
    case TxCategory.paybill:
      named = _cleanParty(_toRe.firstMatch(body)?.group(1) ?? '');
      break;
    default:
      named = _cleanParty(_fromRe.firstMatch(body)?.group(1) ?? '') ??
          _cleanParty(_toRe.firstMatch(body)?.group(1) ?? '');
  }
  if (named != null && named.isNotEmpty) return named;

  final narration = _narrationRe.firstMatch(body)?.group(1)?.trim();
  if (narration != null &&
      narration.length >= 3 &&
      !narration.codeUnits.every((c) => c >= 0x30 && c <= 0x39)) {
    return narration;
  }

  final acct = _accountNumRe.firstMatch(body)?.group(1)?.trim();
  if (acct != null && acct.isNotEmpty) return 'A/C $acct';

  return null;
}

String _bankDescription(
    String instId, TxCategory category, double amount, String? counterparty) {
  final bank = instId.isEmpty ? instId : '${instId[0].toUpperCase()}${instId.substring(1)}';
  final amtStr = 'KES ${amount.toStringAsFixed(2)}';
  final prep = category == TxCategory.received ? 'from' : 'to';
  final party = (counterparty != null && counterparty.isNotEmpty) ? ' $prep $counterparty' : '';
  switch (category) {
    case TxCategory.received:
      return '$bank Credit $amtStr$party';
    case TxCategory.sent:
      return '$bank Transfer $amtStr$party';
    case TxCategory.withdraw:
      return '$bank Withdrawal $amtStr';
    case TxCategory.paybill:
      return '$bank Payment $amtStr$party';
    case TxCategory.deposit:
      return '$bank Deposit $amtStr';
    case TxCategory.reversed:
      return '$bank Reversal $amtStr';
    default:
      return '$bank Transaction $amtStr';
  }
}

BankParseResult genericBankParse(
    String body, String sender, int receivedAtMs, Detection? detection) {
  final instId = detection?.institutionId ?? 'bank';

  final amount = _extractAmount(body);
  if (amount == null) {
    return BankError(BankParseError('no_amount', body, receivedAtMs));
  }
  if (amount <= 0) {
    return BankError(BankParseError('zero_amount', body, receivedAtMs));
  }

  final refRaw = _refRe.firstMatch(body)?.group(1)?.trim();
  final crossRefMpesaCode = _mpesaCrossrefRe.firstMatch(body)?.group(1)?.trim();
  final balance = _toDouble(_balanceAfterRe.firstMatch(body)?.group(1)) ??
      _toDouble(_balanceRe.firstMatch(body)?.group(1));
  final fee = _toDouble(_feeRe.firstMatch(body)?.group(1));

  // Direction — CR/DR notation takes priority over word signals.
  final isCrDr = _crSuffix.hasMatch(body) || _crPrefix.hasMatch(body);
  final isDrDr = _drSuffix.hasMatch(body) || _drPrefix.hasMatch(body);

  final isCredit = isCrDr || _creditRe.hasMatch(body) || _accountCredited.hasMatch(body);
  final isDebit = isDrDr ||
      _debitRe.hasMatch(body) ||
      _transferRe.hasMatch(body) ||
      _accountDebited.hasMatch(body) ||
      _cardDebitRe.hasMatch(body);
  final isWithdraw = _withdrawRe.hasMatch(body);
  final isPaybill = _paybillRe.hasMatch(body);
  final isReversal = _reversalRe.hasMatch(body);

  final TxCategory category;
  if (isReversal) {
    category = TxCategory.reversed;
  } else if (isCredit && !isDebit) {
    category = TxCategory.received;
  } else if (isCredit && isDebit && crossRefMpesaCode != null) {
    category = TxCategory.received;
  } else if (isWithdraw) {
    category = TxCategory.withdraw;
  } else if (isPaybill && isDebit) {
    category = TxCategory.paybill;
  } else if (isDebit) {
    category = TxCategory.sent;
  } else {
    category = TxCategory.unknown;
  }

  final counterparty = _extractCounterparty(body, category, isPaybill);

  var fieldCount = 0;
  if (refRaw != null) fieldCount++;
  if (balance != null) fieldCount++;
  if (counterparty != null) fieldCount++;
  final hasDirection = isCredit || isDebit || isWithdraw || isPaybill;

  final PConfidence confidence;
  if (fieldCount >= 2 && hasDirection) {
    confidence = PConfidence.high;
  } else if ((fieldCount >= 1 && hasDirection) ||
      (hasDirection) ||
      fieldCount >= 2) {
    confidence = PConfidence.medium;
  } else {
    confidence = PConfidence.low;
  }
  // Exact Kotlin mapping:
  final mapped = (fieldCount >= 2 && hasDirection)
      ? PConfidence.high
      : ((fieldCount >= 1 && hasDirection) || hasDirection || fieldCount >= 2)
          ? PConfidence.medium
          : PConfidence.low;
  assert(mapped == confidence);

  final parseRoute = switch (confidence) {
    PConfidence.high => ParseRoute.directLedger,
    PConfidence.medium => ParseRoute.reviewQueue,
    PConfidence.low => ParseRoute.quarantine,
  };

  final txDate = extractMpesaDateMs(body, receivedAtMs);

  final sourceHash = sha256Hex(normalizeForHash(body));
  final externalRef =
      (refRaw != null && refRaw.isNotEmpty) ? refRaw : '$instId:${amount.toInt()}:${receivedAtMs ~/ 60000}';
  final description = _bankDescription(instId, category, amount, counterparty);
  final semanticHash = 'sem_${sha256Hex('$instId|${category.wireName}|${amount.toInt()}|${txDate ~/ 60000}|${counterparty ?? ''}').substring(0, 16)}';

  return BankSuccess(ParsedBankTransaction(
    externalRef: externalRef,
    amount: amount,
    category: category,
    confidence: confidence,
    counterparty: counterparty,
    description: description,
    balanceAfter: balance,
    fee: fee,
    date: txDate,
    rawSms: body,
    parseRoute: parseRoute,
    semanticHash: semanticHash,
    sourceHash: sourceHash,
    institutionId: instId,
    currency: 'KES',
    rawSender: sender,
    crossRefMpesaCode: crossRefMpesaCode,
    merchantCategory: resolveMerchantCategory(counterparty, category),
  ));
}
