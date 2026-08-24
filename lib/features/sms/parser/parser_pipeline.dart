/// 1:1 port of ParserPipeline.kt — unified SMS parser router.
///
/// M-Pesa → MpesaParserEnhanced (6-stage) · Airtel → AirtelMoneyParser ·
/// Banks → GenericBankParser. Applies CrossParserVoter, TransactionDecisionTree
/// and OnDeviceClassifier demotion on M-Pesa results.
library;

import 'airtel_money_parser.dart';
import 'cross_parser_voter.dart';
import 'generic_bank_parser.dart';
import 'institution_detector.dart';
import 'mpesa_parsing_config.dart';
import 'mpesa_parser_enhanced.dart';
import 'parser_types.dart';

enum ImportFilter { mpesaOnly, banksOnly, all }

sealed class SmsParseOutcome {
  const SmsParseOutcome();
}

class MpesaOutcomeSuccess extends SmsParseOutcome {
  const MpesaOutcomeSuccess(this.transaction);
  final MpesaParsedTransaction transaction;
}

class BankOutcomeSuccess extends SmsParseOutcome {
  const BankOutcomeSuccess(this.transaction);
  final ParsedBankTransaction transaction;
}

class RejectedOutcome extends SmsParseOutcome {
  const RejectedOutcome(this.reason, this.rawSms);
  final String reason;
  final String rawSms;
}

class FulizaBalanceUpdateOutcome extends SmsParseOutcome {
  const FulizaBalanceUpdateOutcome({
    required this.outstandingKes,
    required this.accessFeeKes,
    required this.amountUsedKes,
    required this.dueDate,
    required this.date,
  });

  final double outstandingKes;
  final double accessFeeKes;
  final double amountUsedKes;
  final int? dueDate;
  final int date;
}

SmsParseOutcome _finalizeMpesa(MpesaParseResult result, String body) {
  if (result is MpesaSuccess) {
    var tx = result.transaction;

    // Cross-parser voting: demote on disagreement with the fallback parser.
    final votedRoute = applyCrossParserVote(tx, body);
    if (votedRoute != tx.parseRoute) {
      tx = _withRoute(tx, votedRoute);
    }

    // Independent decision tree: LOW verdict vs HIGH parser → review.
    if (decisionTreeShouldDemote(body, tx.confidence) &&
        tx.parseRoute == ParseRoute.directLedger) {
      tx = _withRoute(tx, ParseRoute.reviewQueue);
    }

    // On-device personalised classifier (activates after 50 corrections).
    final mlCategory = OnDeviceClassifier.classifyTransaction(tx);
    if (mlCategory != null &&
        mlCategory != tx.category &&
        tx.parseRoute == ParseRoute.directLedger) {
      tx = _withRoute(tx, ParseRoute.reviewQueue);
    }

    return MpesaOutcomeSuccess(tx);
  }
  if (result is MpesaFulizaNotice) {
    return FulizaBalanceUpdateOutcome(
      outstandingKes: result.notice.outstandingKes,
      accessFeeKes: result.notice.accessFeeKes,
      amountUsedKes: result.notice.amountUsedKes,
      dueDate: result.notice.dueDate,
      date: result.notice.date,
    );
  }
  return RejectedOutcome((result as MpesaError).error.reason, body);
}

MpesaParsedTransaction _withRoute(MpesaParsedTransaction tx, ParseRoute route) {
  if (route == tx.parseRoute) return tx;
  return MpesaParsedTransaction(
    mpesaCode: tx.mpesaCode,
    amount: tx.amount,
    category: tx.category,
    confidence: tx.confidence,
    counterparty: tx.counterparty,
    description: tx.description,
    balanceAfter: tx.balanceAfter,
    fee: tx.fee,
    date: tx.date,
    rawSms: tx.rawSms,
    parseRoute: route,
    semanticHash: tx.semanticHash,
    matchedRulePhase: tx.matchedRulePhase,
    merchantCategory: tx.merchantCategory,
    fulizaOutstandingKes: tx.fulizaOutstandingKes,
    fulizaAvailableLimitKes: tx.fulizaAvailableLimitKes,
    isReceivedReversal: tx.isReceivedReversal,
  );
}

