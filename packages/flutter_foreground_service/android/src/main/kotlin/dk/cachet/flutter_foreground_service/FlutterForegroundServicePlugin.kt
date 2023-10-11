package dk.cachet.flutter_foreground_service

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import org.json.JSONArray
import org.json.JSONObject
import java.lang.ref.SoftReference

class FlutterForegroundServicePlugin: FlutterPlugin, MethodCallHandler, IntentService("dk.cachet.ForegroundServicePlugin") {

  companion object {

    private const val LOG_TAG = "ForegroundServicePlugin"
    private const val WAKELOCK_TAG = "ForegroundServicePlugin::WakeLock"

    private const val INTENT_ACTION_START_SERVICE = "Start Service"
    private const val INTENT_ACTION_LOOP = "Loop"

    private var myApplicationContextRef: SoftReference<Context>? = null
    private fun myAppContext(): Context{

      //the idea is that all function calls
      //besides setApplicationContext and registerWith
      //are done from onMethodCall
      //which checks that the context reference points to a context
      //but check anyways, and throw an explicit exception just in case
      return myApplicationContextRef?.get()
              ?: throw Exception("ForegroundServicePlugin application context was null")
    }

    private var shouldWakeLock: Boolean = false
    private var hasWakeLock: Boolean = false
    private lateinit var myWakeLock: PowerManager.WakeLock

    //put this in the companion object so doCallback can use it later

    private var mainChannel: MethodChannel? = null
    private var callbackChannel: MethodChannel? = null
    private var fromBackgroundIsolateChannel: MethodChannel? = null
    private fun doCallback(callbackHandle: Long){
      //TODO: investigate if this is actually the right way to "fix" this
      Handler(Looper.getMainLooper()).post{
        callbackChannel?.invokeMethod("callback", arrayOf(callbackHandle))
      }
    }


    //V1 android embedding uses registerWith
    //V2 uses FlutterPlugin.onAttachedToEngine
    private var isV1FlutterEmbedding = false

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      isV1FlutterEmbedding = true
      initForegroundServicePlugin(registrar.context(), registrar.messenger())
    }

    //apparently onAttachedToEngine gets called when new instance of plugin is made
    //set flag so init only executes once
    private var isForegroundServicePluginInit = false
    private val fgsPluginInstance by lazy{
      FlutterForegroundServicePlugin()
    }

    private fun initForegroundServicePlugin(applicationContext: Context, fromDartMessenger: BinaryMessenger){

      if(!isForegroundServicePluginInit) {

        isForegroundServicePluginInit = true

        myApplicationContextRef = SoftReference(applicationContext)

        mainChannel = MethodChannel(fromDartMessenger, "dk.cachet.flutter_foreground_service/main", JSONMethodCodec.INSTANCE)
        mainChannel!!.setMethodCallHandler(fgsPluginInstance)

        callbackChannel =
                MethodChannel(flutterEngine.dartExecutor, "dk.cachet.flutter_foreground_service/callback", JSONMethodCodec.INSTANCE)

        fromBackgroundIsolateChannel = MethodChannel(flutterEngine.dartExecutor, "dk.cachet.flutter_foreground_service/fromBackgroundIsolate", JSONMethodCodec.INSTANCE)
        fromBackgroundIsolateChannel!!.setMethodCallHandler(fgsPluginInstance)
      }
    }

    private fun logDebug(debugMessage: String){
      Log.d(LOG_TAG, debugMessage)
    }
    private fun logError(errorMessage: String){
      Log.e(LOG_TAG, errorMessage)
    }
    fun Result.simpleError(errorMessage: String?){
      this.error(LOG_TAG,errorMessage,null)
    }

    //instances of the service can come and go
    //but we want the notification data to persist
    private val notificationHelper = NotificationHelper()

    //this is used to let the service execute dart handles
    val flutterEngine: FlutterEngine by lazy{
      FlutterEngine(myAppContext())
    }

    //allows android application to register with the flutter plugin registry
    var sPluginRegistrantCallback: PluginRegistry.PluginRegistrantCallback? = null


