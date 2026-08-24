/// High-throughput ingestion pipeline — port of
/// DefaultMpesaIngestionPipeline.kt re-engineered for 100k+ SMS imports.
///
/// Throughput architecture
/// ────────────────────────
///   ``Stream<RawSms>``
///     → chunked (200/chunk, heap-flat)
///     → parsed IN PARALLEL across worker isolates (CPU-bound regex work)
///     → written SERIALLY: one SQLite transaction per chunk containing
///       • four-tier dedupe checks against hydrated O(1) indexes
///       • batched INSERTs (transactions + audit rows)
///       • paybill-registry / fuliza-lifecycle side effects
///     → progress events emitted per chunk
///
/// This matches Kotlin's shape (parallel Dispatchers.Default parses +
/// WAL-serialized writes, Semaphore-capped in-flight chunks) while removing
/// per-message round-trips: dedupe never touches SQL during bulk import.
library;

export 'lifeos_db_holder.dart' show LifeOsDbHolder;

import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../../core/database/database.dart' as db;
import '../dedupe/mpesa_dedupe_engine.dart';
import '../parser/cross_parser_voter.dart';
import '../parser/parser_types.dart';
import 'ingestion_types.dart';
import 'lifeos_db_holder.dart';
import 'parser_isolate_pool.dart';

class DefaultMpesaIngestionPipeline {
  DefaultMpesaIngestionPipeline({required this.holder, this.budgetSyncHook});

  /// Database + session state (user id, id generator).
  final LifeOsDbHolder holder;

  /// Optional post-import hook (SyncCategoryBudgetsFromTransactionsUseCase).
  /// Called ONCE after a batch completes — final state is identical to the
  /// per-message calls in Kotlin without 100k redundant recomputations.
  final Future<void> Function()? budgetSyncHook;

  static const int chunkSize = 200;

  ParserIsolatePool? _pool;

  // ═══════════════════════════════ realtime ═════════════════════════════════

  Future<MpesaIngestionOutcome> ingestRealtime(
    String rawMessage,
    MpesaIngestionSource source,
    String? sender,
    int smsTimestampMs,
  ) async {
    _pool ??= await ParserIsolatePool.spawn();
    final outcomes =
        await _pool!.parseChunk([(rawMessage, sender ?? 'MPESA', smsTimestampMs)]);
    // Realtime path skips dedupe hydration (single live message; the DB
    // indexes catch duplicates on insert via unique checks upstream).
    final counts =
        await _applyOutcomes([outcomes.first], source, holder.dedupeEngine);
    if (counts.duplicates > 0) return MpesaIngestionOutcome.duplicate;
    if (counts.imported > 0) return MpesaIngestionOutcome.imported;
    if (counts.ignored > 0) return MpesaIngestionOutcome.ignoredIrrelevant;
    return MpesaIngestionOutcome.parseFailed;
  }

  // ═══════════════════════════════ batch ════════════════════════════════════

