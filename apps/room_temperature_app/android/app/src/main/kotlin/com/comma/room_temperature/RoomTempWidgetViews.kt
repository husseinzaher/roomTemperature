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
 * Binds shared widget prefs onto home-screen [RemoteViews] layouts.
 *
 * Size classes match Dart [WidgetLayoutClassifier]: very small / small /
 * medium / large from [AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH] and
 * [AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT], not launcher cell counts.
 */
object RoomTempWidgetViews {
    private const val ROOM_TEMP_KEY = "room_temp"
    private const val OUTSIDE_TEMP_KEY = "outside_temp"
    private const val LEGACY_ROOM_TEMP_KEY = "room_temp_c"
    private const val LEGACY_OUTSIDE_TEMP_KEY = "outside_temp_c"
    private const val UNIT_SYMBOL_KEY = "unit_symbol"
    private const val SOURCE_LABEL_KEY = "source_label"
    private const val UPDATED_AT_KEY = "updated_at_label"
    private const val CLOCK_KEY = "clock_label"
    private const val THRESHOLD_BREACHED_KEY = "threshold_breached"
    private const val LOCATION_LABEL_KEY = "location_label"
    private const val DATE_LABEL_KEY = "date_label"
    private const val SHORT_DATE_LABEL_KEY = "short_date_label"
    private const val CONDITION_LABEL_KEY = "condition_label"
    private const val CONDITION_ICON_KEY = "condition_icon"
    private const val FEELS_LIKE_KEY = "feels_like_label"
    private const val HUMIDITY_KEY = "humidity_label"
    private const val WIND_KEY = "wind_label"
    private const val UV_KEY = "uv_label"
    private const val PLACE_NAME_KEY = "place_name"
    private const val PLACE_AVERAGE_KEY = "place_average_label"

    const val VERY_SMALL_MAX_WIDTH_DP = 110
    const val VERY_SMALL_MAX_HEIGHT_DP = 55
    const val SMALL_MAX_WIDTH_DP = 180
    const val SMALL_MAX_HEIGHT_DP = 110
    const val MEDIUM_MAX_WIDTH_DP = 250
    const val MEDIUM_MAX_HEIGHT_DP = 180

    enum class Size {
        VERY_SMALL,
        SMALL,
        MEDIUM,
        LARGE,
    }

    fun classify(minWidthDp: Int, minHeightDp: Int): Size {
        if (minWidthDp < VERY_SMALL_MAX_WIDTH_DP ||
            minHeightDp < VERY_SMALL_MAX_HEIGHT_DP
        ) {
            return Size.VERY_SMALL
        }
        if (minWidthDp < SMALL_MAX_WIDTH_DP || minHeightDp < SMALL_MAX_HEIGHT_DP) {
            return Size.SMALL
        }
        if (minWidthDp < MEDIUM_MAX_WIDTH_DP ||
            minHeightDp < MEDIUM_MAX_HEIGHT_DP
        ) {
            return Size.MEDIUM
        }
        return Size.LARGE
    }

