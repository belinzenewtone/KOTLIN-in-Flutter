/// Parallel parser isolate pool.
///
/// Mirrors Kotlin's `async(Dispatchers.Default)` fan-out in
/// DefaultMpesaIngestionPipeline.ingestBatch — CPU-bound regex work runs on
/// worker isolates so the UI isolate never stalls during 100k-message
/// backfills.
///
/// Workers are long-lived (spawned once, reused for every chunk) which keeps
/// per-chunk overhead at one message send instead of an isolate spawn.
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../parser/parser_pipeline.dart' as pp;

/// Serializable parse result crossing isolate boundaries (primitives only).
class ParsedOutcome {
  const ParsedOutcome({
    required this.kind,
    required this.body,
    required this.sender,
    required this.receivedAtMs,
    this.reason,
    this.mpesaCode,
    this.amount,
    this.categoryWire,
    this.confidenceOrdinal,
    this.counterparty,
    this.description,
    this.balanceAfter,
    this.fee,
    this.dateMs,
    this.parseRouteIndex,
    this.semanticHash,
    this.matchedRulePhase,
    this.merchantCategoryIndex,
    this.isReceivedReversal,
    this.fulizaOutstandingKes,
    this.externalRef,
    this.sourceHash,
    this.institutionId,
    this.rawSenderValue,
    this.crossRefMpesaCode,
    this.accessFeeKes,
    this.amountUsedKes,
    this.dueDateMs,
  });

  /// 'mpesa' | 'bank' | 'rejected' | 'fuliza_balance'
  final String kind;
  final String body;
  final String sender;
  final int receivedAtMs;
  final String? reason;

  final String? mpesaCode;
  final double? amount;
  final String? categoryWire;
  final int? confidenceOrdinal; // PConfidence.index: 0 high, 1 medium, 2 low
  final String? counterparty;
  final String? description;
  final double? balanceAfter;
  final double? fee;
  final int? dateMs;
  final int? parseRouteIndex; // ParseRoute.index: 0 ledger, 1 review, 2 quarantine
  final String? semanticHash;
  final int? matchedRulePhase;
  final int? merchantCategoryIndex;

  final bool? isReceivedReversal;
  final double? fulizaOutstandingKes;

  final String? externalRef;
  final String? sourceHash;
  final String? institutionId;
  final String? rawSenderValue;
  final String? crossRefMpesaCode;

  final double? accessFeeKes;
  final double? amountUsedKes;
  final int? dueDateMs;
}

typedef ParseItem = (String body, String sender, int receivedAtMs);

class _ParseJob {
  const _ParseJob(this.jobId, this.items, this.reply);
  final int jobId;
  final List<ParseItem> items;
  final SendPort reply;
}

class ParserIsolatePool {
  ParserIsolatePool._(this._size);

  final int _size;

  int get workerCount => _size;
  final List<_Worker> _workers = [];
  int _next = 0;

  /// Kotlin: minOf(availableProcessors, 8).coerceAtLeast(2).
  static Future<ParserIsolatePool> spawn() async {
    final cpus = Platform.numberOfProcessors;
    final size = cpus < 2 ? 2 : (cpus > 8 ? 8 : cpus);
    final pool = ParserIsolatePool._(size);
    await pool._start();
    return pool;
  }

  Future<void> _start() async {
    for (var i = 0; i < _size; i++) {
      _workers.add(await _Worker.spawn());
    }
  }

  /// Parses a chunk on the next worker (round-robin). Worker failures surface
  /// as exceptions to the caller, which converts them into per-item rejects.
  Future<List<ParsedOutcome>> parseChunk(List<ParseItem> items) {
    if (_workers.isEmpty) {
      throw StateError('ParserIsolatePool not started');
    }
    final worker = _workers[_next];
    _next = (_next + 1) % _workers.length;
    return worker.parse(items);
  }

  Future<void> dispose() async {
    for (final w in _workers) {
      w.dispose();
    }
    _workers.clear();
  }
}

