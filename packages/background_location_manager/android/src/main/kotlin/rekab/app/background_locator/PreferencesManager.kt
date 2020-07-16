package rekab.app.background_locator

import android.content.Context

class PreferencesManager {
    companion object {
        private const val PREF_NAME = "background_locator"

        @JvmStatic
        fun saveCallbackDispatcher(context: Context, map: Map<Any, Any>) {
            val sharedPreferences =
                    context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

            sharedPreferences.edit()
                    .putLong(Keys.ARG_CALLBACK_DISPATCHER,
                            map[Keys.ARG_CALLBACK_DISPATCHER] as Long)
                    .apply()
        }

        @JvmStatic
        fun saveSettings(context: Context, map: Map<Any, Any>) {
            val sharedPreferences =
                    context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

            sharedPreferences.edit()
                    .putLong(Keys.ARG_CALLBACK,
                            map[Keys.ARG_CALLBACK] as Long)
                    .apply()

            if (map[Keys.ARG_NOTIFICATION_CALLBACK] as? Long != null) {
                sharedPreferences.edit()
                        .putLong(Keys.ARG_NOTIFICATION_CALLBACK,
                                map[Keys.ARG_NOTIFICATION_CALLBACK] as Long)
                        .apply()
            }

            val settings = map[Keys.ARG_SETTINGS] as Map<*, *>

            sharedPreferences.edit()
                    .putString(Keys.ARG_NOTIFICATION_CHANNEL_NAME,
                            settings[Keys.ARG_NOTIFICATION_CHANNEL_NAME] as String)
                    .apply()

            sharedPreferences.edit()
                    .putString(Keys.ARG_NOTIFICATION_TITLE,
                            settings[Keys.ARG_NOTIFICATION_TITLE] as String)
                    .apply()

            sharedPreferences.edit()
                    .putString(Keys.ARG_NOTIFICATION_MSG,
                            settings[Keys.ARG_NOTIFICATION_MSG] as String)
                    .apply()

            sharedPreferences.edit()
                    .putString(Keys.ARG_NOTIFICATION_ICON,
                            settings[Keys.ARG_NOTIFICATION_ICON] as String)
                    .apply()

            sharedPreferences.edit()
                    .putLong(Keys.ARG_NOTIFICATION_ICON_COLOR,
                            settings[Keys.ARG_NOTIFICATION_ICON_COLOR] as Long)
                    .apply()

            sharedPreferences.edit()
                    .putInt(Keys.ARG_INTERVAL,
                            settings[Keys.ARG_INTERVAL] as Int)
                    .apply()

            sharedPreferences.edit()
                    .putInt(Keys.ARG_ACCURACY,
                            settings[Keys.ARG_ACCURACY] as Int)
                    .apply()

            sharedPreferences.edit()
                    .putFloat(Keys.ARG_DISTANCE_FILTER,
                            (settings[Keys.ARG_DISTANCE_FILTER] as Double).toFloat())
                    .apply()

            if (settings.containsKey(Keys.ARG_WAKE_LOCK_TIME)) {
                sharedPreferences.edit()
                        .putInt(Keys.ARG_WAKE_LOCK_TIME,
                                settings[Keys.ARG_WAKE_LOCK_TIME] as Int)
                        .apply()
            }
        }

        @JvmStatic
        fun getSettings(context: Context): Map<Any, Any> {
            val sharedPreferences =
                    context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

            val result = HashMap<Any, Any>()

            result[Keys.ARG_CALLBACK_DISPATCHER] = sharedPreferences.getLong(Keys.ARG_CALLBACK_DISPATCHER, 0)
            result[Keys.ARG_CALLBACK] = sharedPreferences.getLong(Keys.ARG_CALLBACK, 0)

            if (sharedPreferences.contains(Keys.ARG_NOTIFICATION_CALLBACK)) {
                result[Keys.ARG_NOTIFICATION_CALLBACK] =
                        sharedPreferences.getLong(Keys.ARG_NOTIFICATION_CALLBACK, 0)
            }

            val settings = HashMap<String, Any?>()

            settings[Keys.ARG_NOTIFICATION_CHANNEL_NAME] =
                    sharedPreferences.getString(Keys.ARG_NOTIFICATION_CHANNEL_NAME, "")

            settings[Keys.ARG_NOTIFICATION_TITLE] =
                    sharedPreferences.getString(Keys.ARG_NOTIFICATION_TITLE, "")

            settings[Keys.ARG_NOTIFICATION_MSG] =
                    sharedPreferences.getString(Keys.ARG_NOTIFICATION_MSG, "")

            settings[Keys.ARG_NOTIFICATION_ICON] =
                    sharedPreferences.getString(Keys.ARG_NOTIFICATION_ICON, "")

            settings[Keys.ARG_NOTIFICATION_ICON_COLOR] =
                    sharedPreferences.getLong(Keys.ARG_NOTIFICATION_ICON_COLOR, 0)

            settings[Keys.ARG_INTERVAL] =
                    sharedPreferences.getInt(Keys.ARG_INTERVAL, 0)

            settings[Keys.ARG_ACCURACY] =
                    sharedPreferences.getInt(Keys.ARG_ACCURACY, 0)

            settings[Keys.ARG_DISTANCE_FILTER] =
                    sharedPreferences.getFloat(Keys.ARG_DISTANCE_FILTER, 0f).toDouble()

            if (sharedPreferences.contains(Keys.ARG_WAKE_LOCK_TIME)) {
                settings[Keys.ARG_WAKE_LOCK_TIME] = sharedPreferences.getInt(Keys.ARG_WAKE_LOCK_TIME, 0)
            }

            result[Keys.ARG_SETTINGS] = settings
            return result
        }

    }
}