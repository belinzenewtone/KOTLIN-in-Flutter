package com.personal.lifeos

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.personal.lifeos.sms.SmsBroadcastReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Platform bridge — ports the Android actuals surface:
 *  • SmsReader        → readInbox / isFinancialSms batch handoff
 *  • SmsQueue         → realtime receiver queue drain
 *  • BatteryHelper    → battery-optimization exemption check
 */
class MainActivity : FlutterActivity() {

    private var smsChannel: MethodChannel? = null
    private var systemChannel: MethodChannel? = null

    // Result handle kept alive across the battery-optimisation intent round-trip.
    private var batteryOptResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        smsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lifeos/sms"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "readInbox" -> {
                        val limit = call.argument<Int>("limit") ?: 50000
                        val messages = readInbox(limit)
                        result.success(messages)
                    }
                    "drainQueue" -> {
                        val drained = SmsBroadcastReceiver.drainAll(this).map { (sender, ts, body) ->
                            mapOf("sender" to sender, "timestampMs" to ts, "body" to body)
                        }
                        result.success(drained)
                    }
                    "hasSmsPermissions" -> {
                        result.success(hasSmsPermissions())
                    }
                    "requestSmsPermissions" -> {
                        requestSmsPermissions()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        systemChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lifeos/system"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isBatteryOptimized" -> {
                        result.success(isBatteryOptimizationExempt())
                    }
                    "requestBatteryOptimization" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (isBatteryOptimizationExempt()) {
                                result.success(true)
                            } else {
                                // Keep the result — we'll reply after onResume (user leaves → returns).
                                batteryOptResult = result
                                val intent = Intent(
                                    android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName")
                                )
                                startActivity(intent)
                            }
                        } else {
                            // Pre-M: battery optimisation isn't a concept; treat as exempt.
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Drain any realtime-captured SMS that arrived while detached.
        smsChannel?.invokeMethod("onSmsQueued", null)
        // If the user just returned from the battery-optimisation settings screen,
        // reply with whether the exemption was granted.
        batteryOptResult?.let { pending ->
            batteryOptResult = null
            pending.success(isBatteryOptimizationExempt())
        }
    }

    /** Returns true when the app is already exempt from battery optimisation. */
    private fun isBatteryOptimizationExempt(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun hasSmsPermissions(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) ==
            PackageManager.PERMISSION_GRANTED &&
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermissions() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS),
            4242,
        )
    }

    /** Reads the device inbox — AndroidSmsReader parity. */
    private fun readInbox(limit: Int): List<Map<String, Any>> {
        if (!hasSmsPermissions()) return emptyList()
        val out = mutableListOf<Map<String, Any>>()
        val cursor = contentResolver.query(
            android.provider.Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(
                android.provider.Telephony.Sms._ID,
                android.provider.Telephony.Sms.ADDRESS,
                android.provider.Telephony.Sms.BODY,
                android.provider.Telephony.Sms.DATE,
            ),
            null,
            null,
            "${android.provider.Telephony.Sms.DATE} ASC LIMIT $limit",
        )
        cursor?.use { c ->
            while (c.moveToNext()) {
                out.add(
                    mapOf(
                        "id" to c.getLong(0),
                        "sender" to (c.getString(1) ?: "UNKNOWN"),
                        "body" to (c.getString(2) ?: ""),
                        "timestampMs" to c.getLong(3),
                    )
                )
            }
        }
        return out
    }

    companion object {
        @JvmStatic
        fun notifySmsQueued() {
            // The Dart side polls drainQueue on resume; nothing needed here.
        }
    }
}