    //FlutterApplication subclass needs to call this
    //in order to let the plugin call registerWith
    //which should in turn call GeneratedPluginRegistrant.registerWith
    //which apparently does some voodoo magic that lets this whole thing work
    fun setPluginRegistrantCallback(theCallback: PluginRegistry.PluginRegistrantCallback){
      sPluginRegistrantCallback = theCallback
    }

    private var dartServiceFunctionHandle: Long? = null
    private var serviceFunctionIntervalSeconds: Long = 5
    private var serviceFunctionLastExecuted: DateHelper? = null
    private var serviceFunctionPendingCallbackCount: Int = 0
    private var serviceIsStarted: Boolean = false

    private var isBackgroundIsolateSetupComplete: Boolean = false

    private var continueRunningAfterAppKilled: Boolean = true
    private var isServiceFunctionAsync: Boolean = true
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    //use a variable because it seemed like there was a lot of
    //result.success(true) cluttering everything up
    //so this way there will only be a single call to result.success(methodCallResult) at the end
    var methodCallResult: Any? = true

    if(myApplicationContextRef?.get() != null) {

      try {
        when (call.method) {

          //------------------------------

          "startForegroundService" -> {
              launchService()

              val callbackHandle = (call.arguments as JSONArray).getLong(0)
              shouldWakeLock = (call.arguments as JSONArray).getBoolean(1)
              setupCallback(myAppContext(), callbackHandle)
          }

          "stopForegroundService" -> {
            notificationHelper.serviceIsForegrounded = false
            serviceIsStarted = false
            maybeReleaseWakeLock()
            stopSelf()
          }

          "foregroundServiceIsStarted" ->
            methodCallResult = serviceIsStarted

          //------------------------------

          "getServiceFunctionHandle" ->
            methodCallResult = dartServiceFunctionHandle

          "setServiceFunctionHandle" ->
              dartServiceFunctionHandle = (call.arguments as JSONArray).getLong(0)

          //------------------------------

          "getServiceFunctionInterval" ->
            methodCallResult = serviceFunctionIntervalSeconds

          "setServiceFunctionInterval" ->
              serviceFunctionIntervalSeconds = (call.arguments as JSONArray).getLong(0)

          //------------------------------

          "getNotificationPriority" ->
            methodCallResult =  notificationHelper.priorityOrImportance.name

          "setNotificationPriority" ->
            notificationHelper.priorityOrImportance =
                    AndroidNotifiationPriority.fromString(
                            (call.arguments as JSONArray).getString(0)
                    )
          //------------------------------

          "getNotificationTitle" ->
            methodCallResult = notificationHelper.contentTitle

          "setNotificationTitle" ->
            notificationHelper.contentTitle = (call.arguments as JSONArray).getString(0)

          //------------------------------

          "getNotificationText" ->
            methodCallResult = notificationHelper.contentText

          "setNotificationText" ->
            notificationHelper.contentText = (call.arguments as JSONArray).getString(0)

          //------------------------------

          "startEditNotification"->
            notificationHelper.editModeEnabled = true

          "finishEditNotification"->
            notificationHelper.editModeEnabled = false

          //------------------------------

          "getWakeLock"-> {
            shouldWakeLock = true
            maybeGetWakeLock()
          }

          "releaseWakeLock"->{
            maybeReleaseWakeLock()
          }

          //------------------------------

          "getContinueRunningAfterAppKilled"-> {
            methodCallResult = continueRunningAfterAppKilled
          }

          "setContinueRunningAfterAppKilled"-> {
            continueRunningAfterAppKilled = (call.arguments as JSONArray).getBoolean(0)
          }

          //------------------------------

          "fromBackgroundIsolate"-> {

            //method call is being passed through from background isolate
            //because ex. the dart side foreground service function is calling ForegroundService.notification.setTitle

            //pick up the method call details from the background isolate's message
            val methodName = (call.arguments as JSONObject).getString("method")
            val methodArguments = (call.arguments as JSONObject).get("arguments")

            //construct a new method call with the bare details
            val passThroughCall = MethodCall(methodName, methodArguments)

            //and then re-handle it
            this.onMethodCall(passThroughCall, result)

            //set to null so that result.success will not be called twice
            methodCallResult = null
          }

          //------------------------------

          "backgroundIsolateSetupComplete"-> {
            isBackgroundIsolateSetupComplete = true
          }

          "isBackgroundIsolateSetupComplete"-> {
            methodCallResult = isBackgroundIsolateSetupComplete
          }

          //------------------------------

          "backgroundIsolateCallbackComplete"-> {
            serviceFunctionPendingCallbackCount -= 1
          }

          //------------------------------

          "getServiceFunctionAsync"-> {
            methodCallResult = isServiceFunctionAsync
          }

          "setServiceFunctionAsync"-> {
            isServiceFunctionAsync = (call.arguments as JSONArray).getBoolean(0)
          }

          //------------------------------

          else -> {
            methodCallResult = null
            result.notImplemented()
          }
        }

        if(methodCallResult != null){result.success(methodCallResult)}

      }catch(e: Exception){
        //expecting this to catch errors like the icon file for the notification not existing
        //which should have a semi-descriptive message attached
        result.simpleError(e.message)
      }
    }else{
      result.simpleError(
              "Application context is null.  " +
                "Did you call ForegroundServicePlugin.setPluginRegistrantCallback?"
      )
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    initForegroundServicePlugin(binding.applicationContext, binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    //method channels, etc. will need to be reinitialized on being reattached to the engine
    isForegroundServicePluginInit = false

    //this function is called ex. when the app is killed by being slid off of the recent apps list
    //change from dart side by calling setContinueRunningAfterAppKilled
    if(!continueRunningAfterAppKilled) {
      myApplicationContextRef = null

      mainChannel?.setMethodCallHandler(null)
      mainChannel = null

      callbackChannel?.setMethodCallHandler(null)
      callbackChannel = null

      serviceIsStarted = false
      isForegroundServicePluginInit = false
    }
  }

  //starting point to launch self as a foreground service
  //after the service is started, onHandleIntent does the foregrounding stuff
  private fun launchService(){
    try {

      val startServiceIntent = Intent(myAppContext(), FlutterForegroundServicePlugin::class.java)
      startServiceIntent.action = INTENT_ACTION_START_SERVICE

      if (thisCanReceiveIntent(startServiceIntent)) {
        if(notificationHelper.hardcodedIconIsAvailable()) {
          //starting with O, have to startForegroundService instead of just startService
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            myAppContext().startForegroundService(startServiceIntent)
          } else {
            myAppContext().startService(startServiceIntent)
          }
        }else{
          logError(notificationHelper.hardCodedIconNotFoundErrorMessage)
        }
      }
      else {
        logError(
                "Service cannot be started.  " +
                        "Did you register ForegroundServicePlugin as a service in your android manifest?"
        )
      }

    }catch(e: Exception){
      logError("unexpected ${e::class} caught while launching service: ${e.message}")
    }
  }

