/// 1:1 port of AirtelMoneyParser.kt.
library;

import 'generic_bank_parser.dart';
import 'mpesa_date_parser.dart' show extractMpesaDateMs;
import 'parser_types.dart';
import 'sms_normalizer.dart' show normalizeForHash, sha256Hex;

final _amountRe = RegExp(r'KES\s*([0-9,]+(?:\.[0-9]{1,2})?)');
final _refRe =
    RegExp(r'(?:transaction\s*id|txn\s*id|trans\s*id)[:\s#]+(AIR[0-9]{5,15})', caseSensitive: false);
final _balanceRe = RegExp(
    r'(?:new\s+)?balance\s+(?:is\s+)?KES\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false);
final _feeRe = RegExp(r'charges?[:\s]+KES\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false);

final _fromRe = RegExp(
    r"\bfrom\s+([A-Za-z][A-Za-z0-9 .\-']{1,35}?)(?:\s*\(|(?:\s+on\s+\d))",
    caseSensitive: false);
final _toRe = RegExp(
    r"\bto\s+([A-Za-z][A-Za-z0-9 .\-']{1,35}?)(?:\s*\(|(?:\s+on\s+\d))",
    caseSensitive: false);

final _creditRe = RegExp(r'\b(?:received?|credited?|deposit)\b', caseSensitive: false);
final _debitRe = RegExp(r'\b(?:sent|paid|payment|withdraw[an]l?)\b', caseSensitive: false);
final _withdrawRe = RegExp(r'\b(?:withdraw[an]l?|cash\s*out|atm)\b', caseSensitive: false);
final _paybillRe = RegExp(r'\b(?:paid\s+to|merchant|paybill|buy\s+goods)\b', caseSensitive: false);
final _airtimeRe = RegExp(r'\b(?:airtime|data\s+bundle)\b', caseSensitive: false);

bool airtelCanParse(String body, String sender) {
  final sUp = sender.trim().toUpperCase();
  if (sUp.contains('AIRTEL')) return true;
  if (body.toUpperCase().startsWith('AIRTEL MONEY:')) return true;
  return body.contains('KES') && body.toLowerCase().contains('airtel');
}

BankParseResult airtelMoneyParse(String body, String sender, int receivedAtMs) {
  final amountRaw = _amountRe.firstMatch(body)?.group(1)?.replaceAll(',', '');
  final amount = double.tryParse(amountRaw ?? '');
  if (amount == null) {
    return BankError(BankParseError('no_amount', ''));
  }
  if (amount <= 0) {
    return BankError(BankParseError('zero_amount', '', receivedAtMs));
  }

  final refRaw = _refRe.firstMatch(body)?.group(1)?.trim();
  final balance = double.tryParse(_balanceRe.firstMatch(body)?.group(1)?.replaceAll(',', '') ?? '');
  final fee = double.tryParse(_feeRe.firstMatch(body)?.group(1)?.replaceAll(',', '') ?? '');

  final isCredit = _creditRe.hasMatch(body);
  final isDebit = _debitRe.hasMatch(body);
  final isWithdraw = _withdrawRe.hasMatch(body);
  final isPaybill = _paybillRe.hasMatch(body);
  final isAirtime = _airtimeRe.hasMatch(body);

  TxCategory category;
  if (isCredit && !isDebit) {
    category = TxCategory.received;
  } else if (isWithdraw) {
    category = TxCategory.withdraw;
  } else if (isAirtime) {
    category = TxCategory.airtime;
  } else if (isPaybill) {
    category = TxCategory.paybill;
  } else if (isDebit) {
    category = TxCategory.sent;
  } else {
    category = TxCategory.unknown;
  }

  String? counterparty;
  if (isCredit) {
    counterparty = _fromRe.firstMatch(body)?.group(1)?.trim();
  } else if (isDebit) {
    counterparty = _toRe.firstMatch(body)?.group(1)?.trim();
  }

  PConfidence confidence;
  if (refRaw != null && (isCredit || isDebit)) {
    confidence = PConfidence.high;
  } else if ((balance != null || counterparty != null) && (isCredit || isDebit)) {
    confidence = PConfidence.medium;
  } else if (isCredit || isDebit) {
    confidence = PConfidence.medium;
  } else {
    confidence = PConfidence.low;
  }

  final parseRoute = switch (confidence) {
    PConfidence.high => ParseRoute.directLedger,
    PConfidence.medium => ParseRoute.reviewQueue,
    PConfidence.low => ParseRoute.quarantine,
  };

  // Parse transaction date from the SMS body (same as GenericBankParser),
  // falling back to receivedAtMs only when no date is embedded.
  final txDate = extractMpesaDateMs(body, receivedAtMs);

  final sourceHash = sha256Hex(normalizeForHash(body));
  final externalRef =
      (refRaw != null && refRaw.isNotEmpty) ? refRaw : 'airtel:${amount.toInt()}:${txDate ~/ 60000}';
  final description = _buildDescription(category, amount, counterparty);
  // Semantic hash uses txDate (parsed from body) so deduplication is stable
  // across re-imports where the SMS delivery timestamp may differ.
  final semanticHash =
      'sem_${sha256Hex('airtel|${category.wireName}|${amount.toInt()}|${txDate ~/ 60000}|${counterparty ?? ''}').substring(0, 16)}';

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
    institutionId: 'airtel',
    currency: 'KES',
    rawSender: sender,
  ));
}

String _buildDescription(TxCategory category, double amount, String? counterparty) {
  final amtStr = 'KES ${amount.toStringAsFixed(2)}';
  final prep = category == TxCategory.received ? 'from' : 'to';
  final party = (counterparty != null && counterparty.isNotEmpty) ? ' $prep $counterparty' : '';
  switch (category) {
    case TxCategory.received:
      return 'Airtel Money Received $amtStr$party';
    case TxCategory.sent:
      return 'Airtel Money Sent $amtStr$party';
    case TxCategory.withdraw:
      return 'Airtel Money Withdrawal $amtStr';
    case TxCategory.airtime:
      return 'Airtel Airtime $amtStr';
    case TxCategory.paybill:
      return 'Airtel Money Payment $amtStr$party';
    default:
      return 'Airtel Money $amtStr';
  }
}
