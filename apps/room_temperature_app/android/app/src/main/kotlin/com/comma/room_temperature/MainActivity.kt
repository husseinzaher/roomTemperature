package com.comma.room_temperature

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val AMBIENT_SENSOR_CHANNEL = "room_temperature/ambient_sensor"
private const val BATTERY_TEMPERATURE_CHANNEL = "room_temperature/battery_temperature"
private const val THERMAL_DATA_CHANNEL = "room_temperature/thermal_data"
private const val AMBIENT_SENSOR_READ_TIMEOUT_MS = 2000L

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AMBIENT_SENSOR_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAmbientTemperatureSensor" -> result.success(hasAmbientTemperatureSensor())
                    "getAmbientTemperature" -> readAmbientTemperature(result)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_TEMPERATURE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasBatteryTemperature" -> result.success(hasBatteryTemperature())
                    "getBatteryTemperature" -> result.success(readBatteryTemperatureCelsius())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, THERMAL_DATA_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getThermalSnapshot" -> result.success(
                        ThermalDataProvider.snapshot(this),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasAmbientTemperatureSensor(): Boolean {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        return sensorManager?.getDefaultSensor(Sensor.TYPE_AMBIENT_TEMPERATURE) != null
    }

    /**
     * Reads `Sensor.TYPE_AMBIENT_TEMPERATURE` once, if the device has one.
     * Most devices don't — [result] resolves to `null` in that case rather
     * than erroring, so the Dart side can fall through Automatic priority.
     */
    private fun readAmbientTemperature(result: MethodChannel.Result) {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        val sensor = sensorManager?.getDefaultSensor(Sensor.TYPE_AMBIENT_TEMPERATURE)
        if (sensorManager == null || sensor == null) {
            result.success(null)
            return
        }

        val handler = Handler(Looper.getMainLooper())
        var resolved = false

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (resolved) return
                resolved = true
                sensorManager.unregisterListener(this)
                result.success(event.values.firstOrNull()?.toDouble())
            }

            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) = Unit
        }

        sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)

        // The sensor may never fire (e.g. it's present but stuck) — time out
        // rather than leaving the Dart Future unresolved forever.
        handler.postDelayed({
            if (!resolved) {
                resolved = true
                sensorManager.unregisterListener(listener)
                result.success(null)
            }
        }, AMBIENT_SENSOR_READ_TIMEOUT_MS)
    }

    private fun hasBatteryTemperature(): Boolean {
        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            ?: return false
        return intent.hasExtra(BatteryManager.EXTRA_TEMPERATURE)
    }

    /**
     * Reads [BatteryManager.EXTRA_TEMPERATURE] and converts tenths of a
     * degree Celsius (`365`) into Celsius (`36.5`).
     */
    private fun readBatteryTemperatureCelsius(): Double? {
        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            ?: return null
        val rawTenthsCelsius = intent.getIntExtra(
            BatteryManager.EXTRA_TEMPERATURE,
            Int.MIN_VALUE,
        )
        if (rawTenthsCelsius == Int.MIN_VALUE) return null
        return rawTenthsCelsius / 10.0
    }
}
