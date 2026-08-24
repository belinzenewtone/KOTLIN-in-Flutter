/// Shared parser types — 1:1 port of the type system spread across
/// MpesaParsingConfig.kt, MpesaParserEnhanced.kt, SenderTrust.kt and
/// MerchantCategory.kt.
library;

/// Semantic transaction categories (MpesaParsingConfig.TransactionCategory).
enum TxCategory {
  received,
  sent,
  airtime,
  paybill,
  buyGoods,
  deposit,
  withdraw,
  reversed,
  loan,
  fulizaCharge,
  unknown;

  /// Wire name used in DB columns and semantic hashes — matches Kotlin enum name.
  String get wireName => switch (this) {
        TxCategory.received => 'RECEIVED',
        TxCategory.sent => 'SENT',
        TxCategory.airtime => 'AIRTIME',
        TxCategory.paybill => 'PAYBILL',
        TxCategory.buyGoods => 'BUY_GOODS',
        TxCategory.deposit => 'DEPOSIT',
        TxCategory.withdraw => 'WITHDRAW',
        TxCategory.reversed => 'REVERSED',
        TxCategory.loan => 'LOAN',
        TxCategory.fulizaCharge => 'FULIZA_CHARGE',
        TxCategory.unknown => 'UNKNOWN',
      };

  static TxCategory fromWire(String name) => TxCategory.values.firstWhere(
        (e) => e.wireName == name.toUpperCase(),
        orElse: () => TxCategory.unknown,
      );

  /// Display name stored on transactions ("Sent", "Paybill", ...) — mirrors the
  /// Kotlin `name.lowercase().replaceFirstChar { it.uppercase() }` mapping.
  String get displayLabel {
    final n = wireName.toLowerCase();
    if (n == 'fuliza_charge') return 'Fuliza charge';
    if (n == 'buy_goods') return 'Buy goods';
    return '${n[0].toUpperCase()}${n.substring(1)}';
  }
}

/// Confidence levels assigned during parsing.
enum PConfidence { high, medium, low }

/// Route determining how the ingestion pipeline handles a parsed transaction.
enum ParseRoute { directLedger, reviewQueue, quarantine }

/// Sender trust tiers for confidence scoring.
enum SenderTrustLevel { officialMpesa, airtelMoney, bank, unknown }

/// Human-readable labels by category (MpesaParsingConfig.CATEGORY_DISPLAY).
const Map<TxCategory, String> kCategoryDisplay = {
  TxCategory.received: 'M-Pesa Received',
  TxCategory.sent: 'Transfer',
  TxCategory.airtime: 'Airtime',
  TxCategory.paybill: 'Utilities',
  TxCategory.buyGoods: 'Shopping',
  TxCategory.deposit: 'Deposit',
  TxCategory.withdraw: 'Cash Withdrawal',
  TxCategory.reversed: 'Reversal',
  TxCategory.loan: 'Loans & Credit',
  TxCategory.fulizaCharge: 'Fuliza Charge',
  TxCategory.unknown: 'Other',
};

/// Fine-grained merchant sub-categories (MerchantCategory.kt).
enum MerchantCategory {
  food('Food & Restaurants'),
  groceries('Groceries & Supermarket'),
  transport('Transport & Ride-hailing'),
  fuel('Fuel & Gas'),
  health('Health & Pharmacy'),
  utilities('Utilities'),
  telecoms('Telecoms & Internet'),
  banking('Banking & Financial'),
  education('Education'),
  housing('Housing & Rent'),
  loans('Loans & Credit'),
  insurance('Insurance'),
  government('Government & Tax'),
  entertainment('Entertainment'),
  shopping('Shopping'),
  other('Other');

  const MerchantCategory(this.label);
  final String label;
}

/// Structured parse error.
class SmsParseError {
  SmsParseError({required this.reason, required this.rawSms, int? timestampMs})
      : timestampMs = timestampMs ?? DateTime.now().millisecondsSinceEpoch;

  final String reason;
  final String rawSms;
  final int timestampMs;
}
