package com.comma.room_temperature

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget. Picks a layout from the actual min width/height
 * reported by the launcher after each resize.
 */
class RoomTempWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val layoutId = RoomTempWidgetViews.layoutForMain(
                    appWidgetManager = appWidgetManager,
                    widgetId = widgetId,
                )
                val views: RemoteViews = RoomTempWidgetViews.build(
                    context = context,
                    layoutId = layoutId,
                    widgetData = widgetData,
                    widgetId = widgetId,
                    size = RoomTempWidgetViews.sizeFor(appWidgetManager, widgetId),
                )
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (error: Exception) {
                android.util.Log.e("RoomTempWidget", "Failed to bind widget $widgetId", error)
            }
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
