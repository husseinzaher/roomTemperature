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
    private const val COMPACT_MIN_WIDTH_DP = 180

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

        bindLaunchApp(context, views, widgetId)

        return views
    }

    /**
     * App-widget taps do not bubble: a click on a child TextView never
     * reaches the root. Attach the same launch intent to every surface so
     * tapping anywhere on the card opens the app.
     */
    private fun bindLaunchApp(
        context: Context,
        views: RemoteViews,
        widgetId: Int,
    ) {
        val pendingIntent = launchAppPendingIntent(context, widgetId)
        val clickableIds = intArrayOf(
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
        if (minWidth in 1 until COMPACT_MIN_WIDTH_DP) {
            return lockLayout
        }

        return homeLayout
    }
}
