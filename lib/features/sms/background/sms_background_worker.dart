/// Background SMS drain worker — WorkManager callback counterpart to
/// MpesaSmsIngestionWorker.kt.
///
/// When a new SMS arrives while the Flutter engine is detached (app killed or
/// backgrounded), SmsBroadcastReceiver writes the SMS body into two queues:
///   1. lifeos_sms_queue (private prefs)  — drained by MethodChannel on resume
///   2. FlutterSharedPreferences (flutter.lifeos_sms_pending) — drained HERE
///
/// This second queue is accessible to Dart's SharedPreferences plugin without
/// any MethodChannel, making it safe to use inside the WorkManager headless
/// Flutter engine where MainActivity is not active.
///
/// The ingestion pipeline's 4-tier dedup guarantees no duplicate transactions
/// even if both drain paths run for the same message.
library;

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../features/dashboard/data/providers.dart';
import '../ingestion/ingestion_pipeline.dart';
import '../ingestion/ingestion_types.dart';

/// WorkManager task name for ad-hoc drain (fired by SmsBroadcastReceiver).
const kSmsDrainTask = 'sms_drain_task';

/// WorkManager task name for the 30-minute periodic backfill.
const kSmsPeriodicSync = 'sms_periodic_sync';

/// WorkManager unique task IDs (stable across app restarts).
const kSmsDrainUniqueId = 'lifeos_sms_drain';
const kSmsPeriodicUniqueId = 'lifeos_sms_periodic';

/// Top-level WorkManager callback dispatcher.
///
/// Must be a top-level function — @pragma prevents the compiler from
/// tree-shaking it (same pattern as firebase_messaging background handler).
/// Called by the workmanager plugin inside a headless FlutterEngine when a
/// scheduled WorkManager task fires on Android.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // Both ad-hoc drain and periodic sync do the same thing: process
      // whatever is in the Flutter-accessible pending queue.
      await _backgroundDrainAndIngest();
      return true;
    } catch (_) {
      // Return false → WorkManager retries with exponential back-off.
      return false;
    }
  });
}

/// Reads the 'lifeos_sms_pending' queue written by SmsBroadcastReceiver,
/// ingests the messages, then clears the key.
///
/// Uses SharedPreferences directly — no MethodChannel. Safe in the WorkManager
/// headless engine where the 'lifeos/sms' channel is not registered.
Future<void> _backgroundDrainAndIngest() async {
  final prefs = await SharedPreferences.getInstance();
  // reload() ensures we see data written by the Kotlin process after the
  // Dart SharedPreferences cache was last populated.
  await prefs.reload();

  final raw = prefs.getString('lifeos_sms_pending');
  if (raw == null || raw.isEmpty) return;

  // Clear early: if this worker is killed mid-run, the foreground MethodChannel
  // drain path will still pick up the lifeos_sms_queue copy on next resume.
  await prefs.remove('lifeos_sms_pending');

  final List<dynamic> arr;
  try {
    arr = jsonDecode(raw) as List<dynamic>;
  } catch (_) {
    return; // malformed JSON — discard and let foreground path handle it
  }
  if (arr.isEmpty) return;

  final messages = arr.map((e) {
    final m = e as Map<String, dynamic>;
    return RawSms(
      body: m['b'] as String? ?? '',
      sender: m['s'] as String? ?? 'UNKNOWN',
      receivedAtMs: (m['t'] as num?)?.toInt() ?? 0,
    );
  }).toList();

  // Fresh ProviderContainer — we are in a headless isolate without the main
  // container. sharedPrefsProvider resolves via SharedPreferences.getInstance()
  // (no override needed since we're not inside UncontrolledProviderScope).
  final container = ProviderContainer();
  try {
    final dbFuture = container
        .read(lifeOsDatabaseProvider.future)
        .timeout(const Duration(seconds: 30));
    final userFuture = container
        .read(userIdProvider.future)
        .timeout(const Duration(seconds: 10));

    final db = await dbFuture;
    final userId = await userFuture;
    if (userId.isEmpty) return; // not logged in — skip, queue will be retried

    final holder = LifeOsDbHolder(database: db, userId: userId);
    await holder.seedAuditCounter();
    final pipeline = DefaultMpesaIngestionPipeline(holder: holder);
    try {
      await pipeline.ingestBatch(Stream<RawSms>.fromIterable(messages));
    } finally {
      await pipeline.dispose();
    }
  } finally {
    container.dispose();
  }
}
