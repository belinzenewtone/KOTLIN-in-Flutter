import 'package:flutter_test/flutter_test.dart';

import 'package:lifeos/features/sms/parser/mpesa_parser_enhanced.dart';
import 'package:lifeos/features/sms/parser/parser_pipeline.dart';
import 'package:lifeos/features/sms/parser/parser_types.dart';

void main() {
  final now = DateTime.now().millisecondsSinceEpoch;

  MpesaParsedTransaction parseOf(String sms) =>
      (mpesaParserParse(sms, 'MPESA', now) as MpesaSuccess).transaction;

  group('MpesaParserEnhanced — Safaricom templates', () {
    test('P2P send extracts code/amount/counterparty/fee/balance', () {
      const sms =
          'SJD7YTH2MD Confirmed. Ksh390.00 sent to JANE DOE 0712345678 on '
          '3/7/25 at 5:32 PM New M-PESA balance is Ksh1,200.00. '
          'Transaction cost, Ksh3.00.';
      final tx = parseOf(sms);
      expect(tx.mpesaCode, 'SJD7YTH2MD');
      expect(tx.amount, 390.0);
      expect(tx.category, TxCategory.sent);
      expect(tx.counterparty, contains('JANE DOE'));
      expect(tx.fee, 3.0);
      expect(tx.balanceAfter, 1200.0);
      expect(tx.isExpense, isTrue);
      expect(tx.isIncome, isFalse);
    });

    test('received from person', () {
      const sms =
          'QGH56RT2LP Confirmed.You have received Ksh4,870.00 from ZIIDI '
          'on 21/6/25 at 9:14 AM New M-PESA balance is Ksh5,000.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.received);
      expect(tx.amount, 4870.0);
      expect(tx.counterparty, 'ZIIDI');
      expect(tx.isIncome, isTrue);
    });

    test('double-currency malformed received', () {
      const sms =
          'ABC12DEF34 Confirmed. received Ksh Ksh4,870.00 from ZIIDI on '
          '21/6/25 at 9:14 AM New M-PESA balance is Ksh5,000.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.received);
      expect(tx.counterparty, 'ZIIDI');
    });

    test('paybill with account number', () {
      const sms =
          'PKQ2XV98ZA Confirmed. Ksh1,500.00 sent to KENYA POWER for account '
          '11223344 on 12/4/25 at 8:03 AM New M-PESA balance is Ksh900.50.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.paybill);
      expect(tx.amount, 1500.0);
      expect(tx.counterparty, contains('KENYA POWER'));
    });

    test('buy goods till payment', () {
      const sms =
          'CCT4E90QZ5 Confirmed. Ksh450.00 paid to NAIVAS WESTLANDS on '
          '3/7/25 at 10:11 AM. New M-PESA balance is Ksh2,300.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.buyGoods);
      expect(tx.counterparty, contains('NAIVAS'));
    });

    test('kopo kopo merchant variant', () {
      const sms =
          'BFR22GT45D Confirmed.Ksh500.00 paid to JAVA HOUSE via kopo kopo '
          'on 5/7/25 at 1:15 PM.New M-PESA balance is Ksh1,800.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.buyGoods);
      expect(tx.counterparty, contains('JAVA HOUSE'));
    });

    test('agent withdrawal strips numeric agent code', () {
      const sms =
          'SD89JK3M2Q Confirmed. Ksh2,000.00 withdrawn from agent 174530 '
          'JAMES AGENT on 3/7/25 at 4:20 PM. Agent fee is Ksh29.00. '
          'New M-PESA balance is Ksh8,971.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.withdraw);
      expect(tx.counterparty, 'JAMES AGENT');
    });

    test('direct airtime purchase', () {
      const sms =
          'AS234BCD91 Confirmed. You bought Ksh50.00 of airtime on '
          '3/7/25 at 6:40 AM New M-PESA balance is Ksh1,150.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.airtime);
      expect(tx.amount, 50.0);
    });

    test('airtime sent to phone number', () {
      const sms =
          'WE56RT78YU Confirmed. Ksh30.00 sent to 0712345678 for airtime on '
          '3/7/25 at 7:02 AM New M-PESA balance is Ksh1,120.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.airtime);
    });

    test('cash deposit by agent', () {
      const sms =
          'CD12FG45HJ Confirmed. Cash deposit of Ksh5,000.00 deposited by '
          'agent 174530 JOHN AGENT on 3/7/25 at 9:05 AM New M-PESA balance '
          'is Ksh6,000.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.deposit);
      expect(tx.counterparty, 'JOHN AGENT');
    });

    test('fuliza repayment maps to LOAN with available limit', () {
      const sms =
          'FG78HJ12KL Confirmed. Ksh105.00 from your M-PESA has been used to '
          'fully pay your outstanding Fuliza M-PESA. Your available Fuliza '
          'M-PESA limit is Ksh1,500.00 on 3/7/25 at 8:00 AM. New M-PESA '
          'balance is Ksh2,000.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.loan);
      expect(tx.fulizaAvailableLimitKes, 1500.0);
    });

    test('fuliza charge notice parses as FULIZA_CHARGE transaction', () {
      // Parity note: isFulizaServiceNotice() deliberately excludes messages
      // carrying "Total Fuliza M-PESA outstanding amount is" so they flow into
      // the fuliza_charge detection rule (identical to Kotlin).
      const sms =
          'CV67BN34MK Confirmed. Fuliza M-PESA amount is Ksh30.00. '
          'Access Fee charged Ksh0.30. Total Fuliza M-PESA outstanding amount '
          'is Ksh508.16 due on 5/7/25. New M-PESA balance is Ksh970.00.';
      final r = mpesaParserParse(sms, 'MPESA', now);
      expect(r, isA<MpesaSuccess>());
      final tx = (r as MpesaSuccess).transaction;
      expect(tx.category, TxCategory.fulizaCharge);
      expect(tx.fulizaOutstandingKes, 508.16);
    });

    test('fuliza service notice without outstanding total is dropped', () {
      const sms =
          'Fuliza M-PESA: your access fee charged today is Ksh3.00 '
          'for daily charges on your overdraft balance.';
      final r = mpesaParserParse(sms, 'MPESA', now);
      expect(r, isA<MpesaError>());
      expect((r as MpesaError).error.reason, 'fuliza_service_notice');
    });

    test('reversal of received money flips direction (Gap 6)', () {
      const sms =
          'RE99XX21AA Confirmed. Ksh500.00 received from JOHN DOE on '
          '3/7/25 at 2:00 PM has been reversed. New M-PESA balance is '
          'Ksh1,000.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.reversed);
      expect(tx.isReceivedReversal, isTrue);
      expect(tx.isExpense, isTrue);
      expect(tx.isIncome, isFalse);
    });

    test('swahili received via umepokea/kutoka', () {
      const sms =
          'SW11KE99ZZ Confirmed. Umepokea Ksh390.00 kutoka JOHN DOE on '
          '3/7/25 at 5:32 PM Salio jipya la M-PESA ni Ksh1,200.00.';
      final tx = parseOf(sms);
      expect(tx.category, TxCategory.received);
      expect(tx.counterparty, contains('JOHN DOE'));
    });

    test('failed transaction rejected with reason', () {
      final r = mpesaParserParse(
          'FAILED. You have entered the wrong PIN. Go to M-PESA menu and try again.', 'MPESA', now);
      expect(r, isA<MpesaError>());
      expect((r as MpesaError).error.reason, 'failed_transaction');
    });

    test('non-financial SMS rejected', () {
      final r = mpesaParserParse(
          'Enjoy 10% off all pizzas today! Dial *369# to order.',
          'PROMO',
          now);
      expect(r, isA<MpesaError>());
      expect((r as MpesaError).error.reason, 'not_mpesa');
    });
  });
}
