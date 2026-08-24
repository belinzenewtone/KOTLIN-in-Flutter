/// 1:1 port of SmsConfidenceScorer.kt — 6-factor weighted scoring.
library;

import 'institution_detector.dart' show classifySenderTrust;
import 'parser_types.dart';

class ConfidenceBreakdown {
  const ConfidenceBreakdown({
    required this.codeScore,
    required this.amountScore,
    required this.dateScore,
    required this.merchantScore,
    required this.typeScore,
    required this.senderScore,
  });

  final double codeScore;
  final double amountScore;
  final double dateScore;
  final double merchantScore;
  final double typeScore;
  final double senderScore;

  double get total =>
      codeScore * 0.15 +
      amountScore * 0.20 +
      dateScore * 0.15 +
      merchantScore * 0.20 +
      typeScore * 0.15 +
      senderScore * 0.15;
}

final RegExp _strictCode = RegExp(r'^[A-Z0-9]{9,10}$');
final RegExp _looseCode = RegExp(r'^[A-Za-z0-9]{9,10}$');

class SmsConfidenceScorer {
  static ConfidenceBreakdown score({
    required String mpesaCode,
    required double amount,
    required int dateMs,
    required String? counterparty,
    required TxCategory category,
    required SenderTrustLevel senderTrust,
    required int nowMs,
  }) {
    return ConfidenceBreakdown(
      codeScore: _scoreCode(mpesaCode),
      amountScore: _scoreAmount(amount),
      dateScore: _scoreDate(dateMs, nowMs),
      merchantScore: _scoreMerchant(counterparty, category),
      typeScore: _scoreType(category),
      senderScore: _scoreSender(senderTrust),
    );
  }

  static PConfidence mapToConfidence(ConfidenceBreakdown b) {
    if (b.total >= 0.85) return PConfidence.high;
    if (b.total >= 0.60) return PConfidence.medium;
    return PConfidence.low;
  }

  static double _scoreCode(String code) {
    // Synthesised codeless path ("F" + 10 hash chars).
    if (code.startsWith('F') && code.length == 11) return 0.55;
    if (_strictCode.hasMatch(code)) return 1.0;
    if (_looseCode.hasMatch(code)) return 0.85;
    return 0.4;
  }

  static double _scoreAmount(double amount) {
    if (amount <= 0) return 0.0;
    if (amount > 10000000) return 0.3;
    if (amount < 1) return 0.6;
    return 1.0;
  }

  static double _scoreDate(int dateMs, int nowMs) {
    final daysDiff = (nowMs - dateMs) ~/ 86400000;
    if (daysDiff < 0) return 0.1;
    if (daysDiff > 365) return 0.4;
    if (daysDiff > 90) return 0.7;
    return 1.0;
  }

  static double _scoreMerchant(String? counterparty, TxCategory category) {
    final noMerchantOk = switch (category) {
      TxCategory.airtime ||
      TxCategory.withdraw ||
      TxCategory.deposit ||
      TxCategory.loan ||
      TxCategory.fulizaCharge => true,
      _ => false,
    };
    if (counterparty == null || counterparty.isEmpty) {
      return noMerchantOk ? 0.8 : 0.35;
    }
    if (counterparty.length > 70) return 0.5;
    return 1.0;
  }

  static double _scoreType(TxCategory category) =>
      category == TxCategory.unknown ? 0.2 : 1.0;

  static double _scoreSender(SenderTrustLevel trust) => switch (trust) {
        SenderTrustLevel.officialMpesa => 1.0,
        SenderTrustLevel.airtelMoney => 0.9,
        SenderTrustLevel.bank => 0.65,
        SenderTrustLevel.unknown => 0.5,
      };
}