class ParserPipeline {
  /// Process a single SMS through the parser pipeline.
  static SmsParseOutcome process(
    String body,
    String sender,
    int receivedAtMs, [
    ImportFilter filter = ImportFilter.all,
  ]) {
    final detection = InstitutionDetector.detect(sender, body);

    if (detection != null) {
      switch (detection.institutionId) {
        case 'mpesa':
          if (filter == ImportFilter.banksOnly) {
            return RejectedOutcome('filtered_mpesa', body);
          }
          return _finalizeMpesa(mpesaParserParse(body, sender, receivedAtMs), body);

        case 'airtel':
          if (filter == ImportFilter.mpesaOnly) {
            return RejectedOutcome('filtered_bank', body);
          }
          if (isServiceNotice(body)) {
            return RejectedOutcome('service_notice', body);
          }
          final result = airtelMoneyParse(body, sender, receivedAtMs);
          return switch (result) {
            BankSuccess(:final transaction) => BankOutcomeSuccess(transaction),
            BankError(:final error) => RejectedOutcome(error.reason, body),
          };

        default:
          if (filter == ImportFilter.mpesaOnly) {
            return RejectedOutcome('filtered_bank', body);
          }
          if (isServiceNotice(body)) {
            return RejectedOutcome('service_notice', body);
          }
          if (bankCanParse(detection)) {
            final result = genericBankParse(body, sender, receivedAtMs, detection);
            return switch (result) {
              BankSuccess(:final transaction) => BankOutcomeSuccess(transaction),
              BankError(:final error) => RejectedOutcome(error.reason, body),
            };
          }
      }
    }

    // Body-keyword last resort for Airtel Money.
    if (filter != ImportFilter.mpesaOnly && airtelCanParse(body, sender)) {
      final result = airtelMoneyParse(body, sender, receivedAtMs);
      return switch (result) {
        BankSuccess(:final transaction) => BankOutcomeSuccess(transaction),
        BankError(:final error) => RejectedOutcome(error.reason, body),
      };
    }

    // M-Pesa body-keyword last resort.
    if (filter != ImportFilter.banksOnly && isMpesaSms(body)) {
      return _finalizeMpesa(mpesaParserParse(body, sender, receivedAtMs), body);
    }

    return RejectedOutcome('not_financial', body);
  }

  /// Cheap pre-filter for inbox scanning.
  static bool isFinancialSms(String sender, String body,
      [ImportFilter filter = ImportFilter.all]) {
    final detection = InstitutionDetector.detect(sender, body);
    if (detection != null) {
      return switch (filter) {
        ImportFilter.mpesaOnly => detection.institutionId == 'mpesa',
        ImportFilter.banksOnly => detection.institutionId != 'mpesa',
        ImportFilter.all => true,
      };
    }
    if (filter != ImportFilter.banksOnly && isMpesaSms(body)) return true;
    return false;
  }

  /// Institution counts for the import-picker UI.
  static Map<String, int> detectInstitutions(
      List<(String, String)> messages,
      [ImportFilter filter = ImportFilter.all]) {
    final counts = <String, int>{};
    for (final (sender, body) in messages) {
      final detection = InstitutionDetector.detect(sender, body);
      if (detection == null) continue;
      final include = switch (filter) {
        ImportFilter.mpesaOnly => detection.institutionId == 'mpesa',
        ImportFilter.banksOnly => detection.institutionId != 'mpesa',
        ImportFilter.all => true,
      };
      if (include) {
        counts[detection.institutionId] = (counts[detection.institutionId] ?? 0) + 1;
      }
    }
    return counts;
  }
}

/// On-device classifier hook. The full CART trainer lands with the Review
/// Queue feature; until then it returns null so parsing behavior matches a
/// fresh install of the Kotlin app (<50 samples → null).
class OnDeviceClassifier {
  static TxCategory? classifyTransaction(MpesaParsedTransaction tx) => null;
}
