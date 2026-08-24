/// Platform SMS bridge — Dart side of the "lifeos/sms" MethodChannel +
/// historical import service feeding the ingestion pipeline
/// (AndroidMpesaHistoricalImportScanner / MpesaSmsIngestionWorker parity).
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/data/providers.dart';
import '../../features/sms/ingestion/ingestion_pipeline.dart';
import '../../features/sms/ingestion/ingestion_types.dart';

class SmsPlatformBridge {
  static const MethodChannel _channel = MethodChannel('lifeos/sms');

  /// Full inbox read for backfill — AndroidSmsReader parity.
  static Future<List<RawSms>> readInbox({int limit = 50000}) async {
    try {
      final rows = await _channel.invokeMethod<List<dynamic>>('readInbox', {'limit': limit});
      if (rows == null) return const [];
      return [
        for (final r in rows.cast<Map>())
          RawSms(
            id: r['id'] as int?,
            body: r['body'] as String? ?? '',
            sender: r['sender'] as String? ?? 'UNKNOWN',
            receivedAtMs: (r['timestampMs'] as num?)?.toInt() ?? 0,
          ),
      ];
    } on PlatformException {
      return const [];
    }
  }

  /// Drains realtime receiver queue captured while the engine was detached.
  static Future<List<RawSms>> drainRealtimeQueue() async {
    try {
      final rows = await _channel.invokeMethod<List<dynamic>>('drainQueue');
      if (rows == null) return const [];
      return [
        for (final r in rows.cast<Map>())
          RawSms(
            body: r['body'] as String? ?? '',
            sender: r['sender'] as String? ?? 'UNKNOWN',
            receivedAtMs: (r['timestampMs'] as num?)?.toInt() ?? 0,
          ),
      ];
    } on PlatformException {
      return const [];
    }
  }

  static Future<bool> hasSmsPermissions() async {
    try {
      return await _channel.invokeMethod<bool>('hasSmsPermissions') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestSmsPermissions() async {
    try {
      await _channel.invokeMethod('requestSmsPermissions');
    } on PlatformException {
      // ignore
    }
  }
}

/// Runs the full historical import: inbox → parser pool → batched writes.
///
/// [source] controls which institutions are processed:
///   'all'   → M-Pesa + Banks + Airtel (default)
///   'mpesa' → M-Pesa only (sender contains MPESA)
///   'banks' → Everything except M-Pesa and Airtel
Future<BatchIngestionResult?> runHistoricalSmsImport(
  dynamic ref, {
  String source = 'all',
}) async {
  final dbReady = await ref.read(lifeOsDatabaseProvider.future).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw StateError('db timeout'),
      );

  final userId = await ref.read(userIdProvider.future);
  if (!await SmsPlatformBridge.hasSmsPermissions()) {
    await SmsPlatformBridge.requestSmsPermissions();
    if (!await SmsPlatformBridge.hasSmsPermissions()) return null;
  }

  final messages = await SmsPlatformBridge.readInbox();
  final queued = await SmsPlatformBridge.drainRealtimeQueue();
  var all = [...messages, ...queued];
  if (all.isEmpty) return const BatchIngestionResult(imported: 0, duplicates: 0, parseFailed: 0, ignored: 0);

  // Apply source filter: check sender string for institution category.
  if (source == 'mpesa') {
    all = all
        .where((m) => m.sender.toUpperCase().contains('MPESA') ||
            m.sender.toUpperCase() == 'M-PESA')
        .toList();
  } else if (source == 'banks') {
    all = all
        .where((m) {
          final s = m.sender.toUpperCase();
          return !s.contains('MPESA') && s != 'M-PESA' &&
              !s.contains('AIRTEL') && !s.contains('TKASH');
        })
        .toList();
  }
  if (all.isEmpty) return const BatchIngestionResult(imported: 0, duplicates: 0, parseFailed: 0, ignored: 0);

  final holder = LifeOsDbHolder(database: dbReady, userId: userId);
  await holder.seedAuditCounter();
  final pipeline = DefaultMpesaIngestionPipeline(holder: holder);
  try {
    return await pipeline.ingestBatch(Stream<RawSms>.fromIterable(all));
  } finally {
    await pipeline.dispose();
  }
}