class _Worker {
  _Worker._(this._toWorker, this._fromWorker, this._isolate);

  final SendPort _toWorker;
  final ReceivePort _fromWorker;
  final Isolate _isolate;
  late final StreamSubscription<dynamic> _sub;
  final Map<int, Completer<List<ParsedOutcome>>> _pending = {};
  int _jobSeq = 0;

  static Future<_Worker> spawn() async {
    final fromWorker = ReceivePort();
    final isolate = await Isolate.spawn(_workerMain, fromWorker.sendPort);

    final handshake = Completer<SendPort>();
    late final StreamSubscription<dynamic> sub;
    sub = fromWorker.listen((msg) {
      if (!handshake.isCompleted) {
        handshake.complete(msg as SendPort);
        return;
      }
      // Job results arrive here when routed via _pending (unused for now —
      // per-job reply ports carry results).
      if (msg is List && msg.isNotEmpty && msg[0] is int) {
        final jobId = msg[0] as int;
        final outcomes =
            (msg[1] as List).cast<Map>().map(ParsedOutcomeX.fromMap).toList();
        final completer = _pendingStatic.remove(jobId);
        if (completer != null && !completer.isCompleted) {
          completer.complete(outcomes);
        }
      }
    }, onError: (Object e) {
      if (!handshake.isCompleted) handshake.completeError(e);
    });

    final toWorker = await handshake.future.timeout(const Duration(seconds: 15));
    final worker = _Worker._(toWorker, fromWorker, isolate);
    worker._sub = sub;
    return worker;
  }

  static final Map<int, Completer<List<ParsedOutcome>>> _pendingStatic = {};

  Future<List<ParsedOutcome>> parse(List<ParseItem> items) {
    final jobId = _jobSeq++;
    final reply = ReceivePort();
    final completer = Completer<List<ParsedOutcome>>();
    _pending[jobId] = completer;

    late final StreamSubscription<dynamic> sub;
    sub = reply.listen((msg) {
      if (msg is! List) return;
      final id = msg[0] as int;
      final outcomes =
          (msg[1] as List).cast<Map>().map(ParsedOutcomeX.fromMap).toList();
      final pending = _pending.remove(id);
      if (pending != null && !pending.isCompleted) {
        pending.complete(outcomes);
      }
      unawaited(sub.cancel());
      reply.close();
    });

    _toWorker.send(_ParseJob(jobId, items, reply.sendPort));
    return completer.future;
  }

