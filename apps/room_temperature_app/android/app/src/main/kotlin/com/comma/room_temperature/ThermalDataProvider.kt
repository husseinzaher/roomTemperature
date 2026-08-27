package com.comma.room_temperature

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.os.SystemClock
import java.io.File

/**
 * Reads local thermal signals only: battery extras, PowerManager, and
 * publicly readable `/sys/class/thermal` zones. No network, no location.
 */
object ThermalDataProvider {
    private const val THERMAL_DIR = "/sys/class/thermal"
    private const val PROC_STAT = "/proc/stat"

    private var lastCpuSample: CpuSample? = null

    fun snapshot(context: Context): Map<String, Any?> {
        val battery = readBattery(context)
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val cpuUsage = readCpuUsagePercent()
        return mapOf(
            "timestampMs" to System.currentTimeMillis(),
            "batteryCelsius" to battery.temperatureCelsius,
            "batteryLevelPercent" to battery.levelPercent,
            "isCharging" to battery.isCharging,
            "batteryCurrentMicroamps" to battery.currentMicroamps,
            "batteryVoltageMillivolts" to battery.voltageMillivolts,
            "screenOn" to (powerManager?.isInteractive ?: true),
            "thermalStatus" to currentThermalStatus(powerManager),
            "cpuUsagePercent" to cpuUsage,
            "uptimeMs" to SystemClock.elapsedRealtime(),
            "zones" to readThermalZones(),
        )
    }

    private fun currentThermalStatus(powerManager: PowerManager?): Int? {
        if (powerManager == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return null
        }
        return powerManager.currentThermalStatus
    }

    private data class BatteryReading(
        val temperatureCelsius: Double?,
        val levelPercent: Int?,
        val isCharging: Boolean,
        val currentMicroamps: Int?,
        val voltageMillivolts: Int?,
    )

    private fun readBattery(context: Context): BatteryReading {
        val intent = context.registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED),
        )
        val rawTenths = intent?.getIntExtra(
            BatteryManager.EXTRA_TEMPERATURE,
            Int.MIN_VALUE,
        ) ?: Int.MIN_VALUE
        val temperature = if (rawTenths == Int.MIN_VALUE) {
            null
        } else {
            rawTenths / 10.0
        }
        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, 0) ?: 0
        val percent = if (level != null && level >= 0 && scale > 0) {
            (level * 100) / scale
        } else {
            null
        }
        val status = intent?.getIntExtra(
            BatteryManager.EXTRA_STATUS,
            BatteryManager.BATTERY_STATUS_UNKNOWN,
        ) ?: BatteryManager.BATTERY_STATUS_UNKNOWN
        val plugged = intent?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) ?: 0
        val isCharging = plugged != 0 ||
            status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL

        val batteryManager =
            context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
        val current = try {
            batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        } catch (_: Exception) {
            null
        }
        val rawVoltage = intent?.getIntExtra(
            BatteryManager.EXTRA_VOLTAGE,
            -1,
        ) ?: -1
        val voltage = if (rawVoltage > 0) rawVoltage else null

        return BatteryReading(
            temperatureCelsius = temperature,
            levelPercent = percent,
            isCharging = isCharging,
            currentMicroamps = current,
            voltageMillivolts = voltage,
        )
    }

    private fun readThermalZones(): List<Map<String, Any?>> {
        val dir = File(THERMAL_DIR)
        if (!dir.exists() || !dir.isDirectory) {
            return emptyList()
        }
        val children = dir.listFiles() ?: return emptyList()
        val zones = mutableListOf<Map<String, Any?>>()
        for (child in children) {
            if (!child.isDirectory || !child.name.startsWith("thermal_zone")) {
                continue
            }
            val type = readTextOrNull(File(child, "type"))?.trim().orEmpty()
            if (type.isEmpty()) {
                continue
            }
            val rawTemp = readTextOrNull(File(child, "temp"))?.trim() ?: continue
            val millidegrees = rawTemp.toLongOrNull() ?: continue
            val celsius = millidegreesToCelsius(millidegrees)
            if (celsius == null) {
                continue
            }
            zones += mapOf(
                "name" to type,
                "temperatureCelsius" to celsius,
            )
        }
        return zones
    }

    private fun millidegreesToCelsius(raw: Long): Double? {
        val value = when {
            kotlin.math.abs(raw) >= 200 -> raw / 1000.0
            else -> raw.toDouble()
        }
        if (value.isNaN() || value.isInfinite()) {
            return null
        }
        return value
    }

    private fun readCpuUsagePercent(): Double? {
        val line = readTextOrNull(File(PROC_STAT))?.lineSequence()?.firstOrNull()
            ?: return null
        val parts = line.trim().split(Regex("\\s+"))
        if (parts.size < 5 || parts[0] != "cpu") {
            return null
        }
        val numbers = parts.drop(1).mapNotNull { it.toLongOrNull() }
        if (numbers.size < 4) {
            return null
        }
        val idle = numbers[3] + (numbers.getOrNull(4) ?: 0L)
        val total = numbers.sum()
        val previous = lastCpuSample
        lastCpuSample = CpuSample(total = total, idle = idle)
        if (previous == null) {
            return null
        }
        val totalDelta = total - previous.total
        val idleDelta = idle - previous.idle
        if (totalDelta <= 0) {
            return null
        }
        val busy = 1.0 - (idleDelta.toDouble() / totalDelta.toDouble())
        return (busy * 100.0).coerceIn(0.0, 100.0)
    }

    private fun readTextOrNull(file: File): String? {
        return try {
            if (!file.exists() || !file.canRead()) {
                null
            } else {
                file.readText()
            }
        } catch (_: Exception) {
            null
        }
    }

    private data class CpuSample(
        val total: Long,
        val idle: Long,
    )
}
