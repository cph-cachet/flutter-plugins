package cachet.plugins.health

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.annotation.NonNull
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.BodyFatRecord
import androidx.health.connect.client.records.NutritionRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.WeightRecord

import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Energy
import androidx.health.connect.client.units.Mass
import androidx.health.connect.client.units.Percentage
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.DataDeleteRequest
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.request.DataUpdateRequest
import com.google.android.gms.fitness.request.SessionReadRequest
import com.google.android.gms.fitness.result.DataReadResponse
import com.google.android.gms.fitness.result.SessionReadResponse
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.collections.ArrayList
import kotlin.reflect.KClass

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111
const val HEALTH_CONNECT_PERMISSIONS_REQUEST_CODE = 2222
const val CHANNEL_NAME = "flutter_health"
const val MMOLL_2_MGDL = 18.0 // 1 mmoll= 18 mgdl
const val MIN_SUPPORTED_SDK = Build.VERSION_CODES.O_MR1

class HealthPlugin(private var channel: MethodChannel? = null) : MethodCallHandler,
    ActivityResultListener, Result, ActivityAware, FlutterPlugin {
    private var result: Result? = null
    private var handler: Handler? = null
    private var activity: Activity? = null
    private var threadPoolExecutor: ExecutorService? = null
    private var healthConnectRequestPermissionsLauncher: ActivityResultLauncher<Set<String>>? = null
    private var BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    private var HEIGHT = "HEIGHT"
    private var WEIGHT = "WEIGHT"
    private var STEPS = "STEPS"
    private var AGGREGATE_STEP_COUNT = "AGGREGATE_STEP_COUNT"
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
    private var NUTRITION = "NUTRITION"
    //private var BODYFAT = "BODYFAT"


    private var DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
    private var DIETARY_CARBS_CONSUMED = "DIETARY_CARBS_CONSUMED"
    private var DIETARY_FATS_CONSUMED = "DIETARY_FATS_CONSUMED"
    private var DIETARY_PROTEIN_CONSUMED = "DIETARY_PROTEIN_CONSUMED"

    private var DIETARY_FAT_SATURATED = "DIETARY_FAT_SATURATED"
    private var DIETARY_FAT_UNSATURATED = "DIETARY_FAT_UNSATURATED"
    private var DIETARY_FAT_POLYUNSATURATED = "DIETARY_FAT_POLYUNSATURATED"
    private var DIETARY_FAT_MONOUNSATURATED = "DIETARY_FAT_MONOUNSATURATED"
    private var DIETARY_FAT_TRANS = "DIETARY_FAT_TRANS"
    private var DIETARY_CHOLESTEROL = "DIETARY_CHOLESTEROL"
    private var DIETARY_SODIUM = "DIETARY_SODIUM"
    private var DIETARY_POTASSIUM = "DIETARY_POTASSIUM"
    private var DIETARY_FIBER = "DIETARY_FIBER"
    private var DIETARY_SUGAR = "DIETARY_SUGAR"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        threadPoolExecutor = Executors.newFixedThreadPool(4)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
        activity = null
        threadPoolExecutor!!.shutdown()
        threadPoolExecutor = null
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
        errorCode: String, errorMessage: String?, errorDetails: Any?
    ) {
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
        } else if (requestCode == HEALTH_CONNECT_PERMISSIONS_REQUEST_CODE) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    Log.d("FLUTTER_HEALTH", "Access Granted!123")
                    mResult?.success(true)
                }
                Activity.RESULT_CANCELED -> {
                    Log.d("FLUTTER_HEALTH", "Access Denied!123")
                    mResult?.success(false)
                }
                Activity.RESULT_FIRST_USER -> {
                    Log.d("FLUTTER_HEALTH", "Access Denied!!")
                    mResult?.success(false)
                }
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
            AGGREGATE_STEP_COUNT -> DataType.AGGREGATE_STEP_COUNT_DELTA
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
            DIETARY_ENERGY_CONSUMED -> DataType.TYPE_NUTRITION
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
            DIETARY_ENERGY_CONSUMED -> Field.FIELD_NUTRIENTS
            else -> throw IllegalArgumentException("Unsupported dataType: $type")
        }
    }

    private fun getNutrientField(type: String): String {
        return when (type) {
            DIETARY_ENERGY_CONSUMED -> Field.NUTRIENT_CALORIES
            DIETARY_CARBS_CONSUMED -> Field.NUTRIENT_TOTAL_CARBS
            DIETARY_FATS_CONSUMED -> Field.NUTRIENT_TOTAL_FAT
            DIETARY_PROTEIN_CONSUMED -> Field.NUTRIENT_PROTEIN
            DIETARY_FAT_SATURATED -> Field.NUTRIENT_SATURATED_FAT
            DIETARY_FAT_UNSATURATED -> Field.NUTRIENT_UNSATURATED_FAT
            DIETARY_FAT_POLYUNSATURATED -> Field.NUTRIENT_POLYUNSATURATED_FAT
            DIETARY_FAT_MONOUNSATURATED -> Field.NUTRIENT_MONOUNSATURATED_FAT
            DIETARY_FAT_TRANS -> Field.NUTRIENT_TRANS_FAT
            DIETARY_CHOLESTEROL -> Field.NUTRIENT_CHOLESTEROL
            DIETARY_SODIUM -> Field.NUTRIENT_SODIUM
            DIETARY_POTASSIUM -> Field.NUTRIENT_POTASSIUM
            DIETARY_FIBER -> Field.NUTRIENT_DIETARY_FIBER
            DIETARY_SUGAR -> Field.NUTRIENT_SUGAR
            else -> throw IllegalArgumentException("Unsupported dataType: $type")
        }
    }

    private fun isIntField(dataSource: DataSource, unit: Field): Boolean {
        val dataPoint = DataPoint.builder(dataSource).build()
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
            Field.FORMAT_FLOAT -> if (!isGlucose) value.asFloat() else value.asFloat() * MMOLL_2_MGDL
            Field.FORMAT_INT32 -> value.asInt()
            Field.FORMAT_STRING -> value.asString()
            else -> Log.e("Unsupported format:", value.format.toString())
        }
    }

    private fun deleteData(call: MethodCall, result: Result) {

        if (activity == null) {
            result.success(false)
            return
        }

        val type = call.argument<String>("dataTypeKey")!!
        val startTime = call.argument<Long>("startTime")!!
        val endTime = call.argument<Long>("endTime")!!

        // Look up data type and unit for the type key
        val dataType = keyToHealthDataType(type)

        val typesBuilder = FitnessOptions.builder()
        typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

        val fitnessOptions = typesBuilder.build()
        try {
            val googleSignInAccount =
                GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

            val request = DataDeleteRequest.Builder()
                .addDataType(dataType)
                .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
                .build()

            Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                .deleteData(request)
                .addOnSuccessListener {
                    Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet deleted successfully!")
                    result.success(true)
                }
                .addOnFailureListener { e ->
                    Log.w("FLUTTER_HEALTH::ERROR", "There was an error deleting the DataSet", e)
                    result.success(false)
                }
        } catch (e3: Exception) {
            result.success(false)
        }
    }

    private fun deleteFoodData(call: MethodCall, result: Result) {

        if (activity == null) {
            result.success(false)
            return
        }

        val startTime = call.argument<Long>("startTime")!!
        val endTime = call.argument<Long>("endTime")!!

        val dataType = DataType.TYPE_NUTRITION

        val typesBuilder = FitnessOptions.builder()
        typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

        val fitnessOptions = typesBuilder.build()
        try {
            val googleSignInAccount =
                GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

            val request = DataDeleteRequest.Builder()
                .addDataType(dataType)
                .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
                .build()

            Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                .deleteData(request)
                .addOnSuccessListener {
                    Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet deleted successfully!")
                    result.success(true)
                }
                .addOnFailureListener { e ->
                    Log.w("FLUTTER_HEALTH::ERROR", "There was an error deleting the DataSet", e)
                    result.success(false)
                }
        } catch (e3: Exception) {
            result.success(false)
        }
    }

    private fun writeFoodData(call: MethodCall, result: Result) {

        if (activity == null) {
            result.success(false)
            return
        }

        val foodList = call.argument<List<HashMap<String, *>>>("foodList")!!
        val startTime = call.argument<Long>("startTime")!!
        val endTime = call.argument<Long>("endTime")!!
        val overwrite = call.argument<Boolean>("overwrite")!!

        Log.i("FLUTTER_HEALTH::SUCCESS", "Successfully called writeFoodData")

        val field = Field.FIELD_NUTRIENTS
        val dataType = DataType.TYPE_NUTRITION

        val typesBuilder = FitnessOptions.builder()
        typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

        val dataSource = DataSource.Builder()
            .setDataType(dataType)
            .setType(DataSource.TYPE_RAW)
            .setDevice(Device.getLocalDevice(activity!!.applicationContext))
            .setAppPackageName(activity!!.applicationContext)
            .build()

        val dataSetBuilder = DataSet.builder(dataSource)

        for (food in foodList) {
            val iterationFood = food.toMutableMap()

            val timestamp = iterationFood["timestamp"] as Long
            iterationFood.remove("timestamp")

            val builder =
                DataPoint.builder(dataSource).setTimestamp(timestamp, TimeUnit.MILLISECONDS)

            val nutrients = mutableMapOf<String, Float>()

            for ((nutrient, value) in iterationFood) {
                val nutrientField = getNutrientField(nutrient)
                nutrients[nutrientField] = value.toString().toFloat()
            }

            val dataPoint: DataPoint = builder.setField(field, nutrients).build()

            dataSetBuilder.add(dataPoint)

        }

        val dataSet = dataSetBuilder.build()

        val fitnessOptions = typesBuilder.build()
        try {
            val googleSignInAccount =
                GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

            if (overwrite) {
                val request = DataDeleteRequest.Builder()
                    .addDataType(dataType)
                    .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
                    .build()

                Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                    .deleteData(request)
                    .addOnSuccessListener {
                        Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet deleted successfully!")
                        if (!dataSet.isEmpty) {
                            Fitness.getHistoryClient(
                                activity!!.applicationContext,
                                googleSignInAccount
                            )
                                .insertData(dataSet)
                                .addOnSuccessListener {
                                    Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet added successfully!")
                                    result.success(true)
                                }
                                .addOnFailureListener { e ->
                                    Log.w(
                                        "FLUTTER_HEALTH::ERROR",
                                        "There was an error adding the DataSet",
                                        e
                                    )
                                    result.success(false)
                                }
                        } else {
                            Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet was empty!")
                            result.success(true)
                        }
                    }
                    .addOnFailureListener { e ->
                        Log.w("FLUTTER_HEALTH::ERROR", "There was an error deleting the DataSet", e)
                    }
            } else {
                if (!dataSet.isEmpty) {
                    Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                        .insertData(dataSet)
                        .addOnSuccessListener {
                            Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet added successfully!")
                            result.success(true)
                        }
                        .addOnFailureListener { e ->
                            Log.w(
                                "FLUTTER_HEALTH::ERROR",
                                "There was an error adding the DataSet",
                                e
                            )
                            result.success(false)
                        }
                } else {
                    Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet was empty!")
                    result.success(true)
                }
            }
        } catch (e3: Exception) {
            result.success(false)
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

        val value = call.argument<Float>("value")!!
        val overwrite = call.argument<Boolean>("overwrite")!!

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
        val isNutrition = field == Field.FIELD_NUTRIENTS

        val dataPoint: DataPoint = if (isNutrition) {
            val nutrientField = getNutrientField(type)
            val nutrients = mapOf(
                nutrientField to value
            )
            builder.setField(field, nutrients).build()
        } else {
            if (!isIntField(dataSource, field))
                builder.setField(field, if (!isGlucose) value else (value / MMOLL_2_MGDL).toFloat())
                    .build() else
                builder.setField(field, value.toInt()).build()
        }

        val dataSet = DataSet.builder(dataSource)
            .add(dataPoint)
            .build()

        if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
            typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
        }
        val fitnessOptions = typesBuilder.build()
        try {
            val googleSignInAccount =
                GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

            if (overwrite) {
                val request = DataUpdateRequest.Builder()
                    .setDataSet(dataSet)
                    .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
                    .build()

                Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                    .updateData(request)
                    .addOnSuccessListener {
                        Log.i("FLUTTER_HEALTH::SUCCESS", "DataSet added successfully!")
                        result.success(true)
                    }
                    .addOnFailureListener { e ->
                        Log.w("FLUTTER_HEALTH::ERROR", "There was an error adding the DataSet", e)
                        result.success(false)
                    }
            } else {
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
            }
        } catch (e3: Exception) {
            result.success(false)
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun writeDataHealthConnect(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val type = call.argument<String>("dataTypeKey")!!

        mResult = result

        var records = emptyList<Record>()
        var deleteDataRequest: TimeRangeFilter? = null
        when (type) {
            WEIGHT -> {
                val currentTime = call.argument<String>("currentTime")!!
                val value = call.argument<Float>("value")!!
                val time = ZonedDateTime.parse(
                    currentTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val weight = WeightRecord(
                    weight = Mass.kilograms(value.toDouble()),
                    time = time.toInstant(),
                    zoneOffset = time.offset
                )
                records = listOf(weight)
            }
            BODY_FAT_PERCENTAGE -> {
                val currentTime = call.argument<String>("currentTime")!!
                val value = call.argument<Float>("value")!!
                val time = ZonedDateTime.parse(
                    currentTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val bodyFatRecord = BodyFatRecord(
                    time = time.toInstant(),
                    zoneOffset = time.offset,
                    Percentage(value.toDouble()),
                )
                records = listOf(bodyFatRecord)
            }
            NUTRITION -> {
                val listValue = call.argument<List<Map<String, Any>>>("value")!!

                val isOverWrite = call.argument<Boolean>("isOverWrite")!!
                if (isOverWrite) {
                    val startTime = call.argument<String>("startTime")!!
                    val endTime = call.argument<String>("endTime")!!
                    val startDate = ZonedDateTime.parse(
                        startTime,
                        DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                    )
                    val endDate = ZonedDateTime.parse(
                        endTime,
                        DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                    )
                    deleteDataRequest = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    )
                }

                listValue.forEach { value ->
                    val startTime = ZonedDateTime.parse(
                        value["startTime"].toString(),
                        DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                    )
                    val endTime = ZonedDateTime.parse(
                        value["endTime"].toString(),
                        DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                    )
                    val nutritionRecord = NutritionRecord(
                        startTime = startTime.toInstant(),
                        endTime = endTime.toInstant(),
                        startZoneOffset = startTime.offset,
                        endZoneOffset = endTime.offset,
                        mealType = 0,
//                        mealType = (if (value.contains("mealType")) {
//                            value.getValue("mealType").toString(); } else null),
                        name = (if (value.contains("name")) {
                            value.getValue("name").toString(); } else null),
                        biotin = (if (value.contains("biotin")) {
                            getMassFromMap((value.getValue("biotin") as Map<String, Any>))
                        } else null),
                        caffeine = (if (value.contains("caffeine")) {
                            getMassFromMap(value.getValue("caffeine") as Map<String, Any>)
                        } else null),
                        calcium = (if (value.contains("calcium")) {
                            getMassFromMap(value.getValue("calcium") as Map<String, Any>)
                        } else null),
                        chloride = (if (value.contains("chloride")) {
                            getMassFromMap(value.getValue("chloride") as Map<String, Any>)
                        } else null),
                        cholesterol = (if (value.contains("cholesterol")) {
                            getMassFromMap(value.getValue("cholesterol") as Map<String, Any>)
                        } else null),
                        chromium = (if (value.contains("chromium")) {
                            getMassFromMap(value.getValue("chromium") as Map<String, Any>)
                        } else null),
                        copper = (if (value.contains("copper")) {
                            getMassFromMap(value.getValue("copper") as Map<String, Any>)
                        } else null),
                        dietaryFiber = (if (value.contains("dietaryFiber")) {
                            getMassFromMap(value.getValue("dietaryFiber") as Map<String, Any>)
                        } else null),
                        energy = (if (value.contains("energy")) {
                            getEnergyFromMap(value.getValue("energy") as Map<String, Any>)
                        } else null),
                        energyFromFat = (if (value.contains("energyFromFat")) {
                            getEnergyFromMap(value.getValue("energyFromFat") as Map<String, Any>)
                        } else null),
                        folate = (if (value.contains("folate")) {
                            getMassFromMap(value.getValue("folate") as Map<String, Any>)
                        } else null),
                        folicAcid = (if (value.contains("folicAcid")) {
                            getMassFromMap(value.getValue("folicAcid") as Map<String, Any>)
                        } else null),
                        iodine = (if (value.contains("iodine")) {
                            getMassFromMap(value.getValue("iodine") as Map<String, Any>)
                        } else null),
                        iron = (if (value.contains("iron")) {
                            getMassFromMap(value.getValue("iron") as Map<String, Any>)
                        } else null),
                        magnesium = (if (value.contains("magnesium")) {
                            getMassFromMap(value.getValue("magnesium") as Map<String, Any>)
                        } else null),
                        manganese = (if (value.contains("manganese")) {
                            getMassFromMap(value.getValue("manganese") as Map<String, Any>)
                        } else null),
                        molybdenum = (if (value.contains("molybdenum")) {
                            getMassFromMap(value.getValue("molybdenum") as Map<String, Any>)
                        } else null),
                        monounsaturatedFat = (if (value.contains("monounsaturatedFat")) {
                            getMassFromMap(value.getValue("monounsaturatedFat") as Map<String, Any>)
                        } else null),
                        niacin = (if (value.contains("niacin")) {
                            getMassFromMap(value.getValue("niacin") as Map<String, Any>)
                        } else null),
                        pantothenicAcid = (if (value.contains("pantothenicAcid")) {
                            getMassFromMap(value.getValue("pantothenicAcid") as Map<String, Any>)
                        } else null),
                        phosphorus = (if (value.contains("phosphorus")) {
                            getMassFromMap(value.getValue("phosphorus") as Map<String, Any>)
                        } else null),
                        polyunsaturatedFat = (if (value.contains("polyunsaturatedFat")) {
                            getMassFromMap(value.getValue("polyunsaturatedFat") as Map<String, Any>)
                        } else null),
                        potassium = (if (value.contains("potassium")) {
                            getMassFromMap(value.getValue("potassium") as Map<String, Any>)
                        } else null),
                        protein = (if (value.contains("protein")) {
                            getMassFromMap(value.getValue("protein") as Map<String, Any>)
                        } else null),
                        riboflavin = (if (value.contains("riboflavin")) {
                            getMassFromMap(value.getValue("riboflavin") as Map<String, Any>)
                        } else null),
                        saturatedFat = (if (value.contains("saturatedFat")) {
                            getMassFromMap(value.getValue("saturatedFat") as Map<String, Any>)
                        } else null),
                        selenium = (if (value.contains("selenium")) {
                            getMassFromMap(value.getValue("selenium") as Map<String, Any>)
                        } else null),
                        sodium = (if (value.contains("sodium")) {
                            getMassFromMap(value.getValue("sodium") as Map<String, Any>)
                        } else null),
                        sugar = (if (value.contains("sugar")) {
                            getMassFromMap(value.getValue("sugar") as Map<String, Any>)
                        } else null),
                        thiamin = (if (value.contains("thiamin")) {
                            getMassFromMap(value.getValue("thiamin") as Map<String, Any>)
                        } else null),
                        totalCarbohydrate = (if (value.contains("totalCarbohydrate")) {
                            getMassFromMap(value.getValue("totalCarbohydrate") as Map<String, Any>)
                        } else null),
                        totalFat = (if (value.contains("totalFat")) {
                            getMassFromMap(value.getValue("totalFat") as Map<String, Any>)
                        } else null),
                        transFat = (if (value.contains("transFat")) {
                            getMassFromMap(value.getValue("transFat") as Map<String, Any>)
                        } else null),
                        unsaturatedFat = (if (value.contains("unsaturatedFat")) {
                            getMassFromMap(value.getValue("unsaturatedFat") as Map<String, Any>)
                        } else null),
                        vitaminA = (if (value.contains("vitaminA")) {
                            getMassFromMap(value.getValue("vitaminA") as Map<String, Any>)
                        } else null),
                        vitaminB6 = (if (value.contains("vitaminB6")) {
                            getMassFromMap(value.getValue("vitaminB6") as Map<String, Any>)
                        } else null),
                        vitaminB12 = (if (value.contains("vitaminB12")) {
                            getMassFromMap(value.getValue("vitaminB12") as Map<String, Any>)
                        } else null),
                        vitaminC = (if (value.contains("vitaminC")) {
                            getMassFromMap(value.getValue("vitaminC") as Map<String, Any>)
                        } else null),
                        vitaminD = (if (value.contains("vitaminD")) {
                            getMassFromMap(value.getValue("vitaminD") as Map<String, Any>)
                        } else null),
                        vitaminE = (if (value.contains("vitaminE")) {
                            getMassFromMap(value.getValue("vitaminE") as Map<String, Any>)
                        } else null),
                        vitaminK = (if (value.contains("vitaminK")) {
                            getMassFromMap(value.getValue("vitaminK") as Map<String, Any>)
                        } else null),
                        zinc = (if (value.contains("zinc")) {
                            getMassFromMap(value.getValue("zinc") as Map<String, Any>)
                        } else null),
                    )
                    records = records + listOf(nutritionRecord)
                }
            }
        }
        CoroutineScope(Dispatchers.Main).launch {
            if (type == NUTRITION && deleteDataRequest != null) {
                healthConnectClient.deleteRecords(
                    NutritionRecord::class,
                    timeRangeFilter = deleteDataRequest
                )
            }
            if (records.isNotEmpty()) {
                healthConnectClient.insertRecords(records)
            }
            result.success(true)
        }

    }

    private fun getMassFromMap(map: Map<String, Any>): Mass {
        if (map.getValue("type") == "GRAMS") {
            return Mass.grams(map.getValue("value") as Double)
        } else if (map.getValue("type") == "KILOGRAMS") {
            return Mass.kilograms(map.getValue("value") as Double)
        } else if (map.getValue("type") == "MILLIGRAMS") {
            return Mass.milligrams(map.getValue("value") as Double)
        } else if (map.getValue("type") == "MICROGRAMS") {
            return Mass.micrograms(map.getValue("value") as Double)
        } else if (map.getValue("type") == "OUNCES") {
            return Mass.ounces(map.getValue("value") as Double)
        } else if (map.getValue("type") == "POUNDS") {
            return Mass.pounds(map.getValue("value") as Double)
        }
        return Mass.grams(map.getValue("value") as Double)
    }

    private fun getEnergyFromMap(map: Map<String, Any>): Energy {
        if (map.getValue("type") == "CALORIES") {
            return Energy.calories(map.getValue("value") as Double)
        } else if (map.getValue("type") == "KILOCALORIES") {
            return Energy.kilocalories(map.getValue("value") as Double)
        } else if (map.getValue("type") == "JOULES") {
            return Energy.joules(map.getValue("value") as Double)
        } else if (map.getValue("type") == "KILOJOULES") {
            return Energy.kilojoules(map.getValue("value") as Double)
        }

        return Energy.calories(map.getValue("value") as Double)
    }

    private fun getHealthConnectData(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val type = call.argument<String>("dataTypeKey")!!
        val startDate = call.argument<String>("startDate")!!
        val endDate = call.argument<String>("endDate")!!

        mResult = result

        when (type) {
            WEIGHT -> {
                val startDate = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    )
                )
                CoroutineScope(Dispatchers.Main).launch {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<WeightRecord> = response.records;

                    val healthData = dataList.mapIndexed { _, it ->
                        val formatter = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.MEDIUM)
                        val zonedDateTime =
                            dateTimeWithOffsetOrDefault(it.time, it.zoneOffset)
                        val uid = it.metadata.id
                        val weight = it.weight.inGrams
                        return@mapIndexed hashMapOf(
                            //"zonedDateTime" to formatter.format(zonedDateTime),
                            "zonedDateTime" to zonedDateTime.toInstant().toEpochMilli(),
                            "uid" to uid,
                            "weight" to weight
                        )
                    }
                    activity!!.runOnUiThread { result.success(healthData) }
                }
            }
            BODY_FAT_PERCENTAGE -> {
                val startDate = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = BodyFatRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    )
                )
                CoroutineScope(Dispatchers.Main).launch {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<BodyFatRecord> = response.records

                    val healthData = dataList.mapIndexed { _, it ->
                        val formatter = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.MEDIUM)
                        val zonedDateTime =
                            dateTimeWithOffsetOrDefault(it.time, it.zoneOffset)
                        val uid = it.metadata.id
                        val bodyFat = it.percentage.value
                        return@mapIndexed hashMapOf(
                            "zonedDateTime" to zonedDateTime.toInstant().toEpochMilli(),
                            //"zonedDateTime" to formatter.format(zonedDateTime),
                            "uid" to uid,
                            "bodyFat" to bodyFat
                        )
                    }
                    activity!!.runOnUiThread { result.success(healthData) }
                }
            }
            NUTRITION -> {
                val startDate = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = NutritionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    ),
                )
                CoroutineScope(Dispatchers.Main).launch {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<NutritionRecord> = response.records
                    val healthData = dataList.mapIndexed { _, it ->
                        val formatter = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.MEDIUM)
                        val startZonedDateTime =
                            dateTimeWithOffsetOrDefault(it.startTime, it.startZoneOffset)
                        val endZonedDateTime =
                            dateTimeWithOffsetOrDefault(it.endTime, it.endZoneOffset)
                        val uid = it.metadata.id
                        val hashMapData = hashMapOf<String, Any>(
                            "startDateTime" to startZonedDateTime.toInstant().toEpochMilli(),
                            "endDateTime" to endZonedDateTime.toInstant().toEpochMilli(),
                            "uid" to uid,
                        )
                        if (it.biotin != null) {
                            //hashMapData["biotin"] = "${it.biotin!!.inGrams} grams"
                            hashMapData["biotin"] = it.biotin!!.inGrams
                        }
                        if (it.caffeine != null) {
                            //hashMapData["caffeine"] = "${it.caffeine!!.inGrams} grams"
                            hashMapData["caffeine"] = it.caffeine!!.inGrams
                        }
                        if (it.calcium != null) {
                            //hashMapData["calcium"] = "${it.calcium!!.inGrams} grams"
                            hashMapData["calcium"] = it.calcium!!.inGrams
                        }
                        if (it.energy != null) {
                            hashMapData["energy"] = it.energy!!.inCalories
                        }
                        if (it.energyFromFat != null) {
                            hashMapData["energyFromFat"] =
                                it.energyFromFat!!.inCalories
                        }
                        if (it.chloride != null) {
                            hashMapData["chloride"] = it.chloride!!.inGrams
                        }
                        if (it.cholesterol != null) {
                            hashMapData["cholesterol"] = it.cholesterol!!.inGrams
                        }
                        if (it.chromium != null) {
                            hashMapData["chromium"] = it.chromium!!.inGrams
                        }
                        if (it.copper != null) {
                            hashMapData["copper"] = it.copper!!.inGrams
                        }
                        if (it.dietaryFiber != null) {
                            hashMapData["dietaryFiber"] = it.dietaryFiber!!.inGrams
                        }
                        if (it.folate != null) {
                            hashMapData["folate"] = it.folate!!.inGrams
                        }
                        if (it.folicAcid != null) {
                            hashMapData["folicAcid"] = it.folicAcid!!.inGrams
                        }
                        if (it.iodine != null) {
                            hashMapData["iodine"] = it.iodine!!.inGrams
                        }
                        if (it.iron != null) {
                            hashMapData["iron"] = it.iron!!.inGrams
                        }
                        if (it.magnesium != null) {
                            hashMapData["magnesium"] = it.magnesium!!.inGrams
                        }
                        if (it.manganese != null) {
                            hashMapData["manganese"] = it.manganese!!.inGrams
                        }
                        if (it.molybdenum != null) {
                            hashMapData["molybdenum"] = it.molybdenum!!.inGrams
                        }
                        if (it.monounsaturatedFat != null) {
                            hashMapData["monounsaturatedFat"] = it.monounsaturatedFat!!.inGrams
                        }
                        if (it.niacin != null) {
                            hashMapData["niacin"] = it.niacin!!.inGrams
                        }
                        if (it.pantothenicAcid != null) {
                            hashMapData["pantothenicAcid"] = it.pantothenicAcid!!.inGrams
                        }
                        if (it.phosphorus != null) {
                            hashMapData["phosphorus"] = it.phosphorus!!.inGrams
                        }
                        if (it.polyunsaturatedFat != null) {
                            hashMapData["polyunsaturatedFat"] =
                                it.polyunsaturatedFat!!.inGrams
                        }
                        if (it.potassium != null) {
                            hashMapData["potassium"] = it.potassium!!.inGrams
                        }
                        if (it.protein != null) {
                            hashMapData["protein"] = it.protein!!.inGrams
                        }
                        if (it.riboflavin != null) {
                            hashMapData["riboflavin"] = it.riboflavin!!.inGrams
                        }
                        if (it.saturatedFat != null) {
                            hashMapData["saturatedFat"] = it.saturatedFat!!.inGrams
                        }
                        if (it.selenium != null) {
                            hashMapData["selenium"] = it.selenium!!.inGrams
                        }
                        if (it.sodium != null) {
                            hashMapData["sodium"] = it.sodium!!.inGrams
                        }
                        if (it.sugar != null) {
                            hashMapData["sugar"] = it.sugar!!.inGrams
                        }
                        if (it.thiamin != null) {
                            hashMapData["thiamin"] = it.thiamin!!.inGrams
                        }
                        if (it.totalCarbohydrate != null) {
                            hashMapData["totalCarbohydrate"] =
                                it.totalCarbohydrate!!.inGrams
                        }
                        if (it.totalFat != null) {
                            hashMapData["totalFat"] = it.totalFat!!.inGrams
                        }
                        if (it.transFat != null) {
                            hashMapData["transFat"] = it.transFat!!.inGrams
                        }
                        if (it.unsaturatedFat != null) {
                            hashMapData["unsaturatedFat"] = it.unsaturatedFat!!.inGrams
                        }
                        if (it.vitaminA != null) {
                            hashMapData["vitaminA"] = it.vitaminA!!.inGrams
                        }
                        if (it.vitaminB12 != null) {
                            hashMapData["vitaminB12"] = it.vitaminB12!!.inGrams
                        }
                        if (it.vitaminB6 != null) {
                            hashMapData["vitaminB6"] = it.vitaminB6!!.inGrams
                        }
                        if (it.vitaminC != null) {
                            hashMapData["vitaminC"] = it.vitaminC!!.inGrams
                        }
                        if (it.vitaminD != null) {
                            hashMapData["vitaminD"] = it.vitaminD!!.inGrams
                        }
                        if (it.vitaminE != null) {
                            hashMapData["vitaminE"] = it.vitaminE!!.inGrams
                        }
                        if (it.vitaminK != null) {
                            hashMapData["vitaminK"] = it.vitaminK!!.inGrams
                        }
                        if (it.zinc != null) {
                            hashMapData["zinc"] = it.zinc!!.inGrams
                        }
                        if (it.name != null) {
                            hashMapData["name"] = "${it.name}"
                        }
                        if (it.mealType != null) {
                            hashMapData["mealType"] = "${it.mealType}"
                        }
                        return@mapIndexed hashMapData
                    }
                    activity!!.runOnUiThread { result.success(healthData) }
                }
            }
        }
    }

    private fun deleteHealthConnectData(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val type = call.argument<String>("dataTypeKey")!!
        val uID = call.argument<String>("uID")!!
        mResult = result
        if (type == WEIGHT) {
            CoroutineScope(Dispatchers.Main).launch {
                healthConnectClient.deleteRecords(
                    WeightRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
        } else if (type == BODY_FAT_PERCENTAGE) {
            CoroutineScope(Dispatchers.Main).launch {
                healthConnectClient.deleteRecords(
                    BodyFatRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
        } else if (type == NUTRITION) {
            CoroutineScope(Dispatchers.Main).launch {
                healthConnectClient.deleteRecords(
                    NutritionRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
        }

    }

    private fun deleteHealthConnectDataByDateRange(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val type = call.argument<String>("dataTypeKey")!!
        val startTime = call.argument<String>("startTime")!!
        val endTime = call.argument<String>("endTime")!!
        mResult = result

        when (type) {
            WEIGHT -> {
                val startDate = ZonedDateTime.parse(
                    startTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                CoroutineScope(Dispatchers.Main).launch {
                    healthConnectClient.deleteRecords(
                        WeightRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(
                            startDate.toInstant(),
                            endDate.toInstant()
                        )
                    )
                    result.success(true)
                }
            }
            BODY_FAT_PERCENTAGE -> {
                val startDate = ZonedDateTime.parse(
                    startTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )

                CoroutineScope(Dispatchers.Main).launch {
                    healthConnectClient.deleteRecords(
                        BodyFatRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(
                            startDate.toInstant(),
                            endDate.toInstant()
                        )
                    )
                    result.success(true)
                }
            }
            NUTRITION -> {
                val startDate = ZonedDateTime.parse(
                    startTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDate = ZonedDateTime.parse(
                    endTime,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )

                CoroutineScope(Dispatchers.Main).launch {
                    healthConnectClient.deleteRecords(
                        NutritionRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(
                            startDate.toInstant(),
                            endDate.toInstant()
                        )
                    )
                    result.success(true)
                }
            }
        }
    }

    private fun dateTimeWithOffsetOrDefault(time: Instant, offset: ZoneOffset?): ZonedDateTime =
        if (offset != null) {
            ZonedDateTime.ofInstant(time, offset)
        } else {
            ZonedDateTime.ofInstant(time, ZoneId.systemDefault())
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
        val typesBuilder = FitnessOptions.builder()
        typesBuilder.addDataType(dataType)
        if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
            typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
        }
        val fitnessOptions = typesBuilder.build()
        val googleSignInAccount =
            GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

        if (dataType != DataType.TYPE_SLEEP_SEGMENT) {
            Fitness.getHistoryClient(activity!!.applicationContext, googleSignInAccount)
                .readData(
                    DataReadRequest.Builder()
                        .read(dataType)
                        .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                        .build()
                )
                .addOnSuccessListener(threadPoolExecutor!!, dataHandler(dataType, field, result))
                .addOnFailureListener(errHandler(result))
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
                .addOnSuccessListener(threadPoolExecutor!!, sleepDataHandler(type, result))
                .addOnFailureListener(errHandler(result))
        }

    }

    private fun dataHandler(dataType: DataType, field: Field, result: Result) =
        OnSuccessListener { response: DataReadResponse ->
            /// Fetch all data points for the specified DataType
            val dataSet = response.getDataSet(dataType)
            /// For each data point, extract the contents and send them to Flutter, along with date and unit.
            val healthData = dataSet.dataPoints.mapIndexed { _, dataPoint ->
                return@mapIndexed hashMapOf(
                    "value" to getHealthDataValue(dataPoint, field),
                    "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                    "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                    "source_name" to (dataPoint.originalDataSource.appPackageName
                        ?: (dataPoint.originalDataSource.device?.model
                            ?: "")),
                    "source_id" to dataPoint.originalDataSource.streamIdentifier
                )
            }
            activity!!.runOnUiThread { result.success(healthData) }
        }

    private fun errHandler(result: Result) = OnFailureListener { exception ->
        activity!!.runOnUiThread { result.success(null) }
        Log.i("FLUTTER_HEALTH::ERROR", exception.message ?: "unknown error")
        Log.i("FLUTTER_HEALTH::ERROR", exception.stackTrace.toString())
    }

    private fun sleepDataHandler(type: String, result: Result) =
        OnSuccessListener { response: SessionReadResponse ->
            val healthData: MutableList<Map<String, Any?>> = mutableListOf()
            for (session in response.sessions) {

                // Return sleep time in Minutes if requested ASLEEP data
                if (type == SLEEP_ASLEEP) {
                    healthData.add(
                        hashMapOf(
                            "value" to session.getEndTime(TimeUnit.MINUTES) - session.getStartTime(
                                TimeUnit.MINUTES
                            ),
                            "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
                            "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
                            "unit" to "MINUTES",
                            "source_name" to session.appPackageName,
                            "source_id" to session.identifier
                        )
                    )
                }

                if (type == SLEEP_IN_BED) {
                    val dataSets = response.getDataSet(session)

                    // If the sleep session has finer granularity sub-components, extract them:
                    if (dataSets.isNotEmpty()) {
                        for (dataSet in dataSets) {
                            for (dataPoint in dataSet.dataPoints) {
                                // searching OUT OF BED data
                                if (dataPoint.getValue(Field.FIELD_SLEEP_SEGMENT_TYPE)
                                        .asInt() != 3
                                ) {
                                    healthData.add(
                                        hashMapOf(
                                            "value" to dataPoint.getEndTime(TimeUnit.MINUTES) - dataPoint.getStartTime(
                                                TimeUnit.MINUTES
                                            ),
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
                                "value" to session.getEndTime(TimeUnit.MINUTES) - session.getStartTime(
                                    TimeUnit.MINUTES
                                ),
                                "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
                                "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
                                "unit" to "MINUTES",
                                "source_name" to session.appPackageName,
                                "source_id" to session.identifier
                            )
                        )
                    }
                }

                if (type == SLEEP_AWAKE) {
                    val dataSets = response.getDataSet(session)
                    for (dataSet in dataSets) {
                        for (dataPoint in dataSet.dataPoints) {
                            // searching SLEEP AWAKE data
                            if (dataPoint.getValue(Field.FIELD_SLEEP_SEGMENT_TYPE).asInt() == 1) {
                                healthData.add(
                                    hashMapOf(
                                        "value" to dataPoint.getEndTime(TimeUnit.MINUTES) - dataPoint.getStartTime(
                                            TimeUnit.MINUTES
                                        ),
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


    private fun callToHealthTypes(call: MethodCall): FitnessOptions {
        val typesBuilder = FitnessOptions.builder()
        val args = call.arguments as HashMap<*, *>
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
            if (typeKey == SLEEP_ASLEEP || typeKey == SLEEP_AWAKE || typeKey == SLEEP_IN_BED) {
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

    private fun callToHealthConnectTypes(call: MethodCall): Set<String> {
        val listPermission = arrayListOf<String>()

        val args = call.arguments as HashMap<*, *>
        val types = (args["types"] as? ArrayList<*>)?.filterIsInstance<String>()
        val permissions = (args["permissions"] as? ArrayList<*>)?.filterIsInstance<Int>()

        assert(types != null)
        assert(permissions != null)
        assert(types!!.count() == permissions!!.count())

        for ((i, typeKey) in types.withIndex()) {
            val access = permissions[i]
            val dataType: KClass<out Record> = when (typeKey) {
                WEIGHT -> {
                    WeightRecord::class
                }
                NUTRITION -> {
                    NutritionRecord::class
                }
                BODY_FAT_PERCENTAGE -> {
                    BodyFatRecord::class
                }
                else -> throw IllegalArgumentException("Unknown access type $access")
            }
            when (access) {
                0 -> {
                    listPermission.add(HealthPermission.getReadPermission(dataType))
                }
                1 -> {
                    listPermission.add(HealthPermission.getWritePermission(dataType))
                }
                2 -> {
                    listPermission.add(HealthPermission.getWritePermission(dataType))
                    listPermission.add(HealthPermission.getReadPermission(dataType))
                }
                else -> throw IllegalArgumentException("Unknown access type $access")
            }
        }
        return listPermission.toSet()
    }

    private fun hasPermissionHealthConnect(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val permissionList = callToHealthConnectTypes(call)
        mResult = result

        CoroutineScope(Dispatchers.Main).launch {
            val granted = healthConnectClient.permissionController.getGrantedPermissions()

            if (granted.containsAll(permissionList.toSet())) {
                mResult?.success(true)
            } else {
                mResult?.success(false)
                // Do we need to request here?
            }
        }
    }

    var healthConnectAvailable = false

    private fun isHealthConnectAvailable(activityLocal: Activity?, call: MethodCall, result: Result) {
        if (activityLocal == null) {
            result.success(false)
            return
        }

        val install = call.argument<Boolean>("install")!!

        val sdkStatus = HealthConnectClient.getSdkStatus(activityLocal)
        val success = sdkStatus == HealthConnectClient.SDK_AVAILABLE

        healthConnectAvailable = success;

        Log.i("FLUTTER_HEALTH", "isHealthConnectAvailable")
        Log.i("FLUTTER_HEALTH", healthConnectAvailable.toString())

        if (sdkStatus == HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED && install) {
            try {
                val providerPackageName = "com.google.android.apps.healthdata"
                val uriString = "market://details?id=$providerPackageName&url=healthconnect%3A%2F%2Fonboarding"

                activityLocal.startActivity(
                    Intent(Intent.ACTION_VIEW).apply {
                        setPackage("com.android.vending")
                        data = Uri.parse(uriString)
                        putExtra("overlay", true)
                        putExtra("callerId", activityLocal.packageName)
                    })

                result.success(false)
                return
            } catch (e: Throwable) {
                print(e.message)
                result.success(false)
                return
            }
        }

        result.success(success)
    }

    private fun requestHealthConnectPermission(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        mResult = result
        val permissionList = callToHealthConnectTypes(call)

        if(healthConnectRequestPermissionsLauncher == null) {
            result.success(false)
            Log.i("FLUTTER_HEALTH", "Permission launcher not found")
            return;
        }


        healthConnectRequestPermissionsLauncher!!.launch(permissionList.toSet());
    }

    private  fun onHealthConnectPermissionCallback(permissionGranted: Set<String>)
    {
        if(permissionGranted.isEmpty()) {
            mResult?.success(false);
            Log.i("FLUTTER_HEALTH", "Access Denied (to Health Connect)!")

        }else {
            mResult?.success(true);
            Log.i("FLUTTER_HEALTH", "Access Granted (to Health Connect)!")
        }

    }


    private fun getTotalStepsInInterval(call: MethodCall, result: Result) {
        val start = call.argument<Long>("startDate")!!
        val end = call.argument<Long>("endDate")!!

        val activity = activity ?: return

        val stepsDataType = keyToHealthDataType(STEPS)
        val aggregatedDataType = keyToHealthDataType(AGGREGATE_STEP_COUNT)

        val fitnessOptions = FitnessOptions.builder()
            .addDataType(stepsDataType)
            .addDataType(aggregatedDataType)
            .build()
        val gsa = GoogleSignIn.getAccountForExtension(activity, fitnessOptions)

        val ds = DataSource.Builder()
            .setAppPackageName("com.google.android.gms")
            .setDataType(stepsDataType)
            .setType(DataSource.TYPE_DERIVED)
            .setStreamName("estimated_steps")
            .build()

        val duration = (end - start).toInt()

        val request = DataReadRequest.Builder()
            .aggregate(ds)
            .bucketByTime(duration, TimeUnit.MILLISECONDS)
            .setTimeRange(start, end, TimeUnit.MILLISECONDS)
            .build()

        Fitness.getHistoryClient(activity, gsa).readData(request)
            .addOnFailureListener(errHandler(result))
            .addOnSuccessListener(
                threadPoolExecutor!!,
                getStepsInRange(start, end, aggregatedDataType, result)
            )

    }


    private fun getStepsInRange(
        start: Long,
        end: Long,
        aggregatedDataType: DataType,
        result: Result
    ) =
        OnSuccessListener { response: DataReadResponse ->

            val map = HashMap<Long, Int>() // need to return to Dart so can't use sparse array
            for (bucket in response.buckets) {
                val dp = bucket.dataSets.firstOrNull()?.dataPoints?.firstOrNull()
                if (dp != null) {
                    print(dp)

                    val count = dp.getValue(aggregatedDataType.fields[0])

                    val startTime = dp.getStartTime(TimeUnit.MILLISECONDS)
                    val startDate = Date(startTime)
                    val endDate = Date(dp.getEndTime(TimeUnit.MILLISECONDS))
                    Log.i(
                        "FLUTTER_HEALTH::SUCCESS",
                        "returning $count steps for $startDate - $endDate"
                    )
                    map[startTime] = count.asInt()
                } else {
                    val startDay = Date(start)
                    val endDay = Date(end)
                    Log.i("FLUTTER_HEALTH::ERROR", "no steps for $startDay - $endDay")
                }
            }

            assert(map.size <= 1) { "getTotalStepsInInterval should return only one interval. Found: ${map.size}" }
            activity!!.runOnUiThread {
                result.success(map.values.firstOrNull())
            }
        }

    /// Handle calls from the MethodChannel
    override fun onMethodCall(call: MethodCall, result: Result) {
        val activityContext = activity

        when (call.method) {
            "getData" -> getData(call, result)
            "deleteData" -> deleteData(call, result)
            "deleteFoodData" -> deleteFoodData(call, result)
            "writeData" -> writeData(call, result)
            "writeFoodData" -> writeFoodData(call, result)
            "getTotalStepsInInterval" -> getTotalStepsInInterval(call, result)
            "hasPermissionsHealthConnect" -> hasPermissionHealthConnect(call, result)
            "writeDataHealthConnect" -> writeDataHealthConnect(call, result)
            "getHealthConnectData" -> getHealthConnectData(call, result)
            "deleteHealthConnectData" -> deleteHealthConnectData(call, result)
            "requestHealthConnectPermission" -> requestHealthConnectPermission(call, result)
            "isHealthConnectAvailable" -> isHealthConnectAvailable(activityContext, call, result)
            "deleteHealthConnectDataByDateRange" -> deleteHealthConnectDataByDateRange(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (channel == null) {
            return
        }
        binding.addActivityResultListener(this)
        activity = binding.activity

        Log.i("FLUTTER_HEALTH", "onAttachedToActivity")
        Log.i("FLUTTER_HEALTH", healthConnectAvailable.toString())

        if (healthConnectAvailable) {
            val requestPermissionActivityContract = PermissionController.createRequestPermissionResultContract()

            healthConnectRequestPermissionsLauncher =(activity as ComponentActivity).registerForActivityResult(requestPermissionActivityContract) { granted ->
                onHealthConnectPermissionCallback(granted);
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
        healthConnectRequestPermissionsLauncher = null;
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