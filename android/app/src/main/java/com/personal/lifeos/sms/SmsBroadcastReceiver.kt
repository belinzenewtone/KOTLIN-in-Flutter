package com.personal.lifeos.sms

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import org.json.JSONArray
import org.json.JSONObject

/**
 * Real-time SMS capture — port of MpesaSmsReceiver.kt.
 *
 * Path A (foreground): queues in `lifeos_sms_queue` ring buffer; MainActivity
 *   drains on resume via "lifeos/sms" MethodChannel → Dart drainRealtimeAndIngest().
 * Path B (background/killed): appends a JSON copy to FlutterSharedPreferences
 *   (`flutter.lifeos_sms_pending`) and schedules a WorkManager one-shot drain
 *   so the Dart callbackDispatcher picks it up even when the app is killed.
 */
class SmsBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        for (sms in messages) {
            val body   = sms.displayMessageBody ?: continue
            val sender = sms.originatingAddress ?: "UNKNOWN"
            val ts     = sms.timestampMillis

            // Path A — foreground MethodChannel ring-buffer
            enqueue(context, sender, body, ts)

            // Path B — WorkManager background JSON queue
            appendToFlutterQueue(context, sender, body, ts)
        }
        // Collapse burst of SMS into a single pending WorkManager drain
        scheduleSmsDrain(context)
    }

    companion object {
        // ── Path A: SOH-delimited ring-buffer (MethodChannel drain on resume) ─────
        private const val PREFS     = "lifeos_sms_queue"
        private const val KEY_COUNT = "count"
        private const val PREFIX    = "msg_"
        private const val SEP       = ""

        fun enqueue(context: Context, sender: String, body: String, ts: Long) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            synchronized(prefs) {
                val count = prefs.getInt(KEY_COUNT, 0)
                val entry = "$sender$SEP$ts$SEP${body.replace(SEP, " ")}"
                prefs.edit()
                    .putString("$PREFIX$count", entry)
                    .putInt(KEY_COUNT, count + 1)
                    .apply()
            }
        }

        @SuppressLint("CommitPrefEdits")
        fun drainAll(context: Context): List<Triple<String, Long, String>> {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val out   = mutableListOf<Triple<String, Long, String>>()
            synchronized(prefs) {
                val count = prefs.getInt(KEY_COUNT, 0)
                val edit  = prefs.edit()
                for (i in 0 until count) {
                    val entry = prefs.getString("$PREFIX$i", null) ?: continue
                    val parts = entry.split(SEP, limit = 3)
                    if (parts.size == 3) {
                        out.add(Triple(parts[0], parts[1].toLongOrNull() ?: 0L, parts[2]))
                    }
                    edit.remove("$PREFIX$i")
                }
                edit.putInt(KEY_COUNT, 0).apply()
            }
            return out
        }

        // ── Path B: FlutterSharedPreferences JSON queue (WorkManager drain) ───────
        // Dart's SharedPreferences.getInstance() reads FlutterSharedPreferences.
        // Key convention: the Flutter package stores values with "flutter." prefix;
        // Dart reads them WITHOUT that prefix via SharedPreferences.getString('key').
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val FLUTTER_KEY   = "flutter.lifeos_sms_pending"
        private const val WM_TASK_NAME  = "lifeos_sms_drain_oneshot"
        // Must match kSmsDrainTask constant in sms_background_worker.dart
        private const val DART_TASK     = "sms_drain_task"

        /** Append one SMS as a JSON object to the pending Flutter queue. */
        fun appendToFlutterQueue(context: Context, sender: String, body: String, ts: Long) {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            synchronized(prefs) {
                val existing = prefs.getString(FLUTTER_KEY, "[]") ?: "[]"
                val arr = try { JSONArray(existing) } catch (_: Exception) { JSONArray() }
                arr.put(JSONObject().apply {
                    put("s", sender)
                    put("b", body)
                    put("t", ts)
                })
                prefs.edit().putString(FLUTTER_KEY, arr.toString()).apply()
            }
        }

        /**
         * Schedule a one-shot WorkManager task to drain the Flutter JSON queue.
         * Uses REPLACE policy so a burst of incoming SMS yields one pending drain.
         * The worker class is dev.fluttercommunity.workmanager.BackgroundWorker —
         * registered by the workmanager Flutter plugin which reads the DART_TASK
         * input data and invokes callbackDispatcher() in a headless FlutterEngine.
         */
        fun scheduleSmsDrain(context: Context) {
            val data = Data.Builder()
                .putString("be.tramckrijte.workmanager.DART_TASK", DART_TASK)
                .build()
            val request = OneTimeWorkRequest.Builder(
                dev.fluttercommunity.workmanager.BackgroundWorker::class.java
            ).setInputData(data).build()

            WorkManager.getInstance(context)
                .enqueueUniqueWork(WM_TASK_NAME, ExistingWorkPolicy.REPLACE, request)
        }
    }
}

/** Re-arms background workers after device reboot — MpesaBootReceiver parity. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Drain any messages that arrived while the device was off.
            SmsBroadcastReceiver.scheduleSmsDrain(context)
            // Dart registers the 30-min periodic sync when the app next opens.
        }
    }
}
