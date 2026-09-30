package com.palnacare.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget. The app saves what to show (lib/features/home/
 * home_widget_sync.dart); times are epoch milliseconds as text. The clocks
 * are Chronometers, so "time since last feed" keeps counting with the app
 * closed.
 */
class PalnaWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.palna_widget)
            fill(views, widgetData)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun fill(views: RemoteViews, data: SharedPreferences) {
        views.setTextViewText(R.id.baby_name, data.getString("baby_name", null) ?: "Palna")

        val feedSince = millis(data, "feed_since")
        val hasBaby = data.getString("baby_name", null) != null
        if (!hasBaby) {
            views.setViewVisibility(R.id.empty, View.VISIBLE)
            views.setTextViewText(R.id.empty, data.getString("label_empty", null) ?: "Tap to open Palna")
        } else {
            views.setViewVisibility(R.id.empty, View.GONE)
        }

        if (feedSince != null) {
            views.setViewVisibility(R.id.feed_row, View.VISIBLE)
            views.setTextViewText(R.id.feed_label, data.getString("feed_label", "") ?: "")
            clock(views, R.id.feed_clock, feedSince)
            views.setTextViewText(R.id.feed_detail, data.getString("feed_detail", "") ?: "")
            views.setViewVisibility(R.id.feed_detail, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.feed_row, View.GONE)
            views.setViewVisibility(R.id.feed_detail, View.GONE)
        }

        val sleepSince = millis(data, "sleep_since")
        if (sleepSince != null) {
            views.setViewVisibility(R.id.sleep_row, View.VISIBLE)
            views.setTextViewText(R.id.sleep_label, data.getString("sleep_label", "") ?: "")
            clock(views, R.id.sleep_clock, sleepSince)
        } else {
            views.setViewVisibility(R.id.sleep_row, View.GONE)
        }

        val vaccine = data.getString("vaccine", null)
        if (vaccine.isNullOrEmpty()) {
            views.setViewVisibility(R.id.vaccine, View.GONE)
        } else {
            views.setViewVisibility(R.id.vaccine, View.VISIBLE)
            views.setTextViewText(R.id.vaccine, vaccine)
        }
    }

    /** A clock counting up from [sinceMillis] (wall-clock epoch time). */
    private fun clock(views: RemoteViews, viewId: Int, sinceMillis: Long) {
        val elapsed = (System.currentTimeMillis() - sinceMillis).coerceAtLeast(0)
        views.setChronometer(viewId, SystemClock.elapsedRealtime() - elapsed, null, true)
    }

    private fun millis(data: SharedPreferences, key: String): Long? =
        data.getString(key, null)?.toLongOrNull()
}
