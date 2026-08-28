package com.comma.room_temperature

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Dedicated 5-day outdoor forecast widget. */
class RoomTempForecastWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val size = RoomTempWidgetViews.sizeFor(appWidgetManager, widgetId)
            val views: RemoteViews = RoomTempWidgetViews.build(
                context = context,
                layoutId = R.layout.room_temp_forecast_widget,
                widgetData = widgetData,
                widgetId = widgetId,
                size = size,
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
