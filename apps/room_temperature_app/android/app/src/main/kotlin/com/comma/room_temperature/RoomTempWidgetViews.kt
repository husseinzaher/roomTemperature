package com.comma.room_temperature

import android.app.ActivityOptions
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProviderInfo
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.view.View
import android.widget.RemoteViews

/**
 * Binds shared widget prefs onto a home or lock-screen [RemoteViews] layout.
 *
 * Layout ids for indoor/outdoor values must match across both XML files so
 * the same binder can drive the large home card and the compact lock card.
 * Dashboard-only rows (stats, forecast, condition) are bound only on the
 * large home layout so missing ids never crash the lock widget.
 */
object RoomTempWidgetViews {
    private const val ROOM_TEMP_KEY = "room_temp"
    private const val OUTSIDE_TEMP_KEY = "outside_temp"
    private const val LEGACY_ROOM_TEMP_KEY = "room_temp_c"
    private const val LEGACY_OUTSIDE_TEMP_KEY = "outside_temp_c"
    private const val UNIT_SYMBOL_KEY = "unit_symbol"
    private const val SOURCE_LABEL_KEY = "source_label"
    private const val UPDATED_AT_KEY = "updated_at_label"
    private const val THRESHOLD_BREACHED_KEY = "threshold_breached"
    private const val LOCATION_LABEL_KEY = "location_label"
    private const val DATE_LABEL_KEY = "date_label"
    private const val CONDITION_LABEL_KEY = "condition_label"
    private const val CONDITION_ICON_KEY = "condition_icon"
    private const val FEELS_LIKE_KEY = "feels_like_label"
    private const val HUMIDITY_KEY = "humidity_label"
    private const val WIND_KEY = "wind_label"
    private const val UV_KEY = "uv_label"
    private const val COMPACT_MIN_WIDTH_DP = 220
    private const val COMPACT_MIN_HEIGHT_DP = 170

    fun build(
        context: Context,
        layoutId: Int,
        widgetData: SharedPreferences,
        widgetId: Int,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, layoutId)
        val roomTemp = widgetData.getString(ROOM_TEMP_KEY, null)
            ?: widgetData.getString(LEGACY_ROOM_TEMP_KEY, null)
        val outsideTemp = widgetData.getString(OUTSIDE_TEMP_KEY, null)
            ?: widgetData.getString(LEGACY_OUTSIDE_TEMP_KEY, null)
        val unit = widgetData.getString(UNIT_SYMBOL_KEY, "°C") ?: "°C"
        val source = widgetData.getString(SOURCE_LABEL_KEY, null)
        val updatedAt = widgetData.getString(UPDATED_AT_KEY, null)
        val location = widgetData.getString(LOCATION_LABEL_KEY, null)
        val breached = widgetData.getBoolean(THRESHOLD_BREACHED_KEY, false)

        views.setTextViewText(R.id.room_temp_value, roomTemp ?: "—")
        views.setTextViewText(R.id.room_temp_unit, unit)
        views.setTextViewText(
            R.id.outside_temp_value,
            if (outsideTemp != null) "$outsideTemp$unit" else "—",
        )

        val roomColor = context.getColor(
            if (breached) R.color.widget_alert else R.color.widget_normal,
        )
        views.setTextColor(R.id.room_temp_value, roomColor)

        if (source.isNullOrBlank()) {
            views.setViewVisibility(R.id.source_label, View.GONE)
        } else {
            views.setViewVisibility(R.id.source_label, View.VISIBLE)
            views.setTextViewText(R.id.source_label, source)
        }

        views.setTextViewText(
            R.id.updated_at_value,
            if (updatedAt != null) {
                context.getString(R.string.widget_updated_at, updatedAt)
            } else {
                ""
            },
        )

        if (location.isNullOrBlank()) {
            views.setViewVisibility(R.id.location_row, View.GONE)
        } else {
            views.setViewVisibility(R.id.location_row, View.VISIBLE)
            views.setTextViewText(R.id.location_label, location)
        }

        val clickableIds = sharedClickableIds.toMutableList()
        if (layoutId == R.layout.room_temp_widget) {
            bindDashboard(views, widgetData)
            clickableIds.addAll(dashboardClickableIds)
        }

        bindLaunchApp(context, views, widgetId, clickableIds)

