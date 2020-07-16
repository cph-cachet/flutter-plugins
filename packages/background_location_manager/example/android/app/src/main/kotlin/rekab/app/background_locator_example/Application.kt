package rekab.app.background_locator_example

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.view.FlutterMain
import rekab.app.background_locator.LocatorService

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        LocatorService.setPluginRegistrant(this)
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (!registry!!.hasPlugin("io.flutter.plugins.pathprovider")) {
            PathProviderPlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.pathprovider"))
        }
    }
}
