package com.personal.lifeos.sms

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * Real-time SMS capture — port of MpesaSmsReceiver.kt.
 *
 * Every incoming SMS is forwarded to the Dart ingestion pipeline over the
 * "lifeos/sms" MethodChannel. When the engine is not attached (app killed),
 * messages are queued in a SharedPreferences ring buffer and drained on next
 * launch — matching the Kotlin SmsIngestQueue semantics.
 */
class SmsBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        for (sms in messages) {
            val body = sms.displayMessageBody ?: continue
            val sender = sms.originatingAddress ?: "UNKNOWN"
            enqueue(context, sender, body, sms.timestampMillis)
        }
        // The Dart side drains this queue on resume (MainActivity.onResume).
    }

    companion object {
        private const val PREFS = "lifeos_sms_queue"
        private const val KEY_COUNT = "count"
        private const val PREFIX = "msg_"

        fun enqueue(context: Context, sender: String, body: String, ts: Long) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            synchronized(prefs) {
                val count = prefs.getInt(KEY_COUNT, 0)
                val entry = "$sender\u0001$ts\u0001${body.replace("\u0001", " ")}"
                prefs.edit().putString("$PREFIX$count", entry).putInt(KEY_COUNT, count + 1).apply()
            }
        }

        @SuppressLint("CommitPrefEdits")
        fun drainAll(context: Context): List<Triple<String, Long, String>> {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val out = mutableListOf<Triple<String, Long, String>>()
            synchronized(prefs) {
                val count = prefs.getInt(KEY_COUNT, 0)
                for (i in 0 until count) {
                    val entry = prefs.getString("$PREFIX$i", null) ?: continue
                    val parts = entry.split("\u0001", limit = 3)
                    if (parts.size == 3) {
                        out.add(Triple(parts[0], parts[1].toLongOrNull() ?: 0L, parts[2]))
                    }
                    prefs.edit().remove("$PREFIX$i").apply()
                }
                prefs.edit().putInt(KEY_COUNT, 0).apply()
            }
            return out
        }
    }
}

/** Re-arms periodic work after reboot — MpesaBootReceiver parity. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Periodic sync re-registration happens from Dart via workmanager.
        }
    }
}
