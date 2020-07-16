package rekab.app.background_locator

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.view.FlutterMain

class LocatorBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        FlutterMain.ensureInitializationComplete(context, null)
        LocatorService.enqueueWork(context, intent)
    }
}