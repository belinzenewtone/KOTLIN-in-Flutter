import 'package:flutter_test/flutter_test.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart' show NativeDatabase;

import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/features/sms/dedupe/mpesa_dedupe_engine.dart';
import 'package:lifeos/features/sms/ingestion/ingestion_pipeline.dart';
import 'package:lifeos/features/sms/ingestion/ingestion_types.dart';
import 'package:lifeos/features/sms/ingestion/lifeos_db_holder.dart';

/// Deterministic synthetic corpus mirroring real Kenyan SMS traffic:
/// M-Pesa sends/receives/paybills/tills/withdrawals/airtime/deposits,
/// Fuliza notices + repayments, bank credits/debits, and pure noise —
/// plus a configurable duplicate rate to exercise the dedupe tiers.
List<RawSms> generateCorpus(int count, {double duplicateRate = 0.08}) {
  final uniqueCount = (count * (1 - duplicateRate)).round();
  final uniques = <RawSms>[];

  const merchants = [
    'NAIVAS WESTLANDS', 'QUICKMART KILIMANI', 'CARREFOUR TWO RIVERS',
    'JAVAM HOUSE YAYA', 'KFC THE HUB', 'SHELL WESTLANDS', 'UBER *TRIP',
    'BOLT KENYA', 'EQUIPMENT AND ASSETS', 'ARTCAFFE VILLAGE MARKET',
  ];
  const billers = [
    ('KENYA POWER', '11223344-01'),
    ('NAIROBI WATER', '55667788'),
    ('DSTV KENYA', '4499112'),
    ('FAIBA INTERNET', '778812'),
    ('ZUKU FIBRE', '3011204'),
  ];
  const people = [
    'JANE WANJIKU 0712345678', 'JOHN OTIENO 0723456789', 'MARY NJERI 0734567890',
    'PETER KAMAU 0745678901', 'GRACE ACHIENG 0756789012',
  ];
  const agents = ['174530 JAMES AGENT', '220144 GRACE AGENT', '330987 PETER AGENT'];
  final codes = <String>{};
  var codeSeq = 100000;

  String nextCode() {
    String c;
    do {
      c = 'S${(codeSeq++).toRadixString(36).toUpperCase().padLeft(9, '0')}X';
    } while (codes.contains(c));
    codes.add(c);
    return c;
  }

  var ts = DateTime(2023, 1, 1, 8).millisecondsSinceEpoch;
  const hour = 3600000;

  for (var i = 0; i < uniqueCount; i++) {
    ts += (hour ~/ 24) + (i % 17) * 60000; // ~1 msg/hour-ish spacing
    final dateStr =
        '${(i % 28) + 1}/${(i % 12) + 1}/25 at ${(i % 12) + 1}:${(i % 60).toString().padLeft(2, '0')} ${i.isEven ? 'AM' : 'PM'}';
    final code = nextCode();
    final amount = ((i * 37) % 25000) + 10;
    final balance = ((i * 91) % 90000) + 500;
    final merchant = merchants[i % merchants.length];
    final person = people[i % people.length];
    final agent = agents[i % agents.length];

    switch (i % 20) {
      case 0: // P2P send
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh$amount.00 sent to $person on '
              '$dateStr New M-PESA balance is Ksh$balance.00. '
              'Transaction cost, Ksh${(i % 30) + 1}.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 1: // receive
        uniques.add(RawSms(
          body: '$code Confirmed.You have received Ksh$amount.00 from '
              '$person on $dateStr New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 2: // paybill
        final b = billers[i % billers.length];
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh$amount.00 sent to ${b.$1} for account '
              '${b.$2} on $dateStr New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 3: // buy goods till
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh$amount.00 paid to $merchant on '
              '$dateStr New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 4: // agent withdrawal
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh$amount.00 withdrawn from agent '
              '$agent on $dateStr. Agent fee is Ksh29.00. New M-PESA '
              'balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 5: // airtime
        uniques.add(RawSms(
          body: '$code Confirmed. You bought Ksh${(i % 100) + 5}.00 of airtime on $dateStr '
              'New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 6: // deposit
        uniques.add(RawSms(
          body: '$code Confirmed. Cash deposit of Ksh$amount.00 deposited by '
              'agent $agent on $dateStr New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 7: // fuliza repayment
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh${(i % 400) + 35}.00 from your M-PESA has been used to '
              'fully pay your outstanding Fuliza M-PESA. Your available Fuliza '
              'M-PESA limit is Ksh$balance.00 on $dateStr. New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 8: // fuliza charge notice
        uniques.add(RawSms(
          body: '$code Confirmed. Fuliza M-PESA amount is Ksh30.00. '
              'Access Fee charged Ksh0.30. Total Fuliza M-PESA outstanding amount '
              'is Ksh${(i % 900) + 50}.16 due on $dateStr. New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 9: // reversal
        uniques.add(RawSms(
          body: '$code Confirmed. Ksh$amount.00 received from $person on '
              '$dateStr has been reversed. New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 10: // kopo kopo
        uniques.add(RawSms(
          body: '$code Confirmed.Ksh$amount.00 paid to $merchant via kopo kopo '
              'on $dateStr.New M-PESA balance is Ksh$balance.00.',
          sender: 'MPESA',
          receivedAtMs: ts,
        ));
        break;
      case 11: // bank credit (Equity style)
        uniques.add(RawSms(
          body: 'Your account 100****882 has been credited with KES $amount.00 '
              'on $dateStr. Ref CONF$i Balance: KES $balance.00. '
              'From EQUITY BANK.',
          sender: 'EQUITYBK',
          receivedAtMs: ts,
        ));
        break;
      case 12: // bank debit (KCB style)
        uniques.add(RawSms(
          body: 'KCB Account 123456 debited KES $amount.00 on $dateStr. '
              'Ref TXN$i. Balance KES $balance.00. To $merchant.',
          sender: 'KCBBANK',
          receivedAtMs: ts,
        ));
        break;
      case 13: // NCBA Loop transfer with cross-ref
        uniques.add(RawSms(
          body: 'Loop by NCBA: Transfer of KES $amount.00 to $merchant completed '
              'on $dateStr. Ref LOP$i. Balance KES $balance.00. M-PESA ref $code.',
          sender: 'NCBALOOP',
          receivedAtMs: ts,
        ));
        break;
      case 14: // Airtel Money
        uniques.add(RawSms(
          body: 'Airtel Money: You have received KES $amount.00 from $person. '
              'Transaction ID AIR${i}00 Ref. New balance is KES $balance.00.',
          sender: 'AIRTELMONEY',
          receivedAtMs: ts,
        ));
        break;
      default: // noise / promos / OTPs
        switch (i % 5) {
          case 0:
            uniques.add(RawSms(
                body: 'Win BIG! Dial *544# and get 10% bonus data. T&Cs apply.',
                sender: 'SAFARICOM',
                receivedAtMs: ts));
            break;
          case 1:
            uniques.add(RawSms(
                body: 'Your one-time password is $i$i$i$i$i$i. Never share this code.',
                sender: 'SCBKEn',
                receivedAtMs: ts));
            break;
          case 2:
            uniques.add(RawSms(
                body: 'Dear customer, scheduled system maintenance tonight 1AM-3AM.',
                sender: 'COOPBNK',
                receivedAtMs: ts));
            break;
          case 3:
            uniques.add(RawSms(
                body: 'FAILED. You have entered the wrong PIN. Visit M-PESA menu.',
                sender: 'MPESA',
                receivedAtMs: ts));
            break;
          case 4:
            uniques.add(RawSms(
                body: 'Hey Looper! A better, smarter Loop app is here. Update now.',
                sender: 'NCBALOOP',
                receivedAtMs: ts));
            break;
        }
    }
  }

  // Duplicate injection: repeat random earlier messages verbatim.
  if (duplicateRate <= 0 || uniques.isEmpty) return uniques;
  final out = <RawSms>[...uniques];
  var dupIndex = 0;
  while (out.length < count) {
    out.add(uniques[dupIndex++ % uniques.length]);
  }
  return out.sublist(0, count);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('100k SMS stress import — throughput + accuracy', () async {
    final driftIsolate = await DriftIsolate.spawn(() {
      return NativeDatabase.memory();
    });
    final database = LifeOsDatabase(await driftIsolate.connect());

    final holder = LifeOsDbHolder(database: database, userId: 'bench-user');
    await holder.seedAuditCounter();

    const total = 100000;
    final corpus = generateCorpus(total, duplicateRate: 0.08);

    final pipeline = DefaultMpesaIngestionPipeline(holder: holder);
    final sw = Stopwatch()..start();

    var lastProgress = 0;
    final result = await pipeline.ingestBatch(
      Stream<RawSms>.fromIterable(corpus),
      onProgress: (p) {
        if (p.processed - lastProgress >= 20000) {
          lastProgress = p.processed;
          // ignore: avoid_print
          print('progress ${p.processed}/${corpus.length} — imported=${p.imported}');
        }
      },
    );
    sw.stop();

    final txCount = await database.customSelect(
      'SELECT COUNT(*) AS c FROM transactions',
    ).getSingle();
    final auditCount = await database.customSelect(
      "SELECT COUNT(*) AS c FROM import_audit WHERE outcome IN ('imported','recovered_from_backfill')",
    ).getSingle();
    final dupAudit = await database.customSelect(
      "SELECT COUNT(*) AS c FROM import_audit WHERE outcome = 'duplicate'",
    ).getSingle();

    final seconds = sw.elapsedMilliseconds / 1000.0;
    // ignore: avoid_print
    print('──────────────────────────────────────────────────');
    // ignore: avoid_print
    print('Corpus           : ${corpus.length} messages');
    // ignore: avoid_print
    print('Imported         : ${result.imported}');
    // ignore: avoid_print
    print('Duplicates       : ${result.duplicates}');
    // ignore: avoid_print
    print('Parse failed     : ${result.parseFailed}');
    // ignore: avoid_print
    print('Ignored          : ${result.ignored}');
    // ignore: avoid_print
    print('DB transactions  : ${txCount.data['c']}');
    // ignore: avoid_print
    print('Audit imported   : ${auditCount.data['c']}');
    // ignore: avoid_print
    print('Audit duplicates : ${dupAudit.data['c']}');
    // ignore: avoid_print
    print('Elapsed          : ${seconds.toStringAsFixed(2)}s '
        '(${(corpus.length / seconds).round()} msgs/s)');
    // ignore: avoid_print
    print('──────────────────────────────────────────────────');

    // ── Accuracy assertions ──────────────────────────────────────────────
    expect(result.processed, corpus.length);
    // Unique transactional templates ≈ 15/20 of corpus minus dupes/noise.
    expect(result.duplicates, greaterThan(0), reason: 'dupes must be caught');
    expect(result.ignored, greaterThan(0), reason: 'noise must be ignored');

    // Ledger rows must equal imported count exactly.
    expect(txCount.data['c'], result.imported);

    // Re-running the SAME corpus must produce zero new imports (full dedupe).
    final rerunStart = Stopwatch()..start();
    final rerun = await pipeline.ingestBatch(Stream<RawSms>.fromIterable(corpus));
    rerunStart.stop();
    // ignore: avoid_print
    print(
        'Re-import of same corpus: ${rerun.imported} new (took ${(rerunStart.elapsedMilliseconds / 1000).toStringAsFixed(2)}s)');
    expect(rerun.imported, 0, reason: 'every message must dedupe on second pass');

    await pipeline.dispose();
    await database.close();
  }, timeout: const Timeout(Duration(minutes: 20)));
}