    fun sizeFor(appWidgetManager: AppWidgetManager, widgetId: Int): Size {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, Int.MAX_VALUE)
        val minHeight = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
            Int.MAX_VALUE,
        )
        return classify(minWidth, minHeight)
    }

    fun layoutForMain(
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
    ): Int {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val category = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_HOST_CATEGORY,
            AppWidgetProviderInfo.WIDGET_CATEGORY_HOME_SCREEN,
        )
        if (category == AppWidgetProviderInfo.WIDGET_CATEGORY_KEYGUARD) {
            return R.layout.room_temp_lock_widget
        }
        return when (sizeFor(appWidgetManager, widgetId)) {
            Size.VERY_SMALL -> R.layout.room_temp_widget_xs
            Size.SMALL -> R.layout.room_temp_widget_sm
            Size.MEDIUM -> R.layout.room_temp_widget_md
            Size.LARGE -> R.layout.room_temp_widget
        }
    }

    fun build(
        context: Context,
        layoutId: Int,
        widgetData: SharedPreferences,
        widgetId: Int,
        size: Size = Size.LARGE,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, layoutId)
        when (layoutId) {
            R.layout.room_temp_forecast_widget -> bindForecastWidget(
                context,
                views,
                widgetData,
                size,
            )
            R.layout.room_temp_places_widget -> bindPlacesWidget(
                context,
                views,
                widgetData,
                size,
            )
            else -> {
                bindCoreTemps(context, views, widgetData)
                when (layoutId) {
                    R.layout.room_temp_widget -> bindLarge(views, widgetData)
                    R.layout.room_temp_widget_md -> bindMedium(views, widgetData)
                    R.layout.room_temp_widget_sm -> bindSmall(views, widgetData)
                }
            }
        }
        bindLaunchApp(context, views, widgetId, intArrayOf(R.id.widget_root))
        return views
    }

    private fun bindCoreTemps(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
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
    }

    private fun bindLarge(
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        val unit = widgetData.getString(UNIT_SYMBOL_KEY, "°C") ?: "°C"
        val outsideTemp = widgetData.getString(OUTSIDE_TEMP_KEY, null)
            ?: widgetData.getString(LEGACY_OUTSIDE_TEMP_KEY, null)
        val clock = widgetData.getString(CLOCK_KEY, null)
            ?: widgetData.getString(UPDATED_AT_KEY, "")
        views.setTextViewText(R.id.time_label, clock ?: "")
        views.setTextViewText(
            R.id.short_date_label,
            widgetData.getString(SHORT_DATE_LABEL_KEY, "") ?: "",
        )
        views.setTextViewText(
            R.id.date_label,
            widgetData.getString(DATE_LABEL_KEY, "") ?: "",
        )
        views.setTextViewText(
            R.id.header_outside_temp,
            if (outsideTemp != null) "$outsideTemp$unit" else "—",
        )

        bindCondition(views, widgetData)
        val icon = weatherIcon(widgetData.getString(CONDITION_ICON_KEY, null))
        views.setImageViewResource(R.id.hero_condition_icon, icon)
        val condition = widgetData.getString(CONDITION_LABEL_KEY, null)
        views.setTextViewText(R.id.hero_condition_label, condition ?: "")

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

        bindForecastColumns(
            views,
            widgetData,
            visibleCount = 5,
            existingColumns = 5,
            withIcons = true,
        )

        val placeName = widgetData.getString(PLACE_NAME_KEY, null)
        val placeAvg = widgetData.getString(PLACE_AVERAGE_KEY, null)
        if (placeName.isNullOrBlank()) {
            views.setViewVisibility(R.id.place_row, View.GONE)
        } else {
            views.setViewVisibility(R.id.place_row, View.VISIBLE)
            views.setTextViewText(R.id.place_name, placeName)
            views.setTextViewText(R.id.place_average, placeAvg ?: "")
        }
    }

    private fun bindMedium(
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        val clock = widgetData.getString(CLOCK_KEY, null)
            ?: widgetData.getString(UPDATED_AT_KEY, "")
        views.setTextViewText(R.id.time_label, clock ?: "")
        bindCondition(views, widgetData)
        bindForecastColumns(
            views,
            widgetData,
            visibleCount = 2,
            existingColumns = 2,
            withIcons = false,
        )
    }

    private fun bindSmall(views: RemoteViews, widgetData: SharedPreferences) {
        bindCondition(views, widgetData)
    }

    private fun bindForecastWidget(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
        size: Size,
    ) {
        val count = when (size) {
            Size.VERY_SMALL -> 1
            Size.SMALL, Size.MEDIUM -> 2
            Size.LARGE -> 5
        }
        bindForecastColumns(
            views,
            widgetData,
            visibleCount = count,
            existingColumns = 5,
            withIcons = true,
        )
        if (size == Size.VERY_SMALL) {
            val high = widgetData.getString("forecast_0_high", null)
            if (!high.isNullOrBlank()) {
                views.setTextViewText(R.id.forecast_0_range, high)
            }
        }
        val updatedAt = widgetData.getString(UPDATED_AT_KEY, null)
        views.setTextViewText(
            R.id.updated_at_value,
            if (updatedAt != null) {
                context.getString(R.string.widget_updated_at, updatedAt)
            } else {
                ""
            },
        )
    }

    private fun bindPlacesWidget(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
        size: Size,
    ) {
        val count = when (size) {
            Size.VERY_SMALL, Size.SMALL -> 1
            Size.MEDIUM -> 3
            Size.LARGE -> 5
        }
        val slotIds = intArrayOf(
            R.id.place_slot_0,
            R.id.place_slot_1,
            R.id.place_slot_2,
            R.id.place_slot_3,
            R.id.place_slot_4,
        )
        val nameIds = intArrayOf(
            R.id.place_0_name,
            R.id.place_1_name,
            R.id.place_2_name,
            R.id.place_3_name,
            R.id.place_4_name,
        )
        val tempIds = intArrayOf(
            R.id.place_0_temp,
            R.id.place_1_temp,
            R.id.place_2_temp,
            R.id.place_3_temp,
            R.id.place_4_temp,
        )
        val unit = widgetData.getString(UNIT_SYMBOL_KEY, "°C") ?: "°C"
        for (index in slotIds.indices) {
            val name = widgetData.getString("place_${index}_name", null)
            val show = index < count && !name.isNullOrBlank()
            views.setViewVisibility(slotIds[index], if (show) View.VISIBLE else View.GONE)
            if (!show) {
                continue
            }
            val temp = widgetData.getString("place_${index}_temp", null)
            views.setTextViewText(nameIds[index], name)
            views.setTextViewText(
                tempIds[index],
                if (temp.isNullOrBlank()) "—" else "$temp$unit",
            )
        }
        val subtitle = widgetData.getString("place_0_subtitle", null)
        if (size == Size.LARGE && !subtitle.isNullOrBlank()) {
            views.setViewVisibility(R.id.place_0_subtitle, View.VISIBLE)
            views.setTextViewText(R.id.place_0_subtitle, subtitle)
        } else {
            views.setViewVisibility(R.id.place_0_subtitle, View.GONE)
        }
        val updatedAt = widgetData.getString(UPDATED_AT_KEY, null)
        views.setTextViewText(
            R.id.updated_at_value,
            if (updatedAt != null) {
                context.getString(R.string.widget_updated_at, updatedAt)
            } else {
                ""
            },
        )
    }

    private fun bindCondition(views: RemoteViews, widgetData: SharedPreferences) {
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
    }

    private fun bindForecastColumns(
        views: RemoteViews,
        widgetData: SharedPreferences,
        visibleCount: Int,
        existingColumns: Int,
        withIcons: Boolean,
    ) {
        var hasForecast = false
        for (index in 0 until existingColumns) {
            val label = widgetData.getString("forecast_${index}_label", null)
            val range = widgetData.getString("forecast_${index}_range", null)
            val icon = widgetData.getString("forecast_${index}_icon", null)
            val show = index < visibleCount && !label.isNullOrBlank()
            if (show) {
                hasForecast = true
            }
            views.setTextViewText(forecastLabelIds[index], label ?: "")
            views.setTextViewText(forecastRangeIds[index], range ?: "")
            if (withIcons) {
                views.setImageViewResource(
                    forecastIconIds[index],
                    weatherIcon(icon),
                )
            }
            views.setViewVisibility(
                forecastColumnIds[index],
                if (show) View.VISIBLE else View.GONE,
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

    private val forecastColumnIds = intArrayOf(
        R.id.forecast_0,
        R.id.forecast_1,
        R.id.forecast_2,
        R.id.forecast_3,
        R.id.forecast_4,
    )
    private val forecastLabelIds = intArrayOf(
        R.id.forecast_0_label,
        R.id.forecast_1_label,
        R.id.forecast_2_label,
        R.id.forecast_3_label,
        R.id.forecast_4_label,
    )
    private val forecastIconIds = intArrayOf(
        R.id.forecast_0_icon,
        R.id.forecast_1_icon,
        R.id.forecast_2_icon,
        R.id.forecast_3_icon,
        R.id.forecast_4_icon,
    )
    private val forecastRangeIds = intArrayOf(
        R.id.forecast_0_range,
        R.id.forecast_1_range,
        R.id.forecast_2_range,
        R.id.forecast_3_range,
        R.id.forecast_4_range,
    )

    private fun bindLaunchApp(
        context: Context,
        views: RemoteViews,
        widgetId: Int,
        clickableIds: IntArray,
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
}