  void dispose() {
    _toWorker.send(null);
    _sub.cancel();
    _fromWorker.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}

Future<void> _workerMain(SendPort initialPort) async {
  final port = ReceivePort();
  initialPort.send(port.sendPort);

  await for (final msg in port) {
    if (msg == null) break;
    final job = msg as _ParseJob;

    final outcomes = <Map<String, Object?>>[];
    for (final (body, sender, ts) in job.items) {
      try {
        final outcome = pp.ParserPipeline.process(body, sender, ts);
        outcomes.add(serializeOutcome(body, sender, ts, outcome));
      } catch (e) {
        outcomes.add({
          'kind': 'rejected',
          'reason': 'parse_exception: $e',
          'body': body,
          'sender': sender,
          'receivedAtMs': ts,
        });
      }
    }
    job.reply.send([job.jobId, outcomes]);
  }
}

Map<String, Object?> serializeOutcome(
    String body, String sender, int ts, pp.SmsParseOutcome outcome) {
  final base = <String, Object?>{
    'body': body,
    'sender': sender,
    'receivedAtMs': ts,
  };
  switch (outcome) {
    case final pp.MpesaOutcomeSuccess s:
      final t = s.transaction;
      return base
        ..['kind'] = 'mpesa'
        ..['mpesaCode'] = t.mpesaCode
        ..['amount'] = t.amount
        ..['categoryWire'] = t.category.wireName
        ..['confidenceOrdinal'] = t.confidence.index
        ..['counterparty'] = t.counterparty
        ..['description'] = t.description
        ..['balanceAfter'] = t.balanceAfter
        ..['fee'] = t.fee
        ..['dateMs'] = t.date
        ..['parseRouteIndex'] = t.parseRoute.index
        ..['semanticHash'] = t.semanticHash
        ..['matchedRulePhase'] = t.matchedRulePhase
        ..['merchantCategoryIndex'] = t.merchantCategory.index
        ..['isReceivedReversal'] = t.isReceivedReversal
        ..['fulizaOutstandingKes'] = t.fulizaOutstandingKes;
    case final pp.BankOutcomeSuccess s:
      final t = s.transaction;
      return base
        ..['kind'] = 'bank'
        ..['externalRef'] = t.externalRef
        ..['amount'] = t.amount
        ..['categoryWire'] = t.category.wireName
        ..['confidenceOrdinal'] = t.confidence.index
        ..['counterparty'] = t.counterparty
        ..['description'] = t.description
        ..['balanceAfter'] = t.balanceAfter
        ..['fee'] = t.fee
        ..['dateMs'] = t.date
        ..['parseRouteIndex'] = t.parseRoute.index
        ..['semanticHash'] = t.semanticHash
        ..['sourceHash'] = t.sourceHash
        ..['institutionId'] = t.institutionId
        ..['merchantCategoryIndex'] = t.merchantCategory.index
        ..['rawSenderValue'] = t.rawSender
        ..['crossRefMpesaCode'] = t.crossRefMpesaCode;
    case final pp.FulizaBalanceUpdateOutcome f:
      return base
        ..['kind'] = 'fuliza_balance'
        ..['amount'] = f.outstandingKes
        ..['accessFeeKes'] = f.accessFeeKes
        ..['amountUsedKes'] = f.amountUsedKes
        ..['dueDateMs'] = f.dueDate
        ..['dateMs'] = f.date;
    case final pp.RejectedOutcome r:
      return base
        ..['kind'] = 'rejected'
        ..['reason'] = r.reason;
  }
}

extension ParsedOutcomeX on ParsedOutcome {
  static ParsedOutcome fromMap(Map<dynamic, dynamic> m) => ParsedOutcome(
        kind: m['kind'] as String,
        body: m['body'] as String,
        sender: m['sender'] as String,
        receivedAtMs: m['receivedAtMs'] as int,
        reason: m['reason'] as String?,
        mpesaCode: m['mpesaCode'] as String?,
        amount: (m['amount'] as num?)?.toDouble(),
        categoryWire: m['categoryWire'] as String?,
        confidenceOrdinal: m['confidenceOrdinal'] as int?,
        counterparty: m['counterparty'] as String?,
        description: m['description'] as String?,
        balanceAfter: (m['balanceAfter'] as num?)?.toDouble(),
        fee: (m['fee'] as num?)?.toDouble(),
        dateMs: m['dateMs'] as int?,
        parseRouteIndex: m['parseRouteIndex'] as int?,
        semanticHash: m['semanticHash'] as String?,
        matchedRulePhase: m['matchedRulePhase'] as int?,
        merchantCategoryIndex: m['merchantCategoryIndex'] as int?,
        isReceivedReversal: m['isReceivedReversal'] as bool?,
        fulizaOutstandingKes: (m['fulizaOutstandingKes'] as num?)?.toDouble(),
        externalRef: m['externalRef'] as String?,
        sourceHash: m['sourceHash'] as String?,
        institutionId: m['institutionId'] as String?,
        rawSenderValue: m['rawSenderValue'] as String?,
        crossRefMpesaCode: m['crossRefMpesaCode'] as String?,
        accessFeeKes: (m['accessFeeKes'] as num?)?.toDouble(),
        amountUsedKes: (m['amountUsedKes'] as num?)?.toDouble(),
        dueDateMs: m['dueDateMs'] as int?,
      );
}