  //this sets up a background isolate for executing flutter/dart code
  private fun setupCallback(callbackContext: Context, callbackHandle: Long){

    FlutterMain.ensureInitializationComplete(callbackContext, null)

    if(!flutterEngine.dartExecutor.isExecutingDart) {
      flutterEngine.dartExecutor.executeDartCallback(
              DartExecutor.DartCallback(
                      callbackContext.assets,
                      FlutterMain.findAppBundlePath(),
                      FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
              )
      )
    }

    if(isV1FlutterEmbedding){
      try {
        sPluginRegistrantCallback!!.registerWith(ShimPluginRegistry(flutterEngine))
      } catch (e: Exception) {
        logError("Could not register plugin callback.  " +
                "Did you call ForegroundServicePlugin.setPluginRegistrantCallback?")
      }
    }
  }

  override fun onHandleIntent(p0: Intent?) {
    try {
      when(p0?.action){
        INTENT_ACTION_START_SERVICE -> {
          logDebug("started service, making foreground")

          if(tryStartForeground()) {
            logDebug("started foreground notification, entering service loop")
            notificationHelper.serviceIsForegrounded = true
            serviceIsStarted = true
            maybeGetWakeLock()
            serviceLoop()
          }
        }

        INTENT_ACTION_LOOP ->
          serviceLoop()

        else ->
          logError("received unexpected intent ${p0?.action}")
      }
    }catch(e: Exception){
      logError( "unexpected error while handling intent: ${e.message}")
    }
  }

