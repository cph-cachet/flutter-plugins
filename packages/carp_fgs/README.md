# foreground_service (Flutter v.1.12.x or later)

Create Android foreground service&#x2F;notification

## Prep (Android side):

    Android foreground services require a notification to be displayed,
    and notifications require an icon.

    For this plugin to work, the icon needs to be in this specific location:

    res/drawable/org_thebus_foregroundserviceplugin_notificationicon

    (take a look at the /example app if you're confused)


    -- NOTE FOR PLUGIN VERSION 2.0.0 and above --
    compileSdkVersion & targetSdkVersion need to be 29 or above, or the build will fail
    these values are set/can be changed in the build.gradle for the app

## Use (Flutter/Dart side):

    To start the service, call ForegroundService.startForegroundService([serviceFunction])

    serviceFunction will then be executed periodically, but "minimum/best-effort"
    i.e. it will try to make the interval between function executions *at least* that long

## Doesn't work?

    As long as you're calling ForegroundService.startForegroundService,
    "flutter run" should show error messages that indicate what's wrong/missing

    i.e. messages beginning with E/ForegroundServicePlugin indicate an error from the plugin

## Caution:

    ForegroundService.notification.get* methods may give unexpected values.

    Once notifications are sent out, there's no way to retrieve the "current" data.

    To work around this, the plugin keeps a version of the notification around.
    This version may not have been "sent out" yet, however.


Disclaimer:

Most of the fancy stuff is shamelessly pilfered from the android_alarm_manager plugin