  /// Ingests a potentially unbounded stream of SMS. Progress is reported as
  /// [ImportProgress] snapshots (per chunk). Never throws mid-batch — failures
  /// are recorded per-message and surfaced through the result counters.
  Future<BatchIngestionResult> ingestBatch(
    Stream<RawSms> messages, {
    void Function(ImportProgress progress)? onProgress,
  }) async {
    _pool ??= await ParserIsolatePool.spawn();
    final dedupe = await holder.getDedupeEngine();

    var imported = 0, duplicates = 0, parseFailed = 0, ignored = 0;
    var processed = 0;

    // Bounded in-flight parse jobs (Kotlin WRITE_CONCURRENCY parity): chunks
    // are dispatched ahead of time but drained FIFO, so memory stays flat and
    // DB writes remain serialized.
    final pending = <Future<List<ParsedOutcome>>>[];
    final maxInFlight = _pool!.workerCount;
    final buffer = <RawSms>[];

    Future<void> drain(List<ParsedOutcome> outcomes) async {
      final counts =
          await _applyOutcomes(outcomes, MpesaIngestionSource.backfill, dedupe);
      imported += counts.imported;
      duplicates += counts.duplicates;
      parseFailed += counts.parseFailed;
      ignored += counts.ignored;
      processed += outcomes.length;
      onProgress?.call(ImportProgress(
        processed: processed,
        total: null,
        imported: imported,
        duplicates: duplicates,
        parseFailed: parseFailed,
        ignored: ignored,
      ));
    }

    void dispatch(List<(String, String, int)> items) {
      pending.add(_pool!.parseChunk(items).catchError((Object e) {
        // Worker failure must never lose the import: mark chunk rejected.
        return [
          for (final it in items)
            ParsedOutcome(
              kind: 'rejected',
              reason: 'worker_error: $e',
              body: it.$1,
              sender: it.$2,
              receivedAtMs: it.$3,
            ),
        ];
      }));
    }

    await for (final sms in messages) {
      buffer.add(sms);
      if (buffer.length >= chunkSize) {
        final items = [
          for (final s in buffer) (s.body, s.sender, s.receivedAtMs),
        ];
        buffer.clear();
        dispatch(items);

        while (pending.length >= maxInFlight) {
          await drain(await pending.removeAt(0));
        }
      }
    }
    // Drain remaining in-flight jobs, then any partial chunk.
    while (pending.isNotEmpty) {
      await drain(await pending.removeAt(0));
    }
    if (buffer.isNotEmpty) {
      final items = [
        for (final s in buffer) (s.body, s.sender, s.receivedAtMs),
      ];
      await drain(await _pool!.parseChunk(items));
    }

    // Post-import hooks — same end-state as Kotlin's per-message sync call.
    if (imported > 0) {
      try {
        await budgetSyncHook?.call();
      } catch (_) {/* runCatching parity */}
    }

    return BatchIngestionResult(
      imported: imported,
      duplicates: duplicates,
      parseFailed: parseFailed,
      ignored: ignored,
    );
  }

  Future<void> dispose() async {
    await _pool?.dispose();
    _pool = null;
  }

  // ══════════════════════════ outcome application ═══════════════════════════

