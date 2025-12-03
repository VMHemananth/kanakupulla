package com.example.kanakupulla

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // Open App on Widget Click (Add Button)
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_add_btn, pendingIntent)

                // Update values
                val balance = widgetData.getString("balance", "₹0.00")
                setTextViewText(R.id.widget_balance, balance)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
