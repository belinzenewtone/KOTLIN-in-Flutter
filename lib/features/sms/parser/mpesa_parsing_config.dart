/// 1:1 port of MpesaParsingConfig.kt — detection rules, fallbacks,
/// counterparty patterns and the Fuliza service-notice filter.
///
/// Rule order is load-bearing: more specific rules MUST precede general ones
/// (Reversal → Received → Deposit → Airtime → Paybill → BuyGoods → Withdrawal
///  → FulizaCharge → FulizaRepayment → SentP2P).
library;

import 'parser_types.dart';

class DetectionRule {
  const DetectionRule({
    required this.id,
    required this.category,
    required this.patterns,
    this.fallbackPatterns = const [],
    this.counterpartyPatterns = const [],
  });

  final String id;
  final TxCategory category;
  final List<RegExp> patterns;
  final List<RegExp> fallbackPatterns;
  final List<RegExp> counterpartyPatterns;
}

final List<DetectionRule> kDetectionRules = [
  // ── 1. Reversal ────────────────────────────────────────────────────────────
  DetectionRule(
    id: 'reversal',
    category: TxCategory.reversed,
    patterns: [
      RegExp(
        r'Reversal of transaction\s+[A-Za-z0-9]+\s+has been successfully reversed.*(?:Ksh|KES|KSH)\s?[\d,.]+\s+is\s+(?:debited|credited)',
        caseSensitive: false,
      ),
      RegExp(r'transaction\s+[A-Za-z0-9]{6,12}\s+(?:of|for)\s*(?:Ksh|KES|KSH)\s?[\d,.]+.*?has been reversed',
          caseSensitive: false),
      RegExp(r'(?:transaction of|transaction for)\s*(?:Ksh|KES|KSH)\s?[\d,.]+.*?has been reversed',
          caseSensitive: false),
      RegExp(r'(?:received|sent)\s+(?:Ksh|KES|KSH)\s?[\d,.]+.+has been reversed', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to.+has been reversed', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+received from.+has been reversed', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp('has been reversed', caseSensitive: false),
      RegExp(r'transaction.*reversed', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'received from\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'sent to\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
    ],
  ),

  // ── 2. Received (P2P credit) ───────────────────────────────────────────────
  DetectionRule(
    id: 'received',
    category: TxCategory.received,
    patterns: [
      RegExp(r'(?:you have\s+)?received\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+received from\s+', caseSensitive: false),
      RegExp(r'(?:you have\s+)?received\s+(?:Ksh|KES|KSH)\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+',
          caseSensitive: false),
      RegExp(r'umepokea\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+(?:kutoka|from)\s+', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(r'received from\s+[A-Z]', caseSensitive: false),
      RegExp(r'umepokea\s+(?:Ksh|KES|KSH)', caseSensitive: false),
      RegExp(r'umepokea\s+kutoka', caseSensitive: false),
      RegExp(r'umepokea', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'received\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)',
          caseSensitive: false),
      RegExp(r'received\s+(?:Ksh|KES|KSH)\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)',
          caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+received from\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)',
          caseSensitive: false),
      RegExp(r'umepokea\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+(?:kutoka|from)\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)',
          caseSensitive: false),
    ],
  ),

  // ── 3. Deposit ─────────────────────────────────────────────────────────────
  DetectionRule(
    id: 'deposit',
    category: TxCategory.deposit,
    patterns: [
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+deposited', caseSensitive: false),
      RegExp(r'cash deposit of\s+(?:Ksh|KES|KSH)\s?[\d,.]+', caseSensitive: false),
      RegExp(r'deposited\s+(?:Ksh|KES|KSH)\s?[\d,.]+', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+has been moved from your business account',
          caseSensitive: false),
      RegExp(r'Give\s+(?:Ksh|KES|KSH)\s?[\d,.]+', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(r'deposited\s+(?:Ksh|KES|KSH)', caseSensitive: false),
      RegExp(r'\bdeposited\b', caseSensitive: false),
      RegExp(r'Give\s+(?:Ksh|KES|KSH)', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'deposited by(?:\s+agent)?\s+\d+\s*-?\s*(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'deposited by(?:\s+agent)\s+([A-Za-z][^.]+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'Give\s+(?:Ksh|KES|KSH)\s?[\d,.]+(?:\s+\w+)?\s+to\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)',
          caseSensitive: false),
    ],
  ),

  // ── 4. Airtime — BEFORE paybill ("sent to ... for airtime") ────────────────
  DetectionRule(
    id: 'airtime',
    category: TxCategory.airtime,
    patterns: [
      RegExp(r'(?:you\s+)?bought\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+of airtime', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+\d{9,12}\s+for airtime', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+airtime\s+for\s+\d', caseSensitive: false),
      RegExp(r'for airtime(?:\s+on|\s+purchase|\s+of|\s*\.)', caseSensitive: false),
      RegExp(r'airtime\s+(?:purchase|of\s+(?:Ksh|KES|KSH))', caseSensitive: false),
      RegExp('of airtime purchased', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp('for airtime', caseSensitive: false),
      RegExp('airtime purchase', caseSensitive: false),
      RegExp(r'airtime\s+for\s+\d', caseSensitive: false),
      RegExp(r'bought\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+of airtime', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'sent to\s+(.+?)\s+for airtime', caseSensitive: false),
    ],
  ),

  // ── 5. Paybill (account/meter/ref/token/policy/bill/invoice/a-c) ───────────
  DetectionRule(
    id: 'paybill',
    category: TxCategory.paybill,
    patterns: [
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+.+?\s+(?:for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice)|(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice))\s+[\w-]+',
        caseSensitive: false,
      ),
      RegExp(
        r'paid to\s+.+?\s+(?:for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice)|(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice))\s+[\w-]+',
        caseSensitive: false,
      ),
      RegExp('paybill', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(
        r'(?:sent to|paid to)\s+.+?\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token)\s+[\w-]+',
        caseSensitive: false,
      ),
    ],
    counterpartyPatterns: [
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+(.+?)\s+(?:for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice)|(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice))\s+[\w-]+',
        caseSensitive: false,
      ),
      RegExp(
        r'paid to\s+(.+?)\s+(?:for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice)|(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice))\s+[\w-]+',
        caseSensitive: false,
      ),
      RegExp(
        r'sent to\s+(.+?)\s+(?:for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice)|(?:account|acc\.?|acct\.?|a\/c|meter|ref(?:erence)?|policy|token|bill|invoice))\s+[\w-]+',
        caseSensitive: false,
      ),
      RegExp(
        r'paybill(?:\s+payment)?\s+to\s+(.+?)(?:\s+for\s+(?:account|acc\.?|acct\.?|a\/c|meter|ref)|\s+on\s+\d|\.|$)',
        caseSensitive: false,
      ),
    ],
  ),

  // ── 6. Buy Goods ───────────────────────────────────────────────────────────
  DetectionRule(
    id: 'buy_goods',
    category: TxCategory.buyGoods,
    patterns: [
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+paid to\s+.+?\s+(?:on\s\d|\.\s|confirmed)', caseSensitive: false),
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+paid to\s+.+?\s+via\s+(?:kopo[\s-]+kopo|kopokopo)\b',
        caseSensitive: false,
      ),
      RegExp('buy goods', caseSensitive: false),
      RegExp(r'till number\s+\d+', caseSensitive: false),
      RegExp(r'paid to\s+[A-Z].+?\.\s+New M-PESA', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(r'paid to\s+[A-Z]', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'buy goods from\s+(.+?)(?:\s+on\s|\.|$)', caseSensitive: false),
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+paid to\s+(.+?)\s+via\s+(?:kopo[\s-]+kopo|kopokopo)(?:\.\s|\s+on\s|\s+New\s|$)',
        caseSensitive: false,
      ),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+paid to\s+(.+?)(?:\s+on\s\d|\.\s|confirmed|$)', caseSensitive: false),
      RegExp(r'paid to\s+(.+?)(?:\s+on\s\d|\.\s|confirmed|$)', caseSensitive: false),
    ],
  ),

  // ── 7. Withdrawal ──────────────────────────────────────────────────────────
  DetectionRule(
    id: 'withdrawal',
    category: TxCategory.withdraw,
    patterns: [
      RegExp('withdrawn from agent', caseSensitive: false),
      RegExp(r'cash withdrawal\s+of\s+(?:Ksh|KES|KSH)', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+withdrawn', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+withdrawn from ATM', caseSensitive: false),
      RegExp(r'Withdraw\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp('cash withdrawal', caseSensitive: false),
      RegExp('withdrawn from', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'withdrawn from(?:\s+agent)?\s+\d+\s*-?\s*(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'withdrawn from(?:\s+agent)\s+([A-Za-z][^.]+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'withdrawn from ATM at\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'withdrawn at\s+(.+?)(?:\s+on\s|\s+New\s|\.|$)', caseSensitive: false),
      RegExp(r'Withdraw\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+from\s+(.+?)(?:\s+New\s|\.|$)', caseSensitive: false),
    ],
  ),

  // ── 8. Fuliza charge notice — BEFORE repayment ────────────────────────────
  DetectionRule(
    id: 'fuliza_charge',
    category: TxCategory.fulizaCharge,
    patterns: [
      RegExp(r'Total Fuliza M-PESA outstanding amount is\s*(?:Ksh|KES|KSH)\s?[\d,]+', caseSensitive: false),
      RegExp(r'Fuliza M-PESA amount is\s*(?:Ksh|KES|KSH)\s?[\d,.]+.*Access Fee charged', caseSensitive: false),
      RegExp(r'Fuliza M-PESA amount is\s*(?:Ksh|KES|KSH)\s?[\d,.]+.*Interest charged', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(r'Total Fuliza.*outstanding amount', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp('(Fuliza M-PESA)', caseSensitive: false),
    ],
  ),

  // ── 9. Fuliza repayment — BEFORE sent_p2p ─────────────────────────────────
  DetectionRule(
    id: 'fuliza_repayment',
    category: TxCategory.loan,
    patterns: [
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+from your M-PESA has been used to (?:partially|fully)\s+pay your outstanding Fuliza M-PESA',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+from your M-PESA has been used to .*outstanding Fuliza M-PESA',
        caseSensitive: false,
      ),
    ],
    fallbackPatterns: [
      RegExp(r'from your M-PESA has been used to .*Fuliza', caseSensitive: false),
      RegExp('outstanding Fuliza M-PESA', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp('(Fuliza M-PESA)', caseSensitive: false),
    ],
  ),

  // ── 10. Sent P2P — LAST ───────────────────────────────────────────────────
  DetectionRule(
    id: 'sent_p2p',
    category: TxCategory.sent,
    patterns: [
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+[A-Z].+?(?:\s+on\s|\s+New\s|\.)', caseSensitive: false),
      RegExp(r'customer transfer of\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+to\s+', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+(?:\+?254|0)\d{8,9}\b', caseSensitive: false),
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+(?:0|\+?254[\s-]?)\d[\d\s-]{7,14}\b', caseSensitive: false),
      RegExp(r'you have sent\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+to\s+', caseSensitive: false),
    ],
    fallbackPatterns: [
      RegExp(r'sent to\s+[A-Z]', caseSensitive: false),
      RegExp(r'sent to\s+(?:\+?254|0)\d{8,9}\b', caseSensitive: false),
      RegExp(r'sent to\s+(?:0|\+?254[\s-]?)\d[\d\s-]{7,14}\b', caseSensitive: false),
      RegExp(r'you have sent\s+(?:Ksh|KES|KSH)', caseSensitive: false),
    ],
    counterpartyPatterns: [
      RegExp(r'(?:Ksh|KES|KSH)\s?[\d,.]+\s+sent to\s+(.+?)(?:\s+on\s|\s+New\s|\.|confirmed|$)',
          caseSensitive: false),
      RegExp(r'customer transfer of\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+to\s+(.+?)(?:\s+on\s|\s+New\s|\.|confirmed|$)',
          caseSensitive: false),
      RegExp(r'you have sent\s+(?:Ksh|KES|KSH)\s?[\d,.]+\s+to\s+(.+?)(?:\s+on\s|\s+New\s|\.|confirmed|$)',
          caseSensitive: false),
      RegExp(r'sent to\s+((?:\+?254|0)\d{8,9})\b', caseSensitive: false),
    ],
  ),
];

/// Fee/notice signals that mark a Fuliza *service* message.
const List<String> _fulizaNoticeSignals = [
  'access fee charged',
  'outstanding amount is',
  'daily charges',
  'query charges',
  'select query charges',
  'interest accrual',
  'interest charged',
  'interest accrued',
  'maintenance fee',
  'overdraft balance',
  'overdraft notice',
  'fuliza service charge',
  'overdue charge',
  'late payment fee',
  'rollover fee',
  'penalty fee',
  'processing fee charged',
  'm-pesa statement',
];

final RegExp _wsCollapse = RegExp(r'\s+');

bool isFulizaServiceNotice(String message) {
  final text = message.toLowerCase().replaceAll(_wsCollapse, ' ').trim();
  if (!text.contains('fuliza')) return false;
  if (text.contains('total fuliza m-pesa outstanding amount is')) return false;
  if (text.contains('from your m-pesa has been used to')) return false;
  return _fulizaNoticeSignals.any(text.contains);
}

/// OTA rule-bundle hot-swap parity hook (hardcoded rules by default).
List<DetectionRule> _activeBundle = kDetectionRules;

void loadRuleBundle(List<DetectionRule> rules) => _activeBundle = rules;
void clearRuleBundle() => _activeBundle = kDetectionRules;
List<DetectionRule> activeRules() => _activeBundle;
