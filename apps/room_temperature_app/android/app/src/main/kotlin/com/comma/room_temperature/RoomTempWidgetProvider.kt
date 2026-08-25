package com.comma.room_temperature

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders the home-screen widget from the data [HomeWidgetBridge] (Dart
 * side, in `shared/home_widget_bridge`) saves via `HomeWidget.saveWidgetData`:
 * `room_temp_c`, `outside_temp_c`, `updated_at_label`, `threshold_breached`.
 */
class RoomTempWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.room_temp_widget)

            val roomTemp = widgetData.getString("room_temp_c", null)
            val outsideTemp = widgetData.getString("outside_temp_c", null)
            val updatedAt = widgetData.getString("updated_at_label", null)
            val breached = widgetData.getBoolean("threshold_breached", false)

            views.setTextViewText(
                R.id.room_temp_value,
                if (roomTemp != null) "$roomTemp°" else "--",
            )
            views.setTextViewText(
                R.id.outside_temp_value,
                if (outsideTemp != null) "$outsideTemp°" else "--",
            )
            views.setTextViewText(
                R.id.updated_at_value,
                if (updatedAt != null) context.getString(R.string.widget_updated_at, updatedAt) else "",
            )

            val alertColor = if (breached) R.color.widget_alert else R.color.widget_normal
            views.setTextColor(R.id.room_temp_value, context.getColor(alertColor))

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
