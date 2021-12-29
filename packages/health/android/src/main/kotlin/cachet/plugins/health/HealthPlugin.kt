package cachet.plugins.health

import android.app.Activity
import com.google.android.gms.auth.api.signin.GoogleSignIn
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
import android.content.Intent
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.SessionReadRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111
const val CHANNEL_NAME = "flutter_health"
const val MMOLL_2_MGDL = 18.0 // 1 mmoll= 18 mgdl

class HealthPlugin(private var channel: MethodChannel? = null) : MethodCallHandler, ActivityResultListener, Result, ActivityAware, FlutterPlugin {
    private var result: Result? = null
    private var handler: Handler? = null
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
    private var WATER = "WATER"
    private var SLEEP_ASLEEP = "SLEEP_ASLEEP"
    private var SLEEP_AWAKE = "SLEEP_AWAKE"
    private var SLEEP_IN_BED = "SLEEP_IN_BED"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
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
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val plugin = HealthPlugin(channel)
            registrar.addActivityResultListener(plugin)
            channel.setMethodCallHandler(plugin)
        }
    }

    /// DataTypes to register
    // private val fitnessOptions = FitnessOptions.builder()
    //         .addDataType(keyToHealthDataType(BODY_FAT_PERCENTAGE), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(HEIGHT), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(WEIGHT), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(STEPS), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(ACTIVE_ENERGY_BURNED), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(HEART_RATE), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(BODY_TEMPERATURE), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(BLOOD_PRESSURE_SYSTOLIC), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(BLOOD_OXYGEN), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(BLOOD_GLUCOSE), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(MOVE_MINUTES), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(DISTANCE_DELTA), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(WATER), FitnessOptions.ACCESS_READ)
    //         .addDataType(keyToHealthDataType(SLEEP_ASLEEP), FitnessOptions.ACCESS_READ)
    //         .accessActivitySessions(FitnessOptions.ACCESS_READ)
    //         .accessSleepSessions(FitnessOptions.ACCESS_READ)
    //         .build()


    override fun success(p0: Any?) {
        handler?.post(
                Runnable { result?.success(p0) })
    }

    override fun notImplemented() {
        handler?.post(
                Runnable { result?.notImplemented() })
    }

    override fun error(
            errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler?.post(
                Runnable { result?.error(errorCode, errorMessage, errorDetails) })
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == GOOGLE_FIT_PERMISSIONS_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                Log.d("FLUTTER_HEALTH", "Access Granted!")
                mResult?.success(true)
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.d("FLUTTER_HEALTH", "Access Denied!")
                mResult?.success(false)
            }
        }
        return false
    }

    private var mResult: Result? = null

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
            WATER -> DataType.TYPE_HYDRATION
            SLEEP_ASLEEP -> DataType.TYPE_SLEEP_SEGMENT
            SLEEP_AWAKE -> DataType.TYPE_SLEEP_SEGMENT
            SLEEP_IN_BED -> DataType.TYPE_SLEEP_SEGMENT
            else -> throw IllegalArgumentException("Unsupported dataType: $type")
        }
    }

    private fun getField(type: String): Field {
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
            WATER -> Field.FIELD_VOLUME
            SLEEP_ASLEEP -> Field.FIELD_SLEEP_SEGMENT_TYPE
            SLEEP_AWAKE -> Field.FIELD_SLEEP_SEGMENT_TYPE
            SLEEP_IN_BED -> Field.FIELD_SLEEP_SEGMENT_TYPE
            else -> throw IllegalArgumentException("Unsupported dataType: $type")
        }
    }

    private fun isIntField(dataSource: DataSource, unit: Field): Boolean {
        val dataPoint =  DataPoint.builder(dataSource).build()
        val value = dataPoint.getValue(unit)
        return value.format == Field.FORMAT_INT32
    }

    /// Extracts the (numeric) value from a Health Data Point
    private fun getHealthDataValue(dataPoint: DataPoint, field: Field): Any {
        val value = dataPoint.getValue(field)
        // Conversion is needed because glucose is stored as mmoll in Google Fit;
        // while mgdl is used for glucose in this plugin.
        val isGlucose = field == HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL
        return when (value.format) {
            Field.FORMAT_FLOAT -> if (!isGlucose)  value.asFloat() else value.asFloat() * MMOLL_2_MGDL
            Field.FORMAT_INT32 -> value.asInt()
            Field.FORMAT_STRING -> value.asString()
            else -> Log.e("Unsupported format:", value.format.toString())
        }
    }

    private fun writeData(call: MethodCall, result: Result) {

        if (activity == null) {
            result.success(false)
            return
        }

        val type = call.argument<String>("dataTypeKey")!!
        val startTime = call.argument<Long>("startTime")!!
        val endTime = call.argument<Long>("endTime")!!
        val value = call.argument<Float>( "value")!!

        // Look up data type and unit for the type key
        val dataType = keyToHealthDataType(type)
        val field = getField(type)

        val typesBuilder = FitnessOptions.builder()
        typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

        val dataSource = DataSource.Builder()
                .setDataType(dataType)
                .setType(DataSource.TYPE_RAW)
                .setDevice(Device.getLocalDevice(activity!!.applicationContext))
                .setAppPackageName(activity!!.applicationContext)
                .build()

        val builder = if (startTime == endTime)
            DataPoint.builder(dataSource)
                    .setTimestamp(startTime, TimeUnit.MILLISECONDS)
        else
            DataPoint.builder(dataSource)
                    .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)

        // Conversion is needed because glucose is stored as mmoll in Google Fit;
        // while mgdl is used for glucose in this plugin.
        val isGlucose = field == HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL
        val dataPoint = if (!isIntField(dataSource, field))
            builder.setField(field, if (!isGlucose) value else (value/ MMOLL_2_MGDL).toFloat()).build() else
                builder.setField(field, value.toInt()).build()

        val dataSet = DataSet.builder(dataSource)
                .add(dataPoint)
                .build()

        if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
            typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
        }
        val fitnessOptions = typesBuilder.build()


        try {
            val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)
            Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                    .insertData(dataSet)
                    .addOnSuccessListener {
                        Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet added successfully!")
                        result.success(true)
                    }
                    .addOnFailureListener { e ->
                        Log.w("FLUTTER_HEALTH::ERROR", "There was an error adding the DataSet", e)
                        result.success(false)
                    }
        } catch (e3: Exception) {
             result.success(false)
        }
    }

    private fun getData(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(null)
            return
        }

        val type = call.argument<String>("dataTypeKey")!!
        val startTime = call.argument<Long>("startDate")!!
        val endTime = call.argument<Long>("endDate")!!

        // Look up data type and unit for the type key
        val dataType = keyToHealthDataType(type)
        val field = getField(type)

        /// Start a new thread for doing a GoogleFit data lookup
        thread {
            try {
                val typesBuilder = FitnessOptions.builder()
                typesBuilder.addDataType(dataType)
                if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
                    typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
                }
                val fitnessOptions = typesBuilder.build()
                val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

                if (dataType != DataType.TYPE_SLEEP_SEGMENT) {
                    val response = Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                        .readData(DataReadRequest.Builder()
                            .read(dataType)
                            .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                            .build())

                    /// Fetch all data points for the specified DataType
                    val dataPoints = Tasks.await<DataReadResponse>(response).getDataSet(dataType)

                    /// For each data point, extract the contents and send them to Flutter, along with date and unit.
                    val healthData = dataPoints.dataPoints.mapIndexed { _, dataPoint ->
                        return@mapIndexed hashMapOf(
                                "value" to getHealthDataValue(dataPoint, field),
                                "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                                "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                                "source_name" to (dataPoint.originalDataSource.appPackageName ?: (dataPoint.originalDataSource.device?.model ?: "" )),
                                "source_id" to dataPoint.originalDataSource.streamIdentifier
                        )
                    }

                    activity!!.runOnUiThread { result.success(healthData) }
                } else {
                    // request to the sessions for sleep data
                    val request = SessionReadRequest.Builder()
                            .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
                            .enableServerQueries()
                            .readSessionsFromAllApps()
                            .includeSleepSessions()
                            .build()
                    Fitness.getSessionsClient(activity!!.applicationContext, googleSignInAccount)
                            .readSession(request)
                            .addOnSuccessListener { response ->
                                var healthData: MutableList<Map<String, Any?>> = mutableListOf()
                                for (session in response.sessions) {

                                    // Return sleep time in Minutes if requested ASLEEP data
                                    if (type == SLEEP_ASLEEP) {
                                        healthData.add(
                                                hashMapOf(
                                                        "value" to session.getEndTime(TimeUnit.MINUTES) - session.getStartTime(TimeUnit.MINUTES),
                                                        "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
                                                        "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
                                                        "unit" to "MINUTES",
                                                        "source_name" to session.appPackageName,
                                                        "source_id" to session.identifier
                                                )
                                        )
                                    }
                                    // Returns time spent in bed in Minutes
                                    if (type == SLEEP_IN_BED) {
                                        val dataSets = response.getDataSet(session)

                                        // If the sleep session has finer granularity sub-components, extract them:
                                        if( dataSets.isNotEmpty()){
                                            for (dataSet in dataSets) {
                                                for (dataPoint in dataSet.dataPoints) {
                                                    // searching OUT OF BED data
                                                    if (dataPoint.getValue(Field.FIELD_SLEEP_SEGMENT_TYPE).asInt() != 3) {
                                                        healthData.add(
                                                                hashMapOf(
                                                                        "value" to dataPoint.getEndTime(TimeUnit.MINUTES) - dataPoint.getStartTime(TimeUnit.MINUTES),
                                                                        "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                                                                        "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                                                                        "unit" to "MINUTES",
                                                                        "source_name" to (dataPoint.originalDataSource.appPackageName
                                                                                ?: (dataPoint.originalDataSource.device?.model
                                                                                        ?: "unknown")),
                                                                        "source_id" to dataPoint.originalDataSource.streamIdentifier
                                                                )
                                                        )
                                                    }
                                                }
                                            }
                                        } else {
                                            healthData.add(
                                                    hashMapOf(
                                                            "value" to session.getEndTime(TimeUnit.MINUTES) - session.getStartTime(TimeUnit.MINUTES),
                                                            "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
                                                            "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
                                                            "unit" to "MINUTES",
                                                            "source_name" to session.appPackageName,
                                                            "source_id" to session.identifier
                                                    )
                                            )
                                        }
                                    }

                                    // If the sleep session has finer granularity sub-components, extract them:
                                    if (type == SLEEP_AWAKE) {
                                        val dataSets = response.getDataSet(session)
                                        for (dataSet in dataSets) {
                                            for (dataPoint in dataSet.dataPoints) {
                                                // searching SLEEP AWAKE data
                                                if (dataPoint.getValue(Field.FIELD_SLEEP_SEGMENT_TYPE).asInt() == 1) {
                                                    healthData.add(
                                                            hashMapOf(
                                                                    "value" to dataPoint.getEndTime(TimeUnit.MINUTES) - dataPoint.getStartTime(TimeUnit.MINUTES),
                                                                    "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                                                                    "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                                                                    "unit" to "MINUTES",
                                                                    "source_name" to (dataPoint.originalDataSource.appPackageName
                                                                            ?: (dataPoint.originalDataSource.device?.model
                                                                                    ?: "unknown")),
                                                                    "source_id" to dataPoint.originalDataSource.streamIdentifier
                                                            )
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                                activity!!.runOnUiThread { result.success(healthData) }
                            }
                            .addOnFailureListener { exception ->
                                activity!!.runOnUiThread { result.success(null) }
                                Log.i("FLUTTER_HEALTH::ERROR", exception.message ?: "unknown error")
                                Log.i("FLUTTER_HEALTH::ERROR", exception.stackTrace.toString())
                            }
                }
            } catch (e3: Exception) {
                activity!!.runOnUiThread { result.success(null) }
            }
        }
    }

    private fun callToHealthTypes(call: MethodCall): FitnessOptions {
        val typesBuilder = FitnessOptions.builder()
        val args = call.arguments as HashMap<*, *>
//<<<<<<< metric
        val types = (args["types"] as? ArrayList<*>)?.filterIsInstance<String>()
        val permissions = (args["permissions"] as? ArrayList<*>)?.filterIsInstance<Int>()

        assert(types != null)
        assert(permissions != null)
        assert(types!!.count() == permissions!!.count())

        for ((i, typeKey) in types.withIndex()) {
            val access = permissions[i]
            val dataType = keyToHealthDataType(typeKey)
            when (access) {
                0 -> typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_READ)
                1 -> typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)
                2 -> {
                    typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_READ)
                    typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)
                }
                else -> throw IllegalArgumentException("Unknown access type $access")
            }
            if (typeKey == SLEEP_ASLEEP || typeKey == SLEEP_AWAKE) {
//=======
        val types = args["types"] as ArrayList<*>
        for (typeKey in types) {
            if (typeKey !is String) continue
            typesBuilder.addDataType(keyToHealthDataType(typeKey), FitnessOptions.ACCESS_READ)
            typesBuilder.addDataType(keyToHealthDataType(typeKey), FitnessOptions.ACCESS_WRITE)
            if (typeKey == SLEEP_ASLEEP || typeKey == SLEEP_AWAKE || typeKey == SLEEP_IN_BED) {
//>>>>>>> master
                typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
                when (access) {
                    0 -> typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
                    1 -> typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_WRITE)
                    2 -> {
                        typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
                        typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_WRITE)
                    }
                    else -> throw IllegalArgumentException("Unknown access type $access")
                }
            }

        }
        return typesBuilder.build()
    }

    private fun hasPermissions(call: MethodCall, result: Result) {

        if (activity == null) {
            result.success(false)
            return
        }

        val optionsToRegister = callToHealthTypes(call)
        mResult = result

        val isGranted = GoogleSignIn.hasPermissions(GoogleSignIn.getLastSignedInAccount(activity), optionsToRegister)

        mResult?.success(isGranted)
    }

    /// Called when the "requestAuthorization" is invoked from Flutter 
    private fun requestAuthorization(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }

        val optionsToRegister = callToHealthTypes(call)
        mResult = result

        val isGranted = GoogleSignIn.hasPermissions(GoogleSignIn.getLastSignedInAccount(activity), optionsToRegister)
        /// Not granted? Ask for permission
        if (!isGranted && activity != null) {
            GoogleSignIn.requestPermissions(
                    activity!!,
                    GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
                    GoogleSignIn.getLastSignedInAccount(activity),
                    optionsToRegister)
        }
        /// Permission already granted
        else {
            mResult?.success(true)
        }
    }

    /// Handle calls from the MethodChannel
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestAuthorization" -> requestAuthorization(call, result)
            "getData" -> getData(call, result)
            "writeData" -> writeData(call, result)
            "hasPermissions" -> hasPermissions(call, result)
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
