package com.optracker.app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Android NotificationListenerService that captures incoming notifications.
 * The Flutter plugin (notification_listener_service) bridges this to Dart code.
 * This service declaration ensures Android registers us as a notification listener.
 */
class NotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        // Handled by the Flutter notification_listener_service plugin
        super.onNotificationPosted(sbn)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
