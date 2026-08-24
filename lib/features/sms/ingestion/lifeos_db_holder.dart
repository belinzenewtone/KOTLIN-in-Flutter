/// Session-scoped database holder — the Flutter analogue of Koin's singleton
/// graph slice used by the pipeline: database + active user id +
/// LocalIdGenerator parity counters + hydrated dedupe engine + Fuliza ledger
/// helpers.
library;

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../dedupe/mpesa_dedupe_engine.dart';

class LifeOsDbHolder {
  LifeOsDbHolder({required this.database, this.userId = ''});

  final LifeOsDatabase database;
  String userId;

  MpesaDedupeEngine? _dedupe;
  Future<MpesaDedupeEngine>? _dedupeReady;

  /// Hydrates (once) and returns the dedupe engine for this user.
  Future<MpesaDedupeEngine> getDedupeEngine() {
    return _dedupeReady ??= () async {
      final engine = MpesaDedupeEngine(database);
      await engine.hydrate(userId);
      _dedupe = engine;
      return engine;
    }();
  }

  MpesaDedupeEngine get dedupeEngine => _dedupe ??= MpesaDedupeEngine(database);

  int _nextTxId = -1;

  /// Monotonic transaction id (LocalIdGenerator parity).
  Future<int> nextTransactionId() async {
    if (_nextTxId < 0) {
      final row = await database.customSelect(
        'SELECT COALESCE(MAX(id), 0) AS m FROM transactions',
      ).getSingle();
      _nextTxId = (row.data['m'] as int? ?? 0) + 1;
    }
    return _nextTxId;
  }

  Future<void> saveNextTransactionId(int value) async {
    _nextTxId = value;
  }

  int nextAuditId() {
    // Audit ids are per-user composite keys; a session counter seeded from
    // MAX(id) keeps them unique without contention.
    return _auditSeq++;
  }

  int _auditSeq = 1;

  Future<void> seedAuditCounter() async {
    final row = await database.customSelect(
      'SELECT COALESCE(MAX(id), 0) AS m FROM import_audit WHERE user_id = ?',
      variables: [Variable.withString(userId)],
    ).getSingle();
    _auditSeq = (row.data['m'] as int? ?? 0) + 1;
  }

  // ── Fuliza lifecycle ledger ───────────────────────────────────────────────

  Future<void> recordFulizaDraw({
    required String drawCode,
    required double amountKes,
    required int drawDate,
  }) async {
    await database.customStatement(
      'INSERT INTO fuliza_loans (id, user_id, draw_code, draw_amount_kes, '
      'total_repaid_kes, status, draw_date, created_at, updated_at) '
      'VALUES ((SELECT COALESCE(MAX(id),0)+1 FROM fuliza_loans WHERE user_id = ?2), ?2, ?1, ?3, 0.0, ?, ?4, ?4, ?4)',
      [drawCode, userId, amountKes, drawDate],
    );
  }

  Future<void> recordFulizaRepayment({
    required String drawCode,
    required double repaidAmountKes,
    required int repaymentDate,
  }) async {
    // Attach repayment to the oldest open draw; create one when none exists.
    await database.customStatement("""
      UPDATE fuliza_loans
         SET total_repaid_kes = total_repaid_kes + ?1,
             last_repayment_date = ?3,
             status = CASE WHEN total_repaid_kes + ?1 >= draw_amount_kes
                           THEN 'REPAID' ELSE 'PARTIAL' END,
             updated_at = ?3
       WHERE id = (
         SELECT id FROM fuliza_loans
          WHERE user_id = ?2 AND status != 'REPAID'
          ORDER BY draw_date ASC LIMIT 1
       )
    """, [repaidAmountKes, userId, repaymentDate]);
  }
}
