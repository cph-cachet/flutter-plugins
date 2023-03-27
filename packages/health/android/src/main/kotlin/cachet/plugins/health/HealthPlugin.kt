package cachet.plugins.health

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessActivities
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.request.DataDeleteRequest
import com.google.android.gms.fitness.request.SessionInsertRequest
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
import java.security.Permission
import java.util.*
import java.util.concurrent.*
import java.util.concurrent.TimeUnit


const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111
const val CHANNEL_NAME = "flutter_health"
const val MMOLL_2_MGDL = 18.0 // 1 mmoll= 18 mgdl

class HealthPlugin(private var channel: MethodChannel? = null) : MethodCallHandler, 
ActivityResultListener, Result, ActivityAware, FlutterPlugin { 
  private var mResult: Result? = null
  private var handler: Handler? = null
  private var activity: Activity? = null
  private var context: Context? = null
  private var threadPoolExecutor: ExecutorService? = null

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
  private var WORKOUT = "WORKOUT"

  val workoutTypeMap = mapOf(
    "AEROBICS" to FitnessActivities.AEROBICS,
    "AMERICAN_FOOTBALL" to FitnessActivities.FOOTBALL_AMERICAN,
    "ARCHERY" to FitnessActivities.ARCHERY,
    "AUSTRALIAN_FOOTBALL" to FitnessActivities.FOOTBALL_AUSTRALIAN,
    "BADMINTON" to FitnessActivities.BADMINTON,
    "BASEBALL" to FitnessActivities.BASEBALL,
    "BASKETBALL" to FitnessActivities.BASKETBALL,
    "BIATHLON" to FitnessActivities.BIATHLON,
    "BIKING" to FitnessActivities.BIKING,
    "BIKING_HAND" to FitnessActivities.BIKING_HAND,
    "BIKING_MOUNTAIN" to FitnessActivities.BIKING_MOUNTAIN,
    "BIKING_ROAD" to FitnessActivities.BIKING_ROAD,
    "BIKING_SPINNING" to FitnessActivities.BIKING_SPINNING,
    "BIKING_STATIONARY" to FitnessActivities.BIKING_STATIONARY,
    "BIKING_UTILITY" to FitnessActivities.BIKING_UTILITY,
    "BOXING" to FitnessActivities.BOXING,
    "CALISTHENICS" to FitnessActivities.CALISTHENICS,
    "CIRCUIT_TRAINING" to FitnessActivities.CIRCUIT_TRAINING,
    "CRICKET" to FitnessActivities.CRICKET,
    "CROSS_COUNTRY_SKIING" to FitnessActivities.SKIING_CROSS_COUNTRY,
    "CROSS_FIT" to FitnessActivities.CROSSFIT,
    "CURLING" to FitnessActivities.CURLING,
    "DANCING" to FitnessActivities.DANCING,
    "DIVING" to FitnessActivities.DIVING,
    "DOWNHILL_SKIING" to FitnessActivities.SKIING_DOWNHILL,
    "ELEVATOR" to FitnessActivities.ELEVATOR,
    "ELLIPTICAL" to FitnessActivities.ELLIPTICAL,
    "ERGOMETER" to FitnessActivities.ERGOMETER,
    "ESCALATOR" to FitnessActivities.ESCALATOR,
    "FENCING" to FitnessActivities.FENCING,
    "FRISBEE_DISC" to FitnessActivities.FRISBEE_DISC,
    "GARDENING" to FitnessActivities.GARDENING,
    "GOLF" to FitnessActivities.GOLF,
    "GUIDED_BREATHING" to FitnessActivities.GUIDED_BREATHING,
    "GYMNASTICS" to FitnessActivities.GYMNASTICS,
    "HANDBALL" to FitnessActivities.HANDBALL,
    "HIGH_INTENSITY_INTERVAL_TRAINING" to FitnessActivities.HIGH_INTENSITY_INTERVAL_TRAINING,
    "HIKING" to FitnessActivities.HIKING,
    "HOCKEY" to FitnessActivities.HOCKEY,
    "HORSEBACK_RIDING" to FitnessActivities.HORSEBACK_RIDING,
    "HOUSEWORK" to FitnessActivities.HOUSEWORK,
    "IN_VEHICLE" to FitnessActivities.IN_VEHICLE,
    "ICE_SKATING" to FitnessActivities.ICE_SKATING,
    "INTERVAL_TRAINING" to FitnessActivities.INTERVAL_TRAINING,
    "JUMP_ROPE" to FitnessActivities.JUMP_ROPE,
    "KAYAKING" to FitnessActivities.KAYAKING,
    "KETTLEBELL_TRAINING" to FitnessActivities.KETTLEBELL_TRAINING,
    "KICK_SCOOTER" to FitnessActivities.KICK_SCOOTER,
    "KICKBOXING" to FitnessActivities.KICKBOXING,
    "KITE_SURFING" to FitnessActivities.KITESURFING,
    "MARTIAL_ARTS" to FitnessActivities.MARTIAL_ARTS,
    "MEDITATION" to FitnessActivities.MEDITATION,
    "MIXED_MARTIAL_ARTS" to FitnessActivities.MIXED_MARTIAL_ARTS,
    "P90X" to FitnessActivities.P90X,
    "PARAGLIDING" to FitnessActivities.PARAGLIDING,
    "PILATES" to FitnessActivities.PILATES,
    "POLO" to FitnessActivities.POLO,
    "RACQUETBALL" to FitnessActivities.RACQUETBALL,
    "ROCK_CLIMBING" to FitnessActivities.ROCK_CLIMBING,
    "ROWING" to FitnessActivities.ROWING,
    "ROWING_MACHINE" to FitnessActivities.ROWING_MACHINE,
    "RUGBY" to FitnessActivities.RUGBY,
    "RUNNING_JOGGING" to FitnessActivities.RUNNING_JOGGING,
    "RUNNING_SAND" to FitnessActivities.RUNNING_SAND,
    "RUNNING_TREADMILL" to FitnessActivities.RUNNING_TREADMILL,
    "RUNNING" to FitnessActivities.RUNNING,
    "SAILING" to FitnessActivities.SAILING,
    "SCUBA_DIVING" to FitnessActivities.SCUBA_DIVING,
    "SKATING_CROSS" to FitnessActivities.SKATING_CROSS,
    "SKATING_INDOOR" to FitnessActivities.SKATING_INDOOR,
    "SKATING_INLINE" to FitnessActivities.SKATING_INLINE,
    "SKATING" to FitnessActivities.SKATING,
    "SKIING" to FitnessActivities.SKIING,
    "SKIING_BACK_COUNTRY" to FitnessActivities.SKIING_BACK_COUNTRY,
    "SKIING_KITE" to FitnessActivities.SKIING_KITE,
    "SKIING_ROLLER" to FitnessActivities.SKIING_ROLLER,
    "SLEDDING" to FitnessActivities.SLEDDING,
    "SNOWBOARDING" to FitnessActivities.SNOWBOARDING,
    "SNOWMOBILE" to FitnessActivities.SNOWMOBILE,
    "SNOWSHOEING" to FitnessActivities.SNOWSHOEING,
    "SOCCER" to FitnessActivities.FOOTBALL_SOCCER,
    "SOFTBALL" to FitnessActivities.SOFTBALL,
    "SQUASH" to FitnessActivities.SQUASH,
    "STAIR_CLIMBING_MACHINE" to FitnessActivities.STAIR_CLIMBING_MACHINE,
    "STAIR_CLIMBING" to FitnessActivities.STAIR_CLIMBING,
    "STANDUP_PADDLEBOARDING" to FitnessActivities.STANDUP_PADDLEBOARDING,
    "STILL" to FitnessActivities.STILL,
    "STRENGTH_TRAINING" to FitnessActivities.STRENGTH_TRAINING,
    "SURFING" to FitnessActivities.SURFING,
    "SWIMMING_OPEN_WATER" to FitnessActivities.SWIMMING_OPEN_WATER,
    "SWIMMING_POOL" to FitnessActivities.SWIMMING_POOL,
    "SWIMMING" to FitnessActivities.SWIMMING,
    "TABLE_TENNIS" to FitnessActivities.TABLE_TENNIS,
    "TEAM_SPORTS" to FitnessActivities.TEAM_SPORTS,
    "TENNIS" to FitnessActivities.TENNIS,
    "TILTING" to FitnessActivities.TILTING,
    "VOLLEYBALL_BEACH" to FitnessActivities.VOLLEYBALL_BEACH,
    "VOLLEYBALL_INDOOR" to FitnessActivities.VOLLEYBALL_INDOOR,
    "VOLLEYBALL" to FitnessActivities.VOLLEYBALL,
    "WAKEBOARDING" to FitnessActivities.WAKEBOARDING,
    "WALKING_FITNESS" to FitnessActivities.WALKING_FITNESS,
    "WALKING_PACED" to FitnessActivities.WALKING_PACED,
    "WALKING_NORDIC" to FitnessActivities.WALKING_NORDIC,
    "WALKING_STROLLER" to FitnessActivities.WALKING_STROLLER,
    "WALKING_TREADMILL" to FitnessActivities.WALKING_TREADMILL,
    "WALKING" to FitnessActivities.WALKING,
    "WATER_POLO" to FitnessActivities.WATER_POLO,
    "WEIGHTLIFTING" to FitnessActivities.WEIGHTLIFTING,
    "WHEELCHAIR" to FitnessActivities.WHEELCHAIR,
    "WINDSURFING" to FitnessActivities.WINDSURFING,
    "YOGA" to FitnessActivities.YOGA,
    "ZUMBA" to FitnessActivities.ZUMBA,
    "OTHER" to FitnessActivities.OTHER,
  )

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    channel?.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext;
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

  override fun success(p0: Any?) {
    handler?.post { mResult?.success(p0) }
  }

  override fun notImplemented() {
    handler?.post { mResult?.notImplemented() }
  }

  override fun error(
    errorCode: String, errorMessage: String?, errorDetails: Any?
  ) {
    handler?.post { mResult?.error(errorCode, errorMessage, errorDetails) }
  }


  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == GOOGLE_FIT_PERMISSIONS_REQUEST_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        Log.i("FLUTTER_HEALTH", "Access Granted!")
        mResult?.success(true)
      } else if (resultCode == Activity.RESULT_CANCELED) {
        Log.i("FLUTTER_HEALTH", "Access Denied!")
        mResult?.success(false)
      }
    }
    return false
  }


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
      WORKOUT -> DataType.TYPE_ACTIVITY_SEGMENT
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
      WORKOUT -> Field.FIELD_ACTIVITY
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

  /** 
   * Delete records of the given type in the time range
   */
  private fun delete(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val type = call.argument<String>("dataTypeKey")!!
    val startTime = call.argument<Long>("startTime")!!
    val endTime = call.argument<Long>("endTime")!!

    // Look up data type and unit for the type key
    val dataType = keyToHealthDataType(type)
    val field = getField(type)

    val typesBuilder = FitnessOptions.builder()
    typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

    val dataSource = DataDeleteRequest.Builder()
      .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
      .addDataType(dataType)
      .deleteAllSessions()
      .build()

    val fitnessOptions = typesBuilder.build()

    try {
      val googleSignInAccount =
        GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
      Fitness.getHistoryClient(context!!.applicationContext, googleSignInAccount)
        .deleteData(dataSource)
        .addOnSuccessListener {
          Log.i("FLUTTER_HEALTH::SUCCESS", "Dataset deleted successfully!")
          result.success(true)
        }
        .addOnFailureListener(errHandler(result, "There was an error deleting the dataset"))
    } catch (e3: Exception) {
      result.success(false)
    }
  }

  /** 
   * Save a Blood Pressure measurement with systolic and diastolic values
   */
  private fun writeBloodPressure(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val dataType = HealthDataTypes.TYPE_BLOOD_PRESSURE
    val systolic = call.argument<Float>("systolic")!!
    val diastolic = call.argument<Float>("diastolic")!!
    val startTime = call.argument<Long>("startTime")!!
    val endTime = call.argument<Long>("endTime")!!

    val typesBuilder = FitnessOptions.builder()
    typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

    val dataSource = DataSource.Builder()
      .setDataType(dataType)
      .setType(DataSource.TYPE_RAW)
      .setDevice(Device.getLocalDevice(context!!.applicationContext))
      .setAppPackageName(context!!.applicationContext)
      .build()

    val builder = DataPoint.builder(dataSource)
      .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
      .setField(HealthFields.FIELD_BLOOD_PRESSURE_SYSTOLIC, systolic)
      .setField(HealthFields.FIELD_BLOOD_PRESSURE_DIASTOLIC, diastolic)
      .build()

    val dataPoint = builder
    val dataSet = DataSet.builder(dataSource)
      .add(dataPoint)
      .build()

    val fitnessOptions = typesBuilder.build()
    try {
      val googleSignInAccount =
        GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
      Fitness.getHistoryClient(context!!.applicationContext, googleSignInAccount)
        .insertData(dataSet)
        .addOnSuccessListener {
          Log.i("FLUTTER_HEALTH::SUCCESS", "Blood Pressure added successfully!")
          result.success(true)
        }
        .addOnFailureListener(
          errHandler(
            result,
            "There was an error adding the blood pressure data!"
          )
        )
    } catch (e3: Exception) {
      result.success(false)
    }
  }

  /** 
   * Save a data type in Google Fit
   */
  private fun writeData(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val type = call.argument<String>("dataTypeKey")!!
    val startTime = call.argument<Long>("startTime")!!
    val endTime = call.argument<Long>("endTime")!!
    val value = call.argument<Float>("value")!!

    // Look up data type and unit for the type key
    val dataType = keyToHealthDataType(type)
    val field = getField(type)

    val typesBuilder = FitnessOptions.builder()
    typesBuilder.addDataType(dataType, FitnessOptions.ACCESS_WRITE)

    val dataSource = DataSource.Builder()
      .setDataType(dataType)
      .setType(DataSource.TYPE_RAW)
      .setDevice(Device.getLocalDevice(context!!.applicationContext))
      .setAppPackageName(context!!.applicationContext)
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
      builder.setField(field, (if (!isGlucose) value else (value / MMOLL_2_MGDL).toFloat()))
        .build() else
      builder.setField(field, value.toInt()).build()

    val dataSet = DataSet.builder(dataSource)
      .add(dataPoint)
      .build()

    if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
      typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
    }
    val fitnessOptions = typesBuilder.build()
    try {
      val googleSignInAccount =
        GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
      Fitness.getHistoryClient(context!!.applicationContext, googleSignInAccount)
        .insertData(dataSet)
        .addOnSuccessListener {
          Log.i("FLUTTER_HEALTH::SUCCESS", "Dataset added successfully!")
          result.success(true)
        }
        .addOnFailureListener(errHandler(result, "There was an error adding the dataset"))
    } catch (e3: Exception) {
      result.success(false)
    }
  }

  /**
   * Save a Workout session with options for distance and calories expended
   */
  private fun writeWorkoutData(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val type = call.argument<String>("activityType")!!
    val startTime = call.argument<Long>("startTime")!!
    val endTime = call.argument<Long>("endTime")!!
    val totalEnergyBurned = call.argument<Int>("totalEnergyBurned")
    val totalDistance = call.argument<Int>("totalDistance")

    val activityType = getActivityType(type)
    // Create the Activity Segment DataSource
    val activitySegmentDataSource = DataSource.Builder()
      .setAppPackageName(context!!.packageName)
      .setDataType(DataType.TYPE_ACTIVITY_SEGMENT)
      .setStreamName("FLUTTER_HEALTH - Activity")
      .setType(DataSource.TYPE_RAW)
      .build()
    // Create the Activity Segment
    val activityDataPoint = DataPoint.builder(activitySegmentDataSource)
      .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
      .setActivityField(Field.FIELD_ACTIVITY, activityType)
      .build()
    // Add DataPoint to DataSet
    val activitySegments = DataSet.builder(activitySegmentDataSource)
      .add(activityDataPoint)
      .build()

    // If distance is provided
    var distanceDataSet: DataSet? = null
    if (totalDistance != null) {
      // Create a data source
      val distanceDataSource = DataSource.Builder()
        .setAppPackageName(context!!.packageName)
        .setDataType(DataType.TYPE_DISTANCE_DELTA)
        .setStreamName("FLUTTER_HEALTH - Distance")
        .setType(DataSource.TYPE_RAW)
        .build()

      val distanceDataPoint = DataPoint.builder(distanceDataSource)
        .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
        .setField(Field.FIELD_DISTANCE, totalDistance.toFloat())
        .build()
      // Create a data set
      distanceDataSet = DataSet.builder(distanceDataSource)
        .add(distanceDataPoint)
        .build()
    }
    // If energyBurned is provided
    var energyDataSet: DataSet? = null
    if (totalEnergyBurned != null) {
      // Create a data source
      val energyDataSource = DataSource.Builder()
        .setAppPackageName(context!!.packageName)
        .setDataType(DataType.TYPE_CALORIES_EXPENDED)
        .setStreamName("FLUTTER_HEALTH - Calories")
        .setType(DataSource.TYPE_RAW)
        .build()

      val energyDataPoint = DataPoint.builder(energyDataSource)
        .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
        .setField(Field.FIELD_CALORIES, totalEnergyBurned.toFloat())
        .build()
      // Create a data set
      energyDataSet = DataSet.builder(energyDataSource)
        .add(energyDataPoint)
        .build()
    }

    // Finish session setup
    val session = Session.Builder()
      .setName(activityType) // TODO: Make a sensible name / allow user to set name
      .setDescription("")
      .setIdentifier(UUID.randomUUID().toString())
      .setActivity(activityType)
      .setStartTime(startTime, TimeUnit.MILLISECONDS)
      .setEndTime(endTime, TimeUnit.MILLISECONDS)
      .build()
    // Build a session and add the values provided
    val sessionInsertRequestBuilder = SessionInsertRequest.Builder()
      .setSession(session)
      .addDataSet(activitySegments)
    if (totalDistance != null) {
      sessionInsertRequestBuilder.addDataSet(distanceDataSet!!)
    }
    if (totalEnergyBurned != null) {
      sessionInsertRequestBuilder.addDataSet(energyDataSet!!)
    }
    val insertRequest = sessionInsertRequestBuilder.build()

    val fitnessOptionsBuilder = FitnessOptions.builder()
      .addDataType(DataType.TYPE_ACTIVITY_SEGMENT, FitnessOptions.ACCESS_WRITE)
    if (totalDistance != null) {
      fitnessOptionsBuilder.addDataType(DataType.TYPE_DISTANCE_DELTA, FitnessOptions.ACCESS_WRITE)
    }
    if (totalEnergyBurned != null) {
      fitnessOptionsBuilder.addDataType(
        DataType.TYPE_CALORIES_EXPENDED,
        FitnessOptions.ACCESS_WRITE
      )
    }
    val fitnessOptions = fitnessOptionsBuilder.build()

    try {
      val googleSignInAccount =
        GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
      Fitness.getSessionsClient(
        context!!.applicationContext,
        googleSignInAccount
      )
        .insertSession(insertRequest)
        .addOnSuccessListener {
          Log.i("FLUTTER_HEALTH::SUCCESS", "Workout was successfully added!")
          result.success(true)
        }
        .addOnFailureListener(errHandler(result, "There was an error adding the workout"))
    } catch (e: Exception) {
      result.success(false)
    }
  }

  /**
   * Get all datapoints of the DataType within the given time range
   */
  private fun getData(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(null)
      return
    }

    val type = call.argument<String>("dataTypeKey")!!
    val startTime = call.argument<Long>("startTime")!!
    val endTime = call.argument<Long>("endTime")!!
    // Look up data type and unit for the type key
    val dataType = keyToHealthDataType(type)
    val field = getField(type)
    val typesBuilder = FitnessOptions.builder()
    typesBuilder.addDataType(dataType)

    // Add special cases for accessing workouts or sleep data.
    if (dataType == DataType.TYPE_SLEEP_SEGMENT) {
      typesBuilder.accessSleepSessions(FitnessOptions.ACCESS_READ)
    } else if (dataType == DataType.TYPE_ACTIVITY_SEGMENT) {
      typesBuilder.accessActivitySessions(FitnessOptions.ACCESS_READ)
        .addDataType(DataType.TYPE_CALORIES_EXPENDED, FitnessOptions.ACCESS_READ)
        .addDataType(DataType.TYPE_DISTANCE_DELTA, FitnessOptions.ACCESS_READ)
    }
    val fitnessOptions = typesBuilder.build()
    val googleSignInAccount =
      GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
    // Handle data types
    when (dataType) {
      DataType.TYPE_SLEEP_SEGMENT -> {
        // request to the sessions for sleep data
        val request = SessionReadRequest.Builder()
          .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
          .enableServerQueries()
          .readSessionsFromAllApps()
          .includeSleepSessions()
          .build()
        Fitness.getSessionsClient(context!!.applicationContext, googleSignInAccount)
          .readSession(request)
          .addOnSuccessListener(threadPoolExecutor!!, sleepDataHandler(type, result))
          .addOnFailureListener(errHandler(result, "There was an error getting the sleeping data!"))
      }
      DataType.TYPE_ACTIVITY_SEGMENT -> {
        val readRequest: SessionReadRequest
        val readRequestBuilder = SessionReadRequest.Builder()
          .setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS)
          .enableServerQueries()
          .readSessionsFromAllApps()
          .includeActivitySessions()
          .read(dataType)
          .read(DataType.TYPE_CALORIES_EXPENDED)

        // If fine location is enabled, read distance data
        if (ContextCompat.checkSelfPermission(
            context!!.applicationContext,
            android.Manifest.permission.ACCESS_FINE_LOCATION
          ) == PackageManager.PERMISSION_GRANTED
        ) {
          readRequestBuilder.read(DataType.TYPE_DISTANCE_DELTA)
        }
        readRequest = readRequestBuilder.build()
        Fitness.getSessionsClient(context!!.applicationContext, googleSignInAccount)
          .readSession(readRequest)
          .addOnSuccessListener(threadPoolExecutor!!, workoutDataHandler(type, result))
          .addOnFailureListener(errHandler(result, "There was an error getting the workout data!"))
      }
      else -> {
        Fitness.getHistoryClient(context!!.applicationContext, googleSignInAccount)
          .readData(
            DataReadRequest.Builder()
              .read(dataType)
              .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
              .build()
          )
          .addOnSuccessListener(threadPoolExecutor!!, dataHandler(dataType, field, result))
          .addOnFailureListener(errHandler(result, "There was an error getting the data!"))
      }
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
      Handler(context!!.mainLooper).run { result.success(healthData) }
    }

  private fun errHandler(result: Result, addMessage: String) = OnFailureListener { exception ->
    Handler(context!!.mainLooper).run { result.success(null) }
    Log.w("FLUTTER_HEALTH::ERROR", addMessage)
    Log.w("FLUTTER_HEALTH::ERROR", exception.message ?: "unknown error")
    Log.w("FLUTTER_HEALTH::ERROR", exception.stackTrace.toString())
  }

  private fun sleepDataHandler(type: String, result: Result) =
    OnSuccessListener { response: SessionReadResponse ->
      val healthData: MutableList<Map<String, Any?>> = mutableListOf()
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
      Handler(context!!.mainLooper).run { result.success(healthData) }
    }

  private fun workoutDataHandler(type: String, result: Result) =
    OnSuccessListener { response: SessionReadResponse ->
      val healthData: MutableList<Map<String, Any?>> = mutableListOf()
      for (session in response.sessions) {
        // Look for calories and distance if they
        var totalEnergyBurned = 0.0
        var totalDistance = 0.0
        for (dataSet in response.getDataSet(session)) {
          if (dataSet.dataType == DataType.TYPE_CALORIES_EXPENDED) {
            for (dataPoint in dataSet.dataPoints) {
              totalEnergyBurned += dataPoint.getValue(Field.FIELD_CALORIES).toString().toDouble()
            }
          }
          if (dataSet.dataType == DataType.TYPE_DISTANCE_DELTA) {
            for (dataPoint in dataSet.dataPoints) {
              totalDistance += dataPoint.getValue(Field.FIELD_DISTANCE).toString().toDouble()
            }
          }
        }
        healthData.add(
          hashMapOf(
            "workoutActivityType" to (workoutTypeMap.filterValues { it == session.activity }.keys.firstOrNull()
              ?: "OTHER"),
            "totalEnergyBurned" to if (totalEnergyBurned == 0.0) null else totalEnergyBurned,
            "totalEnergyBurnedUnit" to "KILOCALORIE",
            "totalDistance" to if (totalDistance == 0.0) null else totalDistance,
            "totalDistanceUnit" to "METER",
            "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
            "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
            "unit" to "MINUTES",
            "source_name" to session.appPackageName,
            "source_id" to session.identifier
          )
        )
      }
      Handler(context!!.mainLooper).run { result.success(healthData) }
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
      if (typeKey == WORKOUT) {
        when (access) {
          0 -> typesBuilder.accessActivitySessions(FitnessOptions.ACCESS_READ)
          1 -> typesBuilder.accessActivitySessions(FitnessOptions.ACCESS_WRITE)
          2 -> {
            typesBuilder.accessActivitySessions(FitnessOptions.ACCESS_READ)
            typesBuilder.accessActivitySessions(FitnessOptions.ACCESS_WRITE)
          }
          else -> throw IllegalArgumentException("Unknown access type $access")
        }
      }

    }
    return typesBuilder.build()
  }

  private fun hasPermissions(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val optionsToRegister = callToHealthTypes(call)

    val isGranted = GoogleSignIn.hasPermissions(
      GoogleSignIn.getLastSignedInAccount(context!!),
      optionsToRegister
    )

    result?.success(isGranted)
  }

  /** 
   * Requests authorization for the HealthDataTypes 
   * with the the READ or READ_WRITE permission type.
   */
  private fun requestAuthorization(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }

    val optionsToRegister = callToHealthTypes(call)
    mResult = result

    // Set to false due to bug described in https://github.com/cph-cachet/flutter-plugins/issues/640#issuecomment-1366830132
    val isGranted = false

    // If not granted then ask for permission
    if (!isGranted && activity != null) {
      GoogleSignIn.requestPermissions(
        activity!!,
        GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
        GoogleSignIn.getLastSignedInAccount(context!!),
        optionsToRegister
      )
    } else { /// Permission already granted
      result?.success(true)
    }
  }

  /** 
   * Revokes access to Google Fit using the `disableFit`-method.
   * 
   * Note: Using the `revokeAccess` creates a bug on android 
   * when trying to reapply for permissions afterwards, hence
   * `disableFit` was used.
   */
  private fun revokePermissions(call: MethodCall, result: Result) {
    if (context == null) {
      result.success(false)
      return
    }
    Fitness.getConfigClient(activity!!, GoogleSignIn.getLastSignedInAccount(context!!)!!)
      .disableFit()
      .addOnSuccessListener {
        Log.i("Health","Disabled Google Fit")
        result.success(true)
      }
      .addOnFailureListener { e ->
        Log.w("Health", "There was an error disabling Google Fit", e)
        result.success(false)
      }
  }

  private fun getTotalStepsInInterval(call: MethodCall, result: Result) {
    val start = call.argument<Long>("startTime")!!
    val end = call.argument<Long>("endTime")!!

    val context = context ?: return

    val stepsDataType = keyToHealthDataType(STEPS)
    val aggregatedDataType = keyToHealthDataType(AGGREGATE_STEP_COUNT)

    val fitnessOptions = FitnessOptions.builder()
      .addDataType(stepsDataType)
      .addDataType(aggregatedDataType)
      .build()
    val gsa = GoogleSignIn.getAccountForExtension(context, fitnessOptions)

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

    Fitness.getHistoryClient(context, gsa).readData(request)
      .addOnFailureListener(
        errHandler(
          result,
          "There was an error getting the total steps in the interval!"
        )
      )
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

          val count = dp.getValue(aggregatedDataType.fields[0])

          val startTime = dp.getStartTime(TimeUnit.MILLISECONDS)
          val startDate = Date(startTime)
          val endDate = Date(dp.getEndTime(TimeUnit.MILLISECONDS))
          Log.i("FLUTTER_HEALTH::SUCCESS", "returning $count steps for $startDate - $endDate")
          map[startTime] = count.asInt()
        } else {
          val startDay = Date(start)
          val endDay = Date(end)
          Log.i("FLUTTER_HEALTH::ERROR", "no steps for $startDay - $endDay")
        }
      }

      assert(map.size <= 1) { "getTotalStepsInInterval should return only one interval. Found: ${map.size}" }
      Handler(context!!.mainLooper).run {
        result.success(map.values.firstOrNull())
      }
    }

  private fun getActivityType(type: String): String {
    return workoutTypeMap[type] ?: FitnessActivities.UNKNOWN
  }

  /**
   *  Handle calls from the MethodChannel
   */
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "hasPermissions" -> hasPermissions(call, result)
      "requestAuthorization" -> requestAuthorization(call, result)
      "revokePermissions" -> revokePermissions(call, result)
      "getData" -> getData(call, result)
      "writeData" -> writeData(call, result)
      "delete" -> delete(call, result)
      "getTotalStepsInInterval" -> getTotalStepsInInterval(call, result)
      "writeWorkoutData" -> writeWorkoutData(call, result)
      "writeBloodPressure" -> writeBloodPressure(call, result)
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
