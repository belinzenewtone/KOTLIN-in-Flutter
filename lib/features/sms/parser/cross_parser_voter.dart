/// 1:1 port of CrossParserVoter.kt + MerchantCategory.kt (resolver).
library;

import 'parser_types.dart';
import 'simple_parser_and_tree.dart';

// ── CrossParserVoter ─────────────────────────────────────────────────────────

/// Maximum relative amount difference before parsers "disagree" (5%).
const double kAmountThreshold = 0.05;

/// Applies the secondary vote: if the independent fallback parser disagrees on
/// category or amount (>5%), a DIRECT_LEDGER route is demoted to REVIEW_QUEUE.
/// Already-demoted routes are untouched.
ParseRoute applyCrossParserVote(ParsedTransactionBase tx, String rawSms) {
  if (tx.parseRoute != ParseRoute.directLedger) return tx.parseRoute;

  final fallback = simpleMpesaParse(rawSms);
  if (fallback == null) return tx.parseRoute;

  final categoriesAgree = tx.category == fallback.category;
  final amountsAgree = (fallback.amount != null && tx.amount > 0)
      ? ((tx.amount - fallback.amount!).abs() / tx.amount <= kAmountThreshold)
      : true;

  return (!categoriesAgree || !amountsAgree) ? ParseRoute.reviewQueue : tx.parseRoute;
}

// ── MerchantCategoryResolver ────────────────────────────────────────────────

final RegExp _foodRe = RegExp(
  r'\b(?:restaurant|cafe|coffee|kfc|java|chicken inn|pizza|subway|domino|artcaffe|big square|steers|debonairs|galito|mama rocks|ocean basket|burger|grill|canteen|bistro|eatery|deli)\b',
  caseSensitive: false,
);
final RegExp _groceriesRe = RegExp(
  r'\b(?:naivas|quickmart|carrefour|cleanshelf|tuskys|chandarana|eastmatt|supermarket|mart\b|hypermarket|wholesale|mini.?mart|groceries|fresh|farm fresh)\b',
  caseSensitive: false,
);
final RegExp _transportRe = RegExp(
  r'\b(?:uber|bolt|little cab|swvl|faras|bus|shuttle|matatu|kenya railways|sgr|taxify|indriver|ride|hailing|boda|okoa)\b',
  caseSensitive: false,
);
final RegExp _fuelRe = RegExp(
  r'\b(?:shell|total|rubis|oilibya|kenol|kobil|ola energy|vivo|gulf energy|petrol|diesel|fuel|pump|station)\b',
  caseSensitive: false,
);
final RegExp _healthRe = RegExp(
  r'\b(?:pharmacy|chemist|hospital|clinic|medical|health|dispensary|lab|nhif|insurance.*health|dentist|doctor|optician|pathology)\b',
  caseSensitive: false,
);
final RegExp _utilitiesRe = RegExp(
  r'\b(?:kplc|kenya power|nairobi water|nwsc|water|electricity|power|wastewater|sewerage|garbage|nea|waste|zuku fibre)\b',
  caseSensitive: false,
);
final RegExp _telecomsRe = RegExp(
  r'\b(?:safaricom|airtel|telkom|faiba|zuku|liquid|jamii|wananchi|internet|broadband|fibre|data|bundle|airtime|sms pack)\b',
  caseSensitive: false,
);
final RegExp _bankingRe = RegExp(
  r'\b(?:kcb|equity|co.?op|ncba|loop|absa|stanbic|stanchart|dtb|family bank|im bank|hf group|sbm|prime bank|bank|sacco|microfinance|mshwari|fuliza|loop)\b',
  caseSensitive: false,
);
final RegExp _educationRe = RegExp(
  r'\b(?:school|college|university|institute|tuition|exam|kcpe|kcse|uon|ku|kenyatta|strathmore|usiu|daystar|nimr|nemis|education|fees?|bursary)\b',
  caseSensitive: false,
);
final RegExp _housingRe = RegExp(
  r'\b(?:rent|house|apartment|bedsitter|studio|landlord|caretaker|property|estate|plot|lease|tenancy|accommodation|hostel)\b',
  caseSensitive: false,
);
final RegExp _loansRe = RegExp(
  r'\b(?:loan|fuliza|mshwari|kcb mpesa|tala|branch|okolea|zenka|timiza|vooma|repay|installment|credit|interest)\b',
  caseSensitive: false,
);
final RegExp _insuranceRe = RegExp(
  r'\b(?:insurance|assurance|jubilee|aar|britam|cic|madison|old mutual|pioneer|resolution|amaco|kenindia|premium|policy|cover)\b',
  caseSensitive: false,
);
final RegExp _governmentRe = RegExp(
  r'\b(?:kra|kenya revenue|ntsa|helb|nssf|nhif|county|government|ecitizen|huduma|judiciary|ministry|lands|nairobi city|tax|duty|permit)\b',
  caseSensitive: false,
);
final RegExp _entertainmentRe = RegExp(
  r'\b(?:netflix|spotify|youtube|showmax|dstv|gotv|startimes|binge|canal|cinema|imax|anga|cinemax|movie|concert|ticket|event|gaming|steam|playstation)\b',
  caseSensitive: false,
);
final RegExp _shoppingRe = RegExp(
  r'\b(?:jumia|kilimall|masoko|amazon|alibaba|aliexpress|shein|fashion|clothing|shoes|electronics|phone|laptop|computer|gadget|mall|boutique)\b',
  caseSensitive: false,
);

MerchantCategory resolveMerchantCategory(String? counterparty, TxCategory txCategory) {
  // Category-level overrides — no need to inspect counterparty.
  switch (txCategory) {
    case TxCategory.airtime:
      return MerchantCategory.telecoms;
    case TxCategory.loan:
    case TxCategory.fulizaCharge:
      return MerchantCategory.loans;
    default:
      break;
  }

  final name = counterparty;
  if (name == null || name.trim().isEmpty) return MerchantCategory.other;

  if (_governmentRe.hasMatch(name)) return MerchantCategory.government;
  if (_healthRe.hasMatch(name)) return MerchantCategory.health;
  if (_insuranceRe.hasMatch(name)) return MerchantCategory.insurance;
  if (_educationRe.hasMatch(name)) return MerchantCategory.education;
  if (_utilitiesRe.hasMatch(name)) return MerchantCategory.utilities;
  if (_housingRe.hasMatch(name)) return MerchantCategory.housing;
  if (_loansRe.hasMatch(name)) return MerchantCategory.loans;
  if (_bankingRe.hasMatch(name)) return MerchantCategory.banking;
  if (_foodRe.hasMatch(name)) return MerchantCategory.food;
  if (_groceriesRe.hasMatch(name)) return MerchantCategory.groceries;
  if (_fuelRe.hasMatch(name)) return MerchantCategory.fuel;
  if (_transportRe.hasMatch(name)) return MerchantCategory.transport;
  if (_telecomsRe.hasMatch(name)) return MerchantCategory.telecoms;
  if (_entertainmentRe.hasMatch(name)) return MerchantCategory.entertainment;
  if (_shoppingRe.hasMatch(name)) return MerchantCategory.shopping;
  return MerchantCategory.other;
}

// ── ParsedTransactionBase ───────────────────────────────────────────────────

/// Common fields shared by the M-Pesa and bank parsed results so the voter and
/// ingestion pipeline can operate polymorphically.
abstract class ParsedTransactionBase {
  double get amount;
  TxCategory get category;
  ParseRoute get parseRoute;
  String? get counterparty;
}
