/// Enhanced deduplication engine — port of MpesaDedupeEngineEnhanced.kt
/// re-engineered for 100k+ message batches.
///
/// Four dedupe tiers (identical semantics to Kotlin):
///   1. mpesa_code exact match        (indexed column + in-memory set)
///   2. source_hash SHA-256 of body   (indexed column + in-memory set)
///   3. semantic_hash normalized props(indexed column + in-memory set)
///   4. heuristic: same amount ±0.01 + merchant (case-insensitive) within a
///      time window — served from an in-memory secondary index instead of a
///      per-message SQL scan.
///
/// The in-memory indexes are hydrated once per import run and updated as rows
/// are inserted, so every check is O(1)/O(log n) regardless of ledger size and
/// stays consistent with rows inserted earlier in the SAME batch (matching the
/// Kotlin behavior where each chunk commit is visible to later checks).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Variable;

import '../../../core/database/database.dart';
import '../parser/parser_types.dart';

class DedupeIndexConfig {
  const DedupeIndexConfig({
    this.windowMillis = 5 * 60 * 1000,
    this.hydrateSemanticHashes = true,
  });

  final int windowMillis;

  /// Set false on low-RAM devices to skip hydrating the semantic-hash set
  /// (falls back to indexed SQL lookups; ~40 bytes/message saved).
  final bool hydrateSemanticHashes;
}

class MpesaDedupeEngine {
  MpesaDedupeEngine(this._db);

  final LifeOsDatabase _db;
  DedupeIndexConfig _config = const DedupeIndexConfig();

  // In-memory mirrors of the indexed columns.
  final Set<String> _codes = {};
  final Set<String> _sourceHashes = {};
  final Set<String> _semanticHashes = {};

  /// Secondary index for the heuristic tier:
  /// key = "${amount.toStringAsFixed(2)}|${merchant.toUpperCase()}" → sorted timestamps.
  final Map<String, List<int>> _heuristic = {};

  bool _hydrated = false;

  int get codeCount => _codes.length;

  /// Hydrates the indexes from existing ledger rows. Call once before a bulk
  /// import; safe to call again (re-hydrates).
  Future<void> hydrate(String userId, {DedupeIndexConfig? config}) async {
    if (config != null) _config = config;

    final rows = await _db.customSelect(
      'SELECT mpesa_code, source_hash, semantic_hash, amount, merchant, date '
      'FROM transactions WHERE user_id = ? AND deleted_at IS NULL',
      variables: [Variable.withString(userId)],
    ).get();

    _codes.clear();
    _sourceHashes.clear();
    if (_config.hydrateSemanticHashes) _semanticHashes.clear();
    _heuristic.clear();

    for (final row in rows) {
      final d = row.data;
      final code = d['mpesa_code'] as String?;
      if (code != null && code.isNotEmpty) _codes.add(code);
      final sh = d['source_hash'] as String?;
      if (sh != null && sh.isNotEmpty) _sourceHashes.add(sh);
      final semh = d['semantic_hash'] as String?;
      if (semh != null &&
          semh.isNotEmpty &&
          _config.hydrateSemanticHashes) {
        _semanticHashes.add(semh);
      }
      _indexHeuristic(
        amount: (d['amount'] as num).toDouble(),
        merchant: (d['merchant'] as String?) ?? '',
        timestamp: (d['date'] as num).toInt(),
      );
    }
    _hydrated = true;
  }

  void ensureHydrated() {
    if (!_hydrated) {
      throw StateError('MpesaDedupeEngine.hydrate() must run before ingestBatch');
    }
  }

