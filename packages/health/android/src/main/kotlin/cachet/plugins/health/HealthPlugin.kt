package cachet.plugins.health

import android.app.Activity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.auth.api.signin.GoogleSignInOptionsExtension
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.result.DataReadResponse
import com.google.android.gms.tasks.Tasks
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import com.google.android.gms.fitness.data.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111
const val GOOGLE_SIGN_IN_REQUEST_CODE = 2222
const val CHANNEL_NAME = "flutter_health"

class HealthPlugin() : MethodCallHandler, ActivityResultListener, Result, ActivityAware, FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var result: Result? = null
    private val handler: Handler by lazy { Handler(Looper.getMainLooper()) }

    private var activity: Activity? = null

    private var BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    private var HEIGHT = "HEIGHT"
    private var WEIGHT = "WEIGHT"
    private var STEPS = "STEPS"
    private var ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    private var HEART_RATE = "HEART_RATE"
    private var BODY_TEMPERATURE = "BODY_TEMPERATURE"
    private var BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    private var BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    private var BLOOD_OXYGEN = "BLOOD_OXYGEN"
    private var BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    private var MOVE_MINUTES = "MOVE_MINUTES"
    private var DISTANCE_DELTA = "DISTANCE_DELTA"

    private fun _runOnUiThread(predicate: () -> Unit) = handler.post(predicate);

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME);
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        activity = null
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = HealthPlugin().apply {
                channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
                context = registrar.context()
                activity = registrar.activity()
            }
            plugin.channel.setMethodCallHandler(plugin)
            registrar.addActivityResultListener(plugin)
        }
    }

    override fun success(p0: Any?) {
        handler.post(
                Runnable { result?.success(p0) })
    }

    override fun notImplemented() {
        handler.post(
                Runnable { result?.notImplemented() })
    }

    override fun error(
            errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler.post(
                Runnable { result?.error(errorCode, errorMessage, errorDetails) })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        try {
            if (requestCode == GOOGLE_FIT_PERMISSIONS_REQUEST_CODE) {
                if (resultCode == Activity.RESULT_OK) {
                    Log.d("FLUTTER_HEALTH", "Access Granted!")
                    mResult?.success(mGoogleSignInAccount?.email)
                } else if (resultCode == Activity.RESULT_CANCELED) {
                    Log.d("FLUTTER_HEALTH", "Access Denied!")
                    mResult?.success(null)
                }
            } else if (requestCode == GOOGLE_SIGN_IN_REQUEST_CODE) {
                try {
                    _requestAuthorization(mCall!!, mResult!!, GoogleSignIn.getSignedInAccountFromIntent(data).result!!);
                } catch (e: Exception) {
                    Log.e("FLUTTER_HEALTH::ERROR", e.toString())
                    mResult?.success(null)
                }
            }
        } finally {
            mCall = null
            mResult = null
            mGoogleSignInAccount = null
        }
        return false
    }

    private var mCall: MethodCall? = null
    private var mResult: Result? = null
    private var mGoogleSignInAccount: GoogleSignInAccount? = null

    private fun keyToHealthDataType(type: String): DataType {
        return when (type) {
            BODY_FAT_PERCENTAGE -> DataType.TYPE_BODY_FAT_PERCENTAGE
            HEIGHT -> DataType.TYPE_HEIGHT
            WEIGHT -> DataType.TYPE_WEIGHT
            STEPS -> DataType.TYPE_STEP_COUNT_DELTA
            ACTIVE_ENERGY_BURNED -> DataType.TYPE_CALORIES_EXPENDED
            HEART_RATE -> DataType.TYPE_HEART_RATE_BPM
            BODY_TEMPERATURE -> HealthDataTypes.TYPE_BODY_TEMPERATURE
            BLOOD_PRESSURE_SYSTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
            BLOOD_PRESSURE_DIASTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
            BLOOD_OXYGEN -> HealthDataTypes.TYPE_OXYGEN_SATURATION
            BLOOD_GLUCOSE -> HealthDataTypes.TYPE_BLOOD_GLUCOSE
            MOVE_MINUTES -> DataType.TYPE_MOVE_MINUTES
            DISTANCE_DELTA -> DataType.TYPE_DISTANCE_DELTA
            else -> DataType.TYPE_STEP_COUNT_DELTA
        }
    }

    private fun getUnit(type: String): Field {
        return when (type) {
            BODY_FAT_PERCENTAGE -> Field.FIELD_PERCENTAGE
            HEIGHT -> Field.FIELD_HEIGHT
            WEIGHT -> Field.FIELD_WEIGHT
            STEPS -> Field.FIELD_STEPS
            ACTIVE_ENERGY_BURNED -> Field.FIELD_CALORIES
            HEART_RATE -> Field.FIELD_BPM
            BODY_TEMPERATURE -> HealthFields.FIELD_BODY_TEMPERATURE
            BLOOD_PRESSURE_SYSTOLIC -> HealthFields.FIELD_BLOOD_PRESSURE_SYSTOLIC
            BLOOD_PRESSURE_DIASTOLIC -> HealthFields.FIELD_BLOOD_PRESSURE_DIASTOLIC
            BLOOD_OXYGEN -> HealthFields.FIELD_OXYGEN_SATURATION
            BLOOD_GLUCOSE -> HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL
            MOVE_MINUTES -> Field.FIELD_DURATION
            DISTANCE_DELTA -> Field.FIELD_DISTANCE
            else -> Field.FIELD_PERCENTAGE
        }
    }

    /// Extracts the (numeric) value from a Health Data Point
    private fun getHealthDataValue(dataPoint: DataPoint, unit: Field): Any {
        return try {
            dataPoint.getValue(unit).asFloat()
        } catch (e1: Exception) {
            try {
                dataPoint.getValue(unit).asInt()
            } catch (e2: Exception) {
                try {
                    dataPoint.getValue(unit).asString()
                } catch (e3: Exception) {
                    Log.e("FLUTTER_HEALTH::ERROR", e3.toString())
                }
            }
        }
    }

    private fun _createGoogleSignInOption(
        signInOptions: GoogleSignInOptionsExtension? = null,
        accountName: String? = null
    ) = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).apply {
        requestEmail()
        signInOptions?.let { addExtension(it) }
        accountName?.takeIf { it.isNotEmpty() }?.let { setAccountName(it) }
    }.build()

    private fun _getGoogleSignInClient(
        signInOptions: GoogleSignInOptionsExtension? = null,
        accountName: String? = null,
        handler: (googleSignInClient: GoogleSignInClient) -> Unit
    ) {
        var googleSignInClient = activity?.let {
            GoogleSignIn.getClient(it, _createGoogleSignInOption(signInOptions, accountName))
        } ?: GoogleSignIn.getClient(context, _createGoogleSignInOption(signInOptions, accountName))

        if (accountName.isNullOrEmpty()) {
            googleSignInClient.signOut().addOnCompleteListener {
                _runOnUiThread { handler(googleSignInClient) }
            }
        } else _runOnUiThread { handler(googleSignInClient) }
    }

    private fun _getGoogleSignInAccount(
        accountName: String? = null,
        signInOptions: GoogleSignInOptionsExtension? = null,
        handler: (googleSignInAccount: GoogleSignInAccount?) -> Unit
    ) {
        _getGoogleSignInClient(signInOptions, accountName) {
            it.silentSignIn().addOnCompleteListener {
                handler(try {
                    it.result?.takeUnless { it.email.isNullOrEmpty() }
                } catch (e: Exception) {
                    Log.e("FLUTTER_HEALTH::ERROR", e.toString())
                    null
                })
            }
        }
    }

    /// Called when the "getHealthDataByType" is invoked from Flutter
    private fun getData(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(null)
            return
        }

        val type = call.argument<String>("dataTypeKey")!!

        // Look up data type and unit for the type key
        val dataType = keyToHealthDataType(type)
        val unit = getUnit(type)

        val optionsToGet = FitnessOptions.builder().addDataType(dataType, FitnessOptions.ACCESS_READ).build()

        call.argument<String?>("accountName")?.let {
            _getGoogleSignInAccount(it, optionsToGet) {
                if (it != null) {
                    _getData(call, result, dataType, unit, it)
                } else {
                    result.success(null)
                }
            }
            return
        }
        _getData(call, result, dataType, unit, GoogleSignIn.getAccountForExtension(context, optionsToGet));
    }

    private fun _getData(call: MethodCall, result: Result, dataType: DataType, unit: Field, googleSignInAccount: GoogleSignInAccount) {
        val startTime = call.argument<Long>("startDate")!!
        val endTime = call.argument<Long>("endDate")!!

        /// Start a new thread for doing a GoogleFit data lookup
        thread {
            try {
                val historyClient = activity?.let {
                    Fitness.getHistoryClient(it, googleSignInAccount)
                } ?: Fitness.getHistoryClient(context, googleSignInAccount)

                val response = historyClient
                    .readData(DataReadRequest.Builder()
                                .read(dataType)
                                .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                                .build())

                /// Fetch all data points for the specified DataType
                val dataPoints = Tasks.await<DataReadResponse>(response).getDataSet(dataType)

                /// For each data point, extract the contents and send them to Flutter, along with date and unit.
                val healthData = dataPoints.dataPoints.mapIndexed { _, dataPoint ->
                    return@mapIndexed hashMapOf(
                            "value" to getHealthDataValue(dataPoint, unit),
                            "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                            "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                            "unit" to unit.toString(),
                            "source_name" to dataPoint.getOriginalDataSource().getAppPackageName(),
                            "source_id" to dataPoint.getOriginalDataSource().getStreamIdentifier()
                    )

                }
                _runOnUiThread { result.success(healthData) }
            } catch (e3: Exception) {
                _runOnUiThread { result.success(null) }
            }
        }
    }

    private fun callToHealthTypes(call: MethodCall): FitnessOptions {
        val typesBuilder = FitnessOptions.builder()
        val args = call.arguments as HashMap<*, *>
        val types = args["types"] as ArrayList<*>
        for (typeKey in types) {
            if (typeKey !is String) continue
            typesBuilder.addDataType(keyToHealthDataType(typeKey), FitnessOptions.ACCESS_READ)
        }
        return typesBuilder.build()
    }

    /// Called when the "requestAuthorization" is invoked from Flutter
    private fun requestAuthorization(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(null)
            return
        }

        val optionsToRegister = callToHealthTypes(call)

        val accountName = call.argument<String?>("accountName")

        val googleSignInAccount = if (accountName != null) {
            if (accountName == "") null
            else {
                _getGoogleSignInAccount(accountName) {
                    if (it != null) {
                        _requestAuthorization(call, result, it)
                    } else {
                        _signIn(call, result, optionsToRegister)
                    }
                }
                return
            }
        } else GoogleSignIn.getLastSignedInAccount(context)

        if ((googleSignInAccount == null) || googleSignInAccount.email.isNullOrEmpty()) {
            _signIn(call, result, optionsToRegister)
        } else {
            _requestAuthorization(call, result, googleSignInAccount)
        }
    }

    private fun _checkActivity(result: Result): Boolean {
        if (activity == null) {
            Log.d("FLUTTER_HEALTH", "No Activity!")
            result?.success(null)
            return false;
        }
        return true;
    }

    private fun _signIn(call: MethodCall, result: Result, optionsToRegister: GoogleSignInOptionsExtension) {
        if (!_checkActivity(result)) return;

        mCall = call
        mResult = result
        _getGoogleSignInClient(optionsToRegister) {
            activity!!.startActivityForResult(
                    it.signInIntent, GOOGLE_SIGN_IN_REQUEST_CODE
            )
        }
    }

    private fun _requestAuthorization(call: MethodCall, result: Result, googleSignInAccount: GoogleSignInAccount) {
        val optionsToRegister = callToHealthTypes(call)

        val isGranted = GoogleSignIn.hasPermissions(googleSignInAccount, optionsToRegister)

        /// Not granted? Ask for permission
        if (!isGranted) {
            if (!_checkActivity(result)) return;

            mCall = call
            mResult = result
            mGoogleSignInAccount = googleSignInAccount
            GoogleSignIn.requestPermissions(
                    activity!!,
                    GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
                    googleSignInAccount,
                    optionsToRegister)
        }
        /// Permission already granted
        else {
            result?.success(googleSignInAccount.email)
        }
    }

    /// Handle calls from the MethodChannel
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestAuthorization" -> requestAuthorization(call, result)
            "getData" -> getData(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (channel == null) {
            return
        }
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        if (channel == null) {
            return
        }
        activity = null
    }
}
