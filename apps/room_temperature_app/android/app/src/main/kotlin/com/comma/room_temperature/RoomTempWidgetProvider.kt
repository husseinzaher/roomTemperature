package com.comma.room_temperature

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget. Uses the large glass card on the launcher and the
 * compact layout when hosted on the lock screen (keyguard) or resized small.
 */
class RoomTempWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val layoutId = RoomTempWidgetViews.layoutForHost(
                appWidgetManager = appWidgetManager,
                widgetId = widgetId,
                homeLayout = R.layout.room_temp_widget,
                lockLayout = R.layout.room_temp_lock_widget,
            )
            val views: RemoteViews = RoomTempWidgetViews.build(
                context = context,
                layoutId = layoutId,
                widgetData = widgetData,
                widgetId = widgetId,
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }
}
