package com.comma.room_temperature

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Compact widget intended for the lock screen (keyguard) picker. Also
 * addable as a 2x1 home-screen widget.
 */
class RoomTempLockWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views: RemoteViews = RoomTempWidgetViews.build(
                context = context,
                layoutId = R.layout.room_temp_lock_widget,
                widgetData = widgetData,
                widgetId = widgetId,
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