  private fun maybeGetWakeLock(){
    if(shouldWakeLock && !hasWakeLock) {
      myWakeLock = (myAppContext().getSystemService(Context.POWER_SERVICE) as PowerManager)
              .run {
                newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG).apply {
                  acquire()
                }
              }
      hasWakeLock = true
    }
  }
  private fun maybeReleaseWakeLock(){
    if(shouldWakeLock && hasWakeLock) {
      myWakeLock.release()
      hasWakeLock = false
    }
  }

  private fun tryStartForeground(): Boolean =(
    try {
      startForeground(notificationHelper.notificationId, notificationHelper.currentNotification)
      true
    }catch(e: Exception){
      logError("error while launching foreground service: ${e.message}")
      false
    }
  )

  //kludge to keep IntentService notification up
  //IntentService will only stay alive so long as there's work pending
  //just keep sending intents to keep this alive
  //TODO: find a better way to do this...
  private fun serviceLoop(){

    if(serviceIsStarted) {
      if ((dartServiceFunctionHandle != null) && isBackgroundIsolateSetupComplete){
        if (
          (
                (serviceFunctionLastExecuted?.secondsUntil(DateHelper())) ?: serviceFunctionIntervalSeconds + 1
                >
                serviceFunctionIntervalSeconds
          )
          &&
          (isServiceFunctionAsync || (serviceFunctionPendingCallbackCount == 0))
        ) {
          serviceFunctionPendingCallbackCount += 1
          doCallback(dartServiceFunctionHandle!!)
          serviceFunctionLastExecuted = DateHelper()
        }
      }

      val loopIntent = Intent(myAppContext(), FlutterForegroundServicePlugin::class.java)
      loopIntent.action = INTENT_ACTION_LOOP

      myAppContext().startService(loopIntent)
    }
  }

  private fun thisCanReceiveIntent(serviceIntent: Intent): Boolean{

    for(queryResult in (myAppContext().packageManager.queryIntentServices(serviceIntent, 0))){

      if(
        (queryResult.serviceInfo.name == this::class.java.name)
        &&
        (queryResult.serviceInfo.packageName == myAppContext().packageName)
      ){
        return true
      }
    }

    return false
  }

  //notificationId = arbitrary id for the notification that this builds
  //should NOT be 0
  class NotificationHelper(val notificationId: Int = 1){

    //things that MUST be set for a notification to function property (probably)

    //setContentTitle
    //setContentText
    //setSmallIcon

    //blech workaround for not being able to upgrade notification channel priority
    //just make the channels in advance and switch between them
    //of course this breaks if the user goes into the settings and lowers the priority
    //it feels like trying to work around that situation strays into malware territory though
    //so just leave it like this
    //TODO: is there a better way?
    private val channelHighImportanceId = "dk.cachet.foregroundserviceplugin.notification.priorityhigh"
    private var channelHighImportanceName = "High Priority Notifications"

    private val channelDefaultImportanceId = "dk.cachet.foregroundserviceplugin.notification.prioritydefault"
    private var channelDefaultImportanceName = "Default Priority Notifications"

    private val channelLowImportanceId = "dk.cachet.foregroundserviceplugin.notification.prioritylow"
    private var channelLowImportanceName = "Low Priority Notifications"

    private fun getChannelIdForImportance(importanceEnum: AndroidNotifiationPriority): String =(
            when(importanceEnum){
              AndroidNotifiationPriority.LOW -> channelLowImportanceId
              AndroidNotifiationPriority.DEFAULT -> channelDefaultImportanceId
              AndroidNotifiationPriority.HIGH -> channelHighImportanceId
            }
            )

    //TODO: is this variable necessary?
    private var currentNotificationInternal: Notification? = null
    val currentNotification: Notification
      get(){
        if(currentNotificationInternal == null){
          currentNotificationInternal = builder.build()
        }
        return currentNotificationInternal!!
      }

    //convenience
    private val notificationManager: NotificationManager
    get(){
      return myAppContext().getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    //"edit mode" to not rebuild/renotify with every single change
    var editModeEnabled = false
    set(value) {
      field = value
      if(!field){
        //exiting editMode
        maybeUpdateNotification()
      }
    }

    //when updating the notification
    //don't want to notify yet if the service is not started
    //so don't notify until this flag is set
    var serviceIsForegrounded = false
    private fun maybeUpdateNotification(){
      if(!editModeEnabled) {
        currentNotificationInternal = builder.build()
      }
    }

    //due to how NotificationCompat.builder.setSmallIcon works
    //you can only use built-in stuff, instead of being able to incorporate things at run-time
    //doesn't seem like there's much point in exposing it
    //so just hardcode the expected icon location
    private val hardcodedIconName = "ic_launcher"

    private fun getHardcodedIconResourceId(): Int =
      myAppContext().resources.getIdentifier(
              hardcodedIconName,
              "mipmap",
              myAppContext().packageName
      )

    private fun iconResourceIdIsValid(someResourceId: Int): Boolean = someResourceId != 0
    fun hardcodedIconIsAvailable(): Boolean = iconResourceIdIsValid(getHardcodedIconResourceId())
    val hardCodedIconNotFoundErrorMessage = "could not find /res/drawable/$hardcodedIconName;" +
            " running a foreground service requires a notification," +
            " and a notification requires an icon"

    //whew, this is ugly
    //basically all the init/default stuff is shoved in here
    //TODO: can this be better?
    private val builder: NotificationCompat.Builder by lazy{

      val newBuilder = NotificationCompat.Builder(myAppContext(), channelDefaultImportanceId)

      try {

        newBuilder
                .setContentTitle("Foreground Service")
                .setContentText("Running")
                .setOngoing(true)
                .setOnlyAlertOnce(false)
                .setSmallIcon(getHardcodedIconResourceId())

        //the "normal" setPriority method will try to rebuild/renotify
        //which of course isn't going to end well since the builder hasn't been set yet
        setPriorityOrImportanceInternal(newBuilder,AndroidNotifiationPriority.DEFAULT)

        //the channel needs to be created yourself starting with O
        //importance can only be downgraded, not upgraded
        //so create all three channels right off the bat
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

          //TODO: better way of making sure all channels are created?
          notificationManager.createNotificationChannel(NotificationChannel(
                  channelHighImportanceId,
                  channelHighImportanceName,
                  AndroidNotifiationPriority.HIGH.toImportanceOrPriorityInt()
          ))

          notificationManager.createNotificationChannel(NotificationChannel(
                  channelDefaultImportanceId,
                  channelDefaultImportanceName,
                  AndroidNotifiationPriority.DEFAULT.toImportanceOrPriorityInt()
          ))

          notificationManager.createNotificationChannel(NotificationChannel(
                  channelLowImportanceId,
                  channelLowImportanceName,
                  AndroidNotifiationPriority.LOW.toImportanceOrPriorityInt()
          ))
        }

      }catch(e: Exception){
        logError("error while creating notification builder: ${e.message}")
      }

      newBuilder
    }

    //this is a doozy, so do this in order to allow a default value to be set intially
    //without needing to duplicate code, or manually injecting the same builder everwhere
    private fun setPriorityOrImportanceInternal(
            someNotificationBuilder: NotificationCompat.Builder,
            newPriorityOrImportance: AndroidNotifiationPriority
    ){

      //the channel needs to be created yourself starting with O
      //will also update existing channel
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

        someNotificationBuilder.setChannelId(getChannelIdForImportance(newPriorityOrImportance))

      } else {
        //for versions below O, need set priority on the notification itself
        //instead of setting importance on the notification channel
        someNotificationBuilder.priority = newPriorityOrImportance.toImportanceOrPriorityInt()
      }
    }

    var priorityOrImportance: AndroidNotifiationPriority
      get(){
        //TODO: make safe?
        //be careful when using this
        //because if new possible priority/importance values are introduced in newer versions
        //the translation from int -> Enum will probably fail & throw an Exception
        //or maybe it will even just be flat-out wrong
        return(
          if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){

            AndroidNotifiationPriority.fromInt(
                    notificationManager.getNotificationChannel(
                            currentNotification.channelId
                    ).importance
            )
          }else{
            //complains about deprecation, but was only deprecated starting with O
            AndroidNotifiationPriority.fromInt(currentNotification.priority)
          }
        )
      }
      set(newPriorityOrImportance) {
        setPriorityOrImportanceInternal(builder, newPriorityOrImportance)
        maybeUpdateNotification()
      }

    private fun Notification.getExtraCompat(extrasKey: String): Any? =
      NotificationCompat.getExtras(this)?.get(extrasKey)

    var contentTitle: String
      get(){
        return currentNotification.getExtraCompat(NotificationCompat.EXTRA_TITLE) as String? ?: ""
      }
      set(newTitle){
        builder.setContentTitle(newTitle)
        maybeUpdateNotification()
      }

    var contentText: String
      get(){
        return currentNotification.getExtraCompat(NotificationCompat.EXTRA_TEXT) as String? ?: ""
      }
      set(newText){
        builder.setContentText(newText)
        maybeUpdateNotification()
      }
  }
}