        return views
    }

    private fun bindDashboard(
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        views.setTextViewText(
            R.id.date_label,
            widgetData.getString(DATE_LABEL_KEY, "") ?: "",
        )

        val condition = widgetData.getString(CONDITION_LABEL_KEY, null)
        if (condition.isNullOrBlank()) {
            views.setViewVisibility(R.id.condition_row, View.GONE)
        } else {
            views.setViewVisibility(R.id.condition_row, View.VISIBLE)
            views.setTextViewText(R.id.condition_label, condition)
            views.setImageViewResource(
                R.id.condition_icon,
                weatherIcon(widgetData.getString(CONDITION_ICON_KEY, null)),
            )
        }

        views.setTextViewText(
            R.id.feels_like_value,
            displayOrDash(widgetData.getString(FEELS_LIKE_KEY, null)),
        )
        views.setTextViewText(
            R.id.humidity_value,
            displayOrDash(widgetData.getString(HUMIDITY_KEY, null)),
        )
        views.setTextViewText(
            R.id.wind_value,
            displayOrDash(widgetData.getString(WIND_KEY, null)),
        )
        views.setTextViewText(
            R.id.uv_value,
            displayOrDash(widgetData.getString(UV_KEY, null)),
        )

        var hasForecast = false
        for (index in 0 until 4) {
            val label = widgetData.getString("forecast_${index}_label", null)
            val range = widgetData.getString("forecast_${index}_range", null)
            val icon = widgetData.getString("forecast_${index}_icon", null)
            if (!label.isNullOrBlank()) {
                hasForecast = true
            }
            views.setTextViewText(forecastLabelIds[index], label ?: "")
            views.setTextViewText(forecastRangeIds[index], range ?: "")
            views.setImageViewResource(forecastIconIds[index], weatherIcon(icon))
            views.setViewVisibility(
                forecastColumnIds[index],
                if (label.isNullOrBlank()) View.INVISIBLE else View.VISIBLE,
            )
        }
        views.setViewVisibility(
            R.id.forecast_row,
            if (hasForecast) View.VISIBLE else View.GONE,
        )
    }

    private fun displayOrDash(value: String?): String {
        return if (value.isNullOrBlank() || value == "—") "—" else value
    }

    private fun weatherIcon(key: String?): Int {
        return when (key) {
            "clear" -> R.drawable.ic_widget_wx_clear
            "partlyCloudy" -> R.drawable.ic_widget_wx_partly_cloudy
            "cloudy" -> R.drawable.ic_widget_wx_cloudy
            "fog" -> R.drawable.ic_widget_wx_fog
            "drizzle" -> R.drawable.ic_widget_wx_drizzle
            "rain" -> R.drawable.ic_widget_wx_rain
            "snow" -> R.drawable.ic_widget_wx_snow
            "thunderstorm" -> R.drawable.ic_widget_wx_thunderstorm
            else -> R.drawable.ic_widget_wx_clear
        }
    }

    private val sharedClickableIds = intArrayOf(
        R.id.widget_root,
        R.id.room_temp_value,
        R.id.room_temp_unit,
        R.id.room_temp_label,
        R.id.source_label,
        R.id.outside_temp_value,
        R.id.outside_temp_label,
        R.id.updated_at_value,
        R.id.location_row,
        R.id.location_label,
        R.id.location_pin,
    )

    private val dashboardClickableIds = intArrayOf(
        R.id.header_row,
        R.id.date_label,
        R.id.condition_row,
        R.id.condition_label,
        R.id.condition_icon,
        R.id.stats_row,
        R.id.feels_like_value,
        R.id.humidity_value,
        R.id.wind_value,
        R.id.uv_value,
        R.id.forecast_row,
        R.id.forecast_0,
        R.id.forecast_1,
        R.id.forecast_2,
        R.id.forecast_3,
    )

    private val forecastColumnIds = intArrayOf(
        R.id.forecast_0,
        R.id.forecast_1,
        R.id.forecast_2,
        R.id.forecast_3,
    )
    private val forecastLabelIds = intArrayOf(
        R.id.forecast_0_label,
        R.id.forecast_1_label,
        R.id.forecast_2_label,
        R.id.forecast_3_label,
    )
    private val forecastIconIds = intArrayOf(
        R.id.forecast_0_icon,
        R.id.forecast_1_icon,
        R.id.forecast_2_icon,
        R.id.forecast_3_icon,
    )
    private val forecastRangeIds = intArrayOf(
        R.id.forecast_0_range,
        R.id.forecast_1_range,
        R.id.forecast_2_range,
        R.id.forecast_3_range,
    )

    private fun bindLaunchApp(
        context: Context,
        views: RemoteViews,
        widgetId: Int,
        clickableIds: List<Int>,
    ) {
        val pendingIntent = launchAppPendingIntent(context, widgetId)
        for (id in clickableIds) {
            views.setOnClickPendingIntent(id, pendingIntent)
        }
    }

    private fun launchAppPendingIntent(
        context: Context,
        widgetId: Int,
    ): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(
            context.packageName,
        ) ?: Intent(context, MainActivity::class.java)
        intent.action = Intent.ACTION_MAIN
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        intent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP,
        )

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val options = ActivityOptions.makeBasic()
            if (Build.VERSION.SDK_INT >= 35) {
                options.setPendingIntentCreatorBackgroundActivityStartMode(
                    ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED,
                )
            } else {
                @Suppress("DEPRECATION")
                options.pendingIntentBackgroundActivityStartMode =
                    ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
            }
            return PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                flags,
                options.toBundle(),
            )
        }

        return PendingIntent.getActivity(context, widgetId, intent, flags)
    }

    fun layoutForHost(
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        homeLayout: Int,
        lockLayout: Int,
    ): Int {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val category = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_HOST_CATEGORY,
            AppWidgetProviderInfo.WIDGET_CATEGORY_HOME_SCREEN,
        )
        if (category == AppWidgetProviderInfo.WIDGET_CATEGORY_KEYGUARD) {
            return lockLayout
        }

        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, Int.MAX_VALUE)
        val minHeight = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
            Int.MAX_VALUE,
        )
        if (minWidth in 1 until COMPACT_MIN_WIDTH_DP ||
            minHeight in 1 until COMPACT_MIN_HEIGHT_DP
        ) {
            return lockLayout
        }

        return homeLayout
    }
}