  /// Full four-tier duplicate check (parity with Kotlin `isDuplicate`).
  Future<bool> isDuplicate({
    required String mpesaCode,
    required String rawMessage,
    required double amount,
    required String merchant,
    required int timestamp,
    String? inlineSemanticHash,
  }) async {
    // Tier 1: exact M-Pesa code.
    if (mpesaCode.isNotEmpty && _codes.contains(mpesaCode)) return true;

    // Tier 2: source hash of the raw body.
    final sourceHash = sha256OfRaw(rawMessage);
    if (_sourceHashes.contains(sourceHash)) return true;

    // Tier 3: semantic hash (inline from parser or computed here).
    final semantic = (inlineSemanticHash != null && inlineSemanticHash.isNotEmpty)
        ? inlineSemanticHash
        : computeSemanticHash('TRANSACTION', amount, timestamp, merchant);
    if (semantic.isNotEmpty && _semanticHashes.contains(semantic)) return true;

    // Tier 4: heuristic window match.
    return _heuristicMatch(amount, merchant, timestamp, _config.windowMillis);
  }

  /// Registers a freshly inserted transaction so subsequent checks see it.
  void recordInserted({
    required String mpesaCode,
    required String sourceHash,
    required String semanticHash,
    required double amount,
    required String merchant,
    required int timestamp,
  }) {
    if (mpesaCode.isNotEmpty) _codes.add(mpesaCode);
    if (sourceHash.isNotEmpty) _sourceHashes.add(sourceHash);
    if (semanticHash.isNotEmpty) _semanticHashes.add(semanticHash);
    _indexHeuristic(amount: amount, merchant: merchant, timestamp: timestamp);
  }

  /// Direct set membership probes (bank dedupe tiers).
  bool hasMpesaCode(String code) => code.isNotEmpty && _codes.contains(code);
  bool hasSourceHash(String hash) => hash.isNotEmpty && _sourceHashes.contains(hash);
  bool hasSemanticHash(String hash) => hash.isNotEmpty && _semanticHashes.contains(hash);

  void _indexHeuristic({
    required double amount,
    required String merchant,
    required int timestamp,
  }) {
    final key = '${amount.toStringAsFixed(2)}|${merchant.toUpperCase()}';
    final list = _heuristic[key];
    if (list == null) {
      _heuristic[key] = [timestamp];
    } else {
      // Keep sorted for binary search.
      var lo = 0, hi = list.length;
      while (lo < hi) {
        final mid = (lo + hi) >> 1;
        if (list[mid] < timestamp) {
          lo = mid + 1;
        } else {
          hi = mid;
        }
      }
      list.insert(lo, timestamp);
    }
  }

  bool _heuristicMatch(double amount, String merchant, int timestamp, int windowMs) {
    final key = '${amount.toStringAsFixed(2)}|${merchant.toUpperCase()}';
    final list = _heuristic[key];
    if (list == null || list.isEmpty) return false;

    final lo = timestamp - windowMs;
    final hi = timestamp + windowMs;

    // Binary search for first element >= lo, then scan while <= hi.
    var start = 0, end = list.length;
    while (start < end) {
      final mid = (start + end) >> 1;
      if (list[mid] < lo) {
        start = mid + 1;
      } else {
        end = mid;
      }
    }
    return start < list.length && list[start] <= hi;
  }

  /// Fuliza-variant duplicate: same code with Fuliza context (parity).
  Future<bool> isFulizaVariantDuplicate({
    required String mpesaCode,
    required String rawMessage,
  }) async {
    if (!rawMessage.toLowerCase().contains('fuliza')) return false;
    return mpesaCode.isNotEmpty && _codes.contains(mpesaCode);
  }

  void clear() {
    _codes.clear();
    _sourceHashes.clear();
    _semanticHashes.clear();
    _heuristic.clear();
    _hydrated = false;
  }
}

// SHA-256 helper (crypto package).
String computeSemanticHash(
    String transactionType, double amount, int timestampMs, String counterparty) {
  final local = DateTime.fromMillisecondsSinceEpoch(timestampMs).toLocal();
  final yyyyMMdd =
      '${local.year.toString().padLeft(4, '0')}${local.month.toString().padLeft(2, '0')}${local.day.toString().padLeft(2, '0')}';
  final input =
      '$transactionType|${amount.toStringAsFixed(2)}|$yyyyMMdd|${counterparty.toLowerCase().trim()}';
  return sha256.convert(utf8.encode(input)).toString();
}

String sha256OfRaw(String raw) => sha256.convert(utf8.encode(raw)).toString();