//enum help class to match with the one on the dart side / translate to & from
enum class AndroidNotifiationPriority{
  LOW,
  DEFAULT,
  HIGH;

  //will select the appropriate int based on OS version
  //this int will also be used in different ways based on OS version
  //for O+, used to set the importance of the notification channel
  //for versions below O, used to set the priority of the notification itself
  fun toImportanceOrPriorityInt(): Int = (

    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      when (this) {
        LOW -> NotificationManager.IMPORTANCE_LOW
        DEFAULT -> NotificationManager.IMPORTANCE_DEFAULT
        HIGH -> NotificationManager.IMPORTANCE_HIGH
      }
    }else{
      when (this) {
        LOW -> NotificationCompat.PRIORITY_LOW
        DEFAULT -> NotificationCompat.PRIORITY_DEFAULT
        HIGH -> NotificationCompat.PRIORITY_HIGH
      }
    }
  )

  companion object{

    //input expected to be a string that's the result of
    //describeEnum(AndroidNotificationPriority) on the flutter/dart side
    //i.e. LOW, DEFAULT, or HIGH
    fun fromString(priorityString: String): AndroidNotifiationPriority = (
      when(priorityString){
        "LOW"->LOW
        "DEFAULT"->DEFAULT
        "HIGH"->HIGH

        //this should never happen unless something in the plugin is broken...
        //famous last words
        else->throw Exception("Unexpected android notification priority from dart: $priorityString")
      }
    )

    //TODO: user is able to set priority lower than we are able to set it
    //because foreground service notifications have a minimum priority/importance of LOW
    //so this needs to handle all possible priority/importance values
    //since effectively this will be taking user input
    //counterpart of toImportanceOrPriorityInt
    fun fromInt(priorityInt: Int): AndroidNotifiationPriority = (
      if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
        when(priorityInt){
          NotificationManager.IMPORTANCE_LOW -> LOW
          NotificationManager.IMPORTANCE_DEFAULT -> DEFAULT
          NotificationManager.IMPORTANCE_HIGH -> HIGH

          else -> throw Exception("Unexpected priority int (O+): $priorityInt")
        }
      }else{
        when(priorityInt){
          NotificationCompat.PRIORITY_LOW -> LOW
          NotificationCompat.PRIORITY_DEFAULT -> DEFAULT
          NotificationCompat.PRIORITY_HIGH -> HIGH

          else -> throw Exception("Unexpected priority int (-O): $priorityInt")
        }
      }
    )
  }
}