  Future<ChunkCounts> _applyOutcomes(
    List<ParsedOutcome> outcomes,
    MpesaIngestionSource source,
    MpesaDedupeEngine? dedupe,
  ) async {
    final database = holder.database;
    final userId = holder.userId;
    final now = DateTime.now().millisecondsSinceEpoch;

    final counts = ChunkCounts();

    // Rows accumulated for this chunk's single transaction.
    final txRows = <db.TransactionsCompanion>[];
    final auditRows = <db.ImportAuditCompanion>[];
    final paybillUpserts = <String, ({double amount, int seenAt})>{};
    final fulizaEvents = <db.FulizaEventsCompanion>[];

    int nextId = await holder.nextTransactionId();

    for (final o in outcomes) {
      switch (o.kind) {
        case 'mpesa':
          final route = ParseRoute.values[o.parseRouteIndex ?? 0];
          final category = TxCategory.fromWire(o.categoryWire ?? 'UNKNOWN');
          final amount = o.amount ?? 0;
          final merchant = o.counterparty ?? 'M-Pesa';
          final code = o.mpesaCode ?? '';
          final dateMs = o.dateMs ?? o.receivedAtMs;

          // Route enforcement: quarantine never auto-inserts.
          if (route == ParseRoute.quarantine) {
            counts.imported++; // counted as candidate pending (parity below)
            auditRows.add(_audit(userId, o.body,
                outcome: 'candidate_pending',
                mpesaCode: code,
                amount: amount,
                merchant: merchant,
                failureReason: 'quarantine_route',
                confidence: (o.confidenceOrdinal ?? 2).toDouble(),
                now: now));
            continue;
          }

          final isDup = dedupe != null &&
              await dedupe.isDuplicate(
                mpesaCode: code,
                rawMessage: o.body,
                amount: amount,
                merchant: merchant,
                timestamp: dateMs,
                inlineSemanticHash: o.semanticHash,
              );
          if (isDup) {
            duplicatesCount(counts);
            auditRows.add(_audit(userId, o.body,
                outcome: 'duplicate',
                mpesaCode: code,
                amount: amount,
                merchant: merchant,
                confidence: (o.confidenceOrdinal ?? 2).toDouble(),
                now: now));
            continue;
          }

          final transactionType = switch (category) {
            TxCategory.received || TxCategory.deposit => 'RECEIVED',
            TxCategory.withdraw => 'WITHDRAW',
            TxCategory.paybill => 'PAYBILL',
            TxCategory.buyGoods => 'BUY_GOODS',
            TxCategory.sent => 'SENT',
            _ => category.wireName,
          };

          final sourceHash = sha256.convert(utf8.encode(o.body)).toString();

          txRows.add(db.TransactionsCompanion.insert(
            id: nextId++,
            userId: userId,
            amount: amount,
            merchant: merchant,
            category: category.displayLabel,
            date: dateMs,
            source: 'MPESA',
            transactionType: transactionType,
            mpesaCode: Value(code.isEmpty ? null : code),
            sourceHash: Value(sourceHash),
            rawSms: Value(o.body),
            createdAt: now,
            updatedAt: now,
            syncState: 'LOCAL',
            recordSource: 'SMS_IMPORT',
            revision: 0,
            fee: Value(o.fee ?? 0.0),
            balanceAfter: Value(o.balanceAfter),
            confidence: Value((o.confidenceOrdinal ?? 2).toDouble()),
            parseRoute: Value(route.name.toUpperCase()),
            description: Value(o.description),
            semanticHash: Value(o.semanticHash),
            institutionId: const Value('mpesa'),
            externalRef: Value(code.isEmpty ? null : code),
            status: route == ParseRoute.reviewQueue
                ? const Value('pending_review')
                : const Value('completed'),
          ));

          dedupe?.recordInserted(
            mpesaCode: code,
            sourceHash: sourceHash,
            semanticHash: o.semanticHash ?? '',
            amount: amount,
            merchant: merchant,
            timestamp: dateMs,
          );

          auditRows.add(_audit(userId, o.body,
              outcome:
                  source == MpesaIngestionSource.backfill ? 'recovered_from_backfill' : 'imported',
              mpesaCode: code,
              amount: amount,
              merchant: merchant,
              confidence: (o.confidenceOrdinal ?? 2).toDouble(),
              now: now));

          if (category == TxCategory.paybill && merchant.isNotEmpty) {
            paybillUpserts[merchant] = (amount: amount, seenAt: now);
          }

          // Fuliza lifecycle (parity with trackFulizaLifecycle).
          if (amount > 0) {
            final hasFulizaContext = o.body.toLowerCase().contains('fuliza');
            if (category == TxCategory.loan) {
              fulizaEvents.add(db.FulizaEventsCompanion.insert(
                userId: userId,
                eventType: 'REPAYMENT',
                mpesaCode: code,
                amountKes: amount,
                outstandingAfter: const Value(0.0),
                eventAt: dateMs,
                createdAt: now,
              ));
              holder.recordFulizaRepayment(drawCode: code, repaidAmountKes: amount, repaymentDate: dateMs);
            } else if (hasFulizaContext && kFulizaDrawCategories.contains(category)) {
              fulizaEvents.add(db.FulizaEventsCompanion.insert(
                userId: userId,
                eventType: 'DRAW',
                mpesaCode: code,
                amountKes: amount,
                eventAt: dateMs,
                createdAt: now,
              ));
              holder.recordFulizaDraw(drawCode: code, amountKes: amount, drawDate: dateMs);
            }
          }
          importedCount(counts);
          break;

        case 'bank':
          final route = ParseRoute.values[o.parseRouteIndex ?? 0];
          final category = TxCategory.fromWire(o.categoryWire ?? 'UNKNOWN');
          final amount = o.amount ?? 0;
          final merchant = o.counterparty ?? (o.institutionId ?? 'bank').toUpperCase();
          final instId = o.institutionId ?? 'bank';
          final externalRef = o.externalRef ?? '';
          final sourceHashBank = o.sourceHash ?? '';
          final semHash = o.semanticHash ?? '';

          bool dup = false;
          if (dedupe != null) {
            if (sourceHashBank.isNotEmpty && dedupe.hasSourceHash(sourceHashBank)) dup = true;
            if (!dup && semHash.isNotEmpty && dedupe.hasSemanticHash(semHash)) dup = true;
            if (!dup && o.crossRefMpesaCode != null && o.crossRefMpesaCode!.isNotEmpty) {
              dup = dedupe.hasMpesaCode(o.crossRefMpesaCode!);
            }
          }
          if (dup || route == ParseRoute.quarantine) {
            if (dup) {
              duplicatesCount(counts);
              auditRows.add(_audit(userId, o.body,
                  outcome: 'duplicate',
                  mpesaCode: externalRef,
                  amount: amount,
                  merchant: merchant,
                  failureReason:
                      o.crossRefMpesaCode != null ? 'Cross-ref M-Pesa duplicate' : null,
                  confidence: (o.confidenceOrdinal ?? 2).toDouble(),
                  now: now));
            } else {
              counts.imported++;
              auditRows.add(_audit(userId, o.body,
                  outcome: 'candidate_pending',
                  mpesaCode: externalRef,
                  amount: amount,
                  merchant: merchant,
                  failureReason: 'quarantine_route',
                  confidence: (o.confidenceOrdinal ?? 2).toDouble(),
                  now: now));
            }
            continue;
          }

          final isIncome = category == TxCategory.received || category == TxCategory.deposit;
          final transactionType = switch (category) {
            TxCategory.withdraw => 'WITHDRAW',
            TxCategory.paybill => 'PAYBILL',
            TxCategory.buyGoods => 'BUY_GOODS',
            TxCategory.sent => 'SENT',
            _ => isIncome ? 'RECEIVED' : category.wireName,
          };

          txRows.add(db.TransactionsCompanion.insert(
            id: nextId++,
            userId: userId,
            amount: amount,
            merchant: merchant,
            category: category.displayLabel,
            date: o.dateMs ?? o.receivedAtMs,
            source: instId.toUpperCase(),
            transactionType: transactionType,
            mpesaCode: Value(externalRef.isEmpty ? null : externalRef),
            sourceHash: Value(sourceHashBank),
            rawSms: Value(o.body),
            createdAt: now,
            updatedAt: now,
            syncState: 'LOCAL',
            recordSource: 'SMS_IMPORT',
            revision: 0,
            fee: Value(o.fee ?? 0.0),
            balanceAfter: Value(o.balanceAfter),
            confidence: Value((o.confidenceOrdinal ?? 2).toDouble()),
            parseRoute: Value(route.name.toUpperCase()),
            description: Value(o.description),
            semanticHash: Value(semHash),
            institutionId: Value(instId),
            externalRef: Value(externalRef.isEmpty ? null : externalRef),
            rawSender: Value(o.rawSenderValue),
            crossRefMpesaCode: Value(o.crossRefMpesaCode),
            status: route == ParseRoute.reviewQueue
                ? const Value('pending_review')
                : const Value('completed'),
          ));

          dedupe?.recordInserted(
            mpesaCode: externalRef,
            sourceHash: sourceHashBank,
            semanticHash: semHash,
            amount: amount,
            merchant: merchant,
            timestamp: o.dateMs ?? o.receivedAtMs,
          );

          auditRows.add(_audit(userId, o.body,
              outcome:
                  source == MpesaIngestionSource.backfill ? 'recovered_from_backfill' : 'imported',
              mpesaCode: externalRef,
              amount: amount,
              merchant: merchant,
              confidence: (o.confidenceOrdinal ?? 2).toDouble(),
              now: now));
          importedCount(counts);
          break;

        case 'fuliza_balance':
          // Balance update — audited, NOT inserted as a ledger row (parity).
          auditRows.add(_audit(userId, o.body,
              outcome: 'fuliza_balance_update',
              amount: o.amount ?? 0,
              confidence: 1,
              now: now));
          ignoredCount(counts);
          break;

        case 'rejected':
        default:
          auditRows.add(_audit(userId, o.body,
              outcome: 'ignored_irrelevant',
              failureReason: o.reason,
              confidence: 0,
              now: now));
          ignoredCount(counts);
          break;
      }
    }

    // ── Single transaction per chunk: batched writes ─────────────────────────
    if (txRows.isNotEmpty || auditRows.isNotEmpty || fulizaEvents.isNotEmpty) {
      await database.transaction(() async {
        if (txRows.isNotEmpty) {
          await database.batch((b) {
            b.insertAll(database.transactions, txRows, mode: InsertMode.insertOrAbort);
          });
        }
        if (auditRows.isNotEmpty) {
          await database.batch((b) {
            b.insertAll(database.importAudit, auditRows, mode: InsertMode.insertOrReplace);
          });
        }
        if (fulizaEvents.isNotEmpty) {
          await database.batch((b) {
            b.insertAll(database.fulizaEvents, fulizaEvents);
          });
        }
        if (paybillUpserts.isNotEmpty) {
          // Pass 1: insert-or-ignore new billers.
          await database.batch((b) {
            for (final e in paybillUpserts.entries) {
              b.insert(
                database.paybillRegistry,
                db.PaybillRegistryCompanion.insert(
                  paybillNumber: e.key,
                  userId: userId,
                  displayName: e.key,
                  lastSeenAt: e.value.seenAt,
                  usageCount: 0,
                  lastAmountKes: e.value.amount,
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }
          });
          // Pass 2: increment usage (two-statement upsert parity with .sq).
          for (final e in paybillUpserts.entries) {
            await database.customStatement(
              'UPDATE paybill_registry SET usage_count = usage_count + 1, '
              'last_seen_at = ?, last_amount_kes = ?, display_name = ? '
              'WHERE user_id = ? AND paybill_number = ?',
              [e.value.seenAt, e.value.amount, e.key, userId, e.key],
            );
          }
        }
      });
    } else if (auditRows.isNotEmpty) {
      await database.batch((b) {
        b.insertAll(database.importAudit, auditRows, mode: InsertMode.insertOrReplace);
      });
    }

    // Persist id generator high-water mark once per chunk.
    if (txRows.isNotEmpty) {
      await holder.saveNextTransactionId(nextId);
    }

    return counts;
  }

  // Counters mirror the Kotlin AtomicInteger semantics.
  static void importedCount(ChunkCounts c) => c.imported++;
  static void duplicatesCount(ChunkCounts c) => c.duplicates++;
  static void ignoredCount(ChunkCounts c) => c.ignored++;

  db.ImportAuditCompanion _audit(
    String userId,
    String rawMessage, {
    required String outcome,
    String? mpesaCode,
    double? amount,
    String? merchant,
    String? failureReason,
    required double confidence,
    required int now,
  }) =>
      db.ImportAuditCompanion.insert(
        id: holder.nextAuditId(),
        userId: userId,
        rawMessage: rawMessage,
        mpesaCode: Value(mpesaCode),
        amount: Value(amount),
        merchant: Value(merchant),
        outcome: outcome,
        failureReason: Value(failureReason),
        importedAt: now,
        createdAt: now,
        updatedAt: now,
        confidenceScore: confidence,
      );
}

const Set<TxCategory> kFulizaDrawCategories = {
  TxCategory.sent,
  TxCategory.airtime,
  TxCategory.paybill,
  TxCategory.buyGoods,
  TxCategory.withdraw,
};

class ChunkCounts {
  int imported = 0;
  int duplicates = 0;
  int parseFailed = 0;
  int ignored = 0;
}
