package cachet.plugins.health

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.annotation.NonNull
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.*

/**
 * Main Flutter plugin class for Health Connect integration. Manages plugin lifecycle, method
 * channel communication, permission handling, and coordinates between Flutter and Android Health
 * Connect APIs.
 */
class HealthPlugin(private var channel: MethodChannel? = null) :
        MethodCallHandler, ActivityResultListener, Result, ActivityAware, FlutterPlugin {

    private var mResult: Result? = null
    private var handler: Handler? = null
    private var activity: Activity? = null
    private var context: Context? = null
    private var healthConnectRequestPermissionsLauncher: ActivityResultLauncher<Set<String>>? = null
    private lateinit var healthConnectClient: HealthConnectClient
    private lateinit var scope: CoroutineScope
    private var isReplySubmitted = false

    // Helper classes
    private lateinit var dataReader: HealthDataReader
    private lateinit var dataWriter: HealthDataWriter
    private lateinit var dataOperations: HealthDataOperations
    private lateinit var dataConverter: HealthDataConverter

    // Health Connect availability
    private var healthConnectAvailable = false
    private var healthConnectStatus = HealthConnectClient.SDK_UNAVAILABLE

    companion object {
        const val CHANNEL_NAME = "flutter_health"
    }

    /**
     * Initializes the plugin when attached to the Flutter engine. Sets up method channel, checks
     * Health Connect availability, and initializes helper classes.
     *
     * @param flutterPluginBinding Plugin binding providing access to Flutter engine resources
     */
    override fun onAttachedToEngine(
            @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        handler = Handler(context!!.mainLooper)

        checkAvailability()
        if (healthConnectAvailable) {
            healthConnectClient =
                    HealthConnectClient.getOrCreate(flutterPluginBinding.applicationContext)
            initializeHelpers()
        }
    }

    /**
     * Cleans up resources when plugin is detached from Flutter engine. Cancels coroutines and
     * nullifies references to prevent memory leaks.
     *
     * @param binding Plugin binding (unused in cleanup)
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
        activity = null
        scope.cancel()
    }

    override fun success(p0: Any?) {
        handler?.post { mResult?.success(p0) }
    }

    override fun notImplemented() {
        handler?.post { mResult?.notImplemented() }
    }

    override fun error(
            errorCode: String,
            errorMessage: String?,
            errorDetails: Any?,
    ) {
        handler?.post { mResult?.error(errorCode, errorMessage, errorDetails) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }

    /**
     * Handles method calls from Flutter and routes them to appropriate handler classes. Central
     * dispatcher for all Health Connect operations including permissions, data reading, writing,
     * and deletion.
     *
     * @param call Method call from Flutter containing method name and arguments
     * @param result Result callback to return data or status to Flutter
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // SDK and Installation
            "installHealthConnect" -> installHealthConnect(call, result)
            "getHealthConnectSdkStatus" -> dataOperations.getHealthConnectSdkStatus(call, result)

            // Permissions
            "hasPermissions" -> dataOperations.hasPermissions(call, result)
            "requestAuthorization" -> requestAuthorization(call, result)
            "revokePermissions" -> revokePermissions(call, result)
            "getData" -> getData(call, result)
            "getIntervalData" -> getIntervalData(call, result)
            "writeData" -> writeData(call, result)
            "delete" -> deleteData(call, result)
            "deleteByIds" -> deleteDataByIds(call, result)
            "getAggregateData" -> getAggregateData(call, result)
            "getTotalStepsInInterval" -> getTotalStepsInInterval(call, result)
            "writeWorkoutData" -> writeWorkoutData(call, result)
            "writeBloodPressure" -> writeBloodPressure(call, result)
            "writeBloodOxygen" -> writeBloodOxygen(call, result)
            "writeMenstruationFlow" -> writeMenstruationFlow(call, result)
            "writeMeal" -> writeMeal(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Called when activity is attached to the plugin. Sets up permission request launcher and
     * activity result handling.
     *
     * @param binding Activity plugin binding providing activity context
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (channel == null) {
            return
        }
        binding.addActivityResultListener(this)
        activity = binding.activity

        val requestPermissionActivityContract =
                PermissionController.createRequestPermissionResultContract()

        healthConnectRequestPermissionsLauncher =
                (activity as ComponentActivity).registerForActivityResult(
                        requestPermissionActivityContract
                ) { granted -> onHealthConnectPermissionCallback(granted) }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    /**
     * Called when activity is detached from plugin. Cleans up activity-specific resources and
     * permission launchers.
     */
    override fun onDetachedFromActivity() {
        if (channel == null) {
            return
        }
        activity = null
        healthConnectRequestPermissionsLauncher = null
    }

    /**
     * Checks Health Connect availability and SDK status on the current device. Determines if Health
     * Connect is installed and accessible.
     */
    private fun checkAvailability() {
        healthConnectStatus = HealthConnectClient.getSdkStatus(context!!)
        healthConnectAvailable = healthConnectStatus == HealthConnectClient.SDK_AVAILABLE
    }

    /**
     * Initializes helper classes for data operations after Health Connect client is ready. Creates
     * instances of reader, writer, operations, and converter classes.
     */
    private fun initializeHelpers() {
        dataConverter = HealthDataConverter()
        dataReader = HealthDataReader(healthConnectClient, scope, context!!, dataConverter)
        dataWriter = HealthDataWriter(healthConnectClient, scope)
        dataOperations =
                HealthDataOperations(
                        healthConnectClient,
                        scope,
                        healthConnectStatus,
                        healthConnectAvailable
                )
    }

    /**
     * Launches Health Connect installation flow via Google Play Store. Directs users to install
     * Health Connect when it's not available.
     *
     * @param call Method call from Flutter (unused)
     * @param result Flutter result callback
     */
    private fun installHealthConnect(call: MethodCall, result: Result) {
        val uriString =
                "market://details?id=com.google.android.apps.healthdata&url=healthconnect%3A%2F%2Fonboarding"
        context!!.startActivity(
                Intent(Intent.ACTION_VIEW).apply {
                    setPackage("com.android.vending")
                    data = android.net.Uri.parse(uriString)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("overlay", true)
                    putExtra("callerId", context!!.packageName)
                }
        )
        result.success(null)
    }

    /**
     * Handles permission request results from Health Connect permission dialog. Called when user
     * responds to permission request, updates Flutter with result.
     *
     * @param permissionGranted Set of permission strings that were granted
     */
    private fun onHealthConnectPermissionCallback(permissionGranted: Set<String>) {
        if (!isReplySubmitted) {
            if (permissionGranted.isEmpty()) {
                mResult?.success(false)
                Log.i(
                        "FLUTTER_HEALTH",
                        "Health Connect permissions were not granted! Make sure to declare the required permissions in the AndroidManifest.xml file."
                )
            } else {
                mResult?.success(true)
                Log.i(
                        "FLUTTER_HEALTH",
                        "${permissionGranted.size} Health Connect permissions were granted!"
                )

                // log the permissions granted for debugging
                Log.i("FLUTTER_HEALTH", "Permissions granted: $permissionGranted")
            }
            isReplySubmitted = true
        }
    }

    /** Save a Nutrition measurement with calories, carbs, protein, fat, name and mealType */
    private fun writeMeal(call: MethodCall, result: Result) {
        val startTime = Instant.ofEpochMilli(call.argument<Long>("start_time")!!)
        val endTime = Instant.ofEpochMilli(call.argument<Long>("end_time")!!)
        val clientRecordId = call.argument<String>("clientRecordId")
        val clientRecordVersion = call.argument<Long>("clientRecordVersion")
        val calories = call.argument<Double>("calories")
        val protein = call.argument<Double>("protein") as Double?
        val carbs = call.argument<Double>("carbs") as Double?
        val fat = call.argument<Double>("fat") as Double?
        val caffeine = call.argument<Double>("caffeine") as Double?
        val vitaminA = call.argument<Double>("vitamin_a") as Double?
        val b1Thiamine = call.argument<Double>("b1_thiamine") as Double?
        val b2Riboflavin = call.argument<Double>("b2_riboflavin") as Double?
        val b3Niacin = call.argument<Double>("b3_niacin") as Double?
        val b5PantothenicAcid = call.argument<Double>("b5_pantothenic_acid") as Double?
        val b6Pyridoxine = call.argument<Double>("b6_pyridoxine") as Double?
        val b7Biotin = call.argument<Double>("b7_biotin") as Double?
        val b9Folate = call.argument<Double>("b9_folate") as Double?
        val b12Cobalamin = call.argument<Double>("b12_cobalamin") as Double?
        val vitaminC = call.argument<Double>("vitamin_c") as Double?
        val vitaminD = call.argument<Double>("vitamin_d") as Double?
        val vitaminE = call.argument<Double>("vitamin_e") as Double?
        val vitaminK = call.argument<Double>("vitamin_k") as Double?
        val calcium = call.argument<Double>("calcium") as Double?
        val chloride = call.argument<Double>("chloride") as Double?
        val cholesterol = call.argument<Double>("cholesterol") as Double?
        // Choline is not yet supported by Health Connect
        // val choline = call.argument<Double>("choline") as Double?
        val chromium = call.argument<Double>("chromium") as Double?
        val copper = call.argument<Double>("copper") as Double?
        val fatUnsaturated = call.argument<Double>("fat_unsaturated") as Double?
        val fatMonounsaturated = call.argument<Double>("fat_monounsaturated") as Double?
        val fatPolyunsaturated = call.argument<Double>("fat_polyunsaturated") as Double?
        val fatSaturated = call.argument<Double>("fat_saturated") as Double?
        val fatTransMonoenoic = call.argument<Double>("fat_trans_monoenoic") as Double?
        val fiber = call.argument<Double>("fiber") as Double?
        val iodine = call.argument<Double>("iodine") as Double?
        val iron = call.argument<Double>("iron") as Double?
        val magnesium = call.argument<Double>("magnesium") as Double?
        val manganese = call.argument<Double>("manganese") as Double?
        val molybdenum = call.argument<Double>("molybdenum") as Double?
        val phosphorus = call.argument<Double>("phosphorus") as Double?
        val potassium = call.argument<Double>("potassium") as Double?
        val selenium = call.argument<Double>("selenium") as Double?
        val sodium = call.argument<Double>("sodium") as Double?
        val sugar = call.argument<Double>("sugar") as Double?
        // Water is not support on a food in Health Connect
        // val water = call.argument<Double>("water") as Double?
        val zinc = call.argument<Double>("zinc") as Double?

        val name = call.argument<String>("name")
        val mealType = call.argument<String>("meal_type")!!

        scope.launch {
            try {
                val metaData: Metadata
                if ((clientRecordId != null) && (clientRecordVersion != null)) {
                    metaData =
                            Metadata(
                                    clientRecordId = clientRecordId,
                                    clientRecordVersion = clientRecordVersion
                            )
                } else {
                    metaData = Metadata()
                }
                val list = mutableListOf<Record>()
                list.add(
                        NutritionRecord(
                                metadata = metaData,
                                name = name,
                                energy = calories?.kilocalories,
                                totalCarbohydrate = carbs?.grams,
                                protein = protein?.grams,
                                totalFat = fat?.grams,
                                caffeine = caffeine?.grams,
                                vitaminA = vitaminA?.grams,
                                thiamin = b1Thiamine?.grams,
                                riboflavin = b2Riboflavin?.grams,
                                niacin = b3Niacin?.grams,
                                pantothenicAcid = b5PantothenicAcid?.grams,
                                vitaminB6 = b6Pyridoxine?.grams,
                                biotin = b7Biotin?.grams,
                                folate = b9Folate?.grams,
                                vitaminB12 = b12Cobalamin?.grams,
                                vitaminC = vitaminC?.grams,
                                vitaminD = vitaminD?.grams,
                                vitaminE = vitaminE?.grams,
                                vitaminK = vitaminK?.grams,
                                calcium = calcium?.grams,
                                chloride = chloride?.grams,
                                cholesterol = cholesterol?.grams,
                                chromium = chromium?.grams,
                                copper = copper?.grams,
                                unsaturatedFat = fatUnsaturated?.grams,
                                monounsaturatedFat = fatMonounsaturated?.grams,
                                polyunsaturatedFat = fatPolyunsaturated?.grams,
                                saturatedFat = fatSaturated?.grams,
                                transFat = fatTransMonoenoic?.grams,
                                dietaryFiber = fiber?.grams,
                                iodine = iodine?.grams,
                                iron = iron?.grams,
                                magnesium = magnesium?.grams,
                                manganese = manganese?.grams,
                                molybdenum = molybdenum?.grams,
                                phosphorus = phosphorus?.grams,
                                potassium = potassium?.grams,
                                selenium = selenium?.grams,
                                sodium = sodium?.grams,
                                sugar = sugar?.grams,
                                zinc = zinc?.grams,
                                startTime = startTime,
                                startZoneOffset = null,
                                endTime = endTime,
                                endZoneOffset = null,
                                mealType = mapMealTypeToType[mealType] ?: MEAL_TYPE_UNKNOWN,
                        ),
                )
                healthConnectClient.insertRecords(
                        list,
                )
                result.success(true)
                Log.i("FLUTTER_HEALTH::SUCCESS", "[Health Connect] Meal was successfully added!")
            } catch (e: Exception) {
                Log.w(
                        "FLUTTER_HEALTH::ERROR",
                        "[Health Connect] There was an error adding the meal",
                )
                Log.w("FLUTTER_HEALTH::ERROR", e.message ?: "unknown error")
                Log.w("FLUTTER_HEALTH::ERROR", e.stackTrace.toString())
                result.success(false)
            }
        }
    }

    /** Save menstrual flow data */
    private fun writeMenstruationFlow(call: MethodCall, result: Result) {
        writeData(call, result)
    }

    /** Save the blood oxygen saturation */
    private fun writeBloodOxygen(call: MethodCall, result: Result) {
        writeData(call, result)
    }

    private fun getIntervalData(call: MethodCall, result: Result) {
        getAggregateData(call, result)
    }

    /**
     * Revokes access to Health Connect using `revokeAllPermissions`.
     *
     * Note: When using `revokePermissions` with Health Connect, the app must be completely killed
     * for it to take effect.
     */
    private fun revokePermissions(call: MethodCall, result: Result) {
        scope.launch {
            Log.i("Health", "Disabling Health Connect")
            healthConnectClient.permissionController.revokeAllPermissions()
        }
        result.success(true)
    }

    private fun getTotalStepsInInterval(call: MethodCall, result: Result) {
        val start = call.argument<Long>("startTime")!!
        val end = call.argument<Long>("endTime")!!
        val recordingMethodsToFilter = call.argument<List<Int>>("recordingMethodsToFilter")!!

        if (recordingMethodsToFilter.isEmpty()) {
            getAggregatedStepCount(start, end, result)
        } else {
            getStepCountFiltered(start, end, recordingMethodsToFilter, result)
        }
    }

    private fun getAggregatedStepCount(start: Long, end: Long, result: Result) {
        val startInstant = Instant.ofEpochMilli(start)
        val endInstant = Instant.ofEpochMilli(end)
        scope.launch {
            try {
                val response =
                        healthConnectClient.aggregate(
                                AggregateRequest(
                                        metrics =
                                                setOf(
                                                        StepsRecord.COUNT_TOTAL,
                                                ),
                                        timeRangeFilter =
                                                TimeRangeFilter.between(startInstant, endInstant),
                                ),
                        )
                // The result may be null if no data is available in the
                // time range.
                val stepsInInterval = response[StepsRecord.COUNT_TOTAL] ?: 0L

                Log.i("FLUTTER_HEALTH::SUCCESS", "returning $stepsInInterval steps")
                result.success(stepsInInterval)
            } catch (e: Exception) {
                Log.e(
                        "FLUTTER_HEALTH::ERROR",
                        "Unable to return steps due to the following exception:"
                )
                Log.e("FLUTTER_HEALTH::ERROR", Log.getStackTraceString(e))
                result.success(null)
            }
        }
    }

    /** get the step records manually and filter out manual entries */
    private fun getStepCountFiltered(
            start: Long,
            end: Long,
            recordingMethodsToFilter: List<Int>,
            result: Result
    ) {
        scope.launch {
            try {
                val request =
                        ReadRecordsRequest(
                                recordType = StepsRecord::class,
                                timeRangeFilter =
                                        TimeRangeFilter.between(
                                                Instant.ofEpochMilli(start),
                                                Instant.ofEpochMilli(end)
                                        ),
                        )
                val response = healthConnectClient.readRecords(request)
                val filteredRecords =
                        filterRecordsByRecordingMethods(recordingMethodsToFilter, response.records)
                val totalSteps = filteredRecords.sumOf { (it as StepsRecord).count.toInt() }
                Log.i(
                        "FLUTTER_HEALTH::SUCCESS",
                        "returning $totalSteps steps (excluding manual entries)"
                )
                result.success(totalSteps)
            } catch (e: Exception) {
                Log.e(
                        "FLUTTER_HEALTH::ERROR",
                        "Unable to return steps due to the following exception:"
                )
                Log.e("FLUTTER_HEALTH::ERROR", Log.getStackTraceString(e))
                result.success(null)
            }
        }
    }

    private fun getHealthConnectSdkStatus(call: MethodCall, result: Result) {
        checkAvailability()
        if (healthConnectAvailable) {
            healthConnectClient = HealthConnectClient.getOrCreate(context!!)
        }
        result.success(healthConnectStatus)
    }

    /** Filter records by recording methods */
    private fun filterRecordsByRecordingMethods(
            recordingMethodsToFilter: List<Int>,
            records: List<Record>
    ): List<Record> {
        if (recordingMethodsToFilter.isEmpty()) {
            return records
        }

        return records.filter { record ->
            Log.i(
                    "FLUTTER_HEALTH",
                    "Filtering record with recording method ${record.metadata.recordingMethod}, filtering by $recordingMethodsToFilter. Result: ${
                    recordingMethodsToFilter.contains(
                        record.metadata.recordingMethod
                    )
                }"
            )
            return@filter !recordingMethodsToFilter.contains(record.metadata.recordingMethod)
        }
    }

    private fun hasPermissions(call: MethodCall, result: Result) {
        val args = call.arguments as HashMap<*, *>
        val types = (args["types"] as? ArrayList<*>)?.filterIsInstance<String>()!!
        val permissions = (args["permissions"] as? ArrayList<*>)?.filterIsInstance<Int>()!!

        val permList = mutableListOf<String>()
        for ((i, typeKey) in types.withIndex()) {
            if (!mapToType.containsKey(typeKey)) {
                Log.w("FLUTTER_HEALTH::ERROR", "Datatype $typeKey not found in HC")
                result.success(false)
                return
            }
            val access = permissions[i]
            val dataType = mapToType[typeKey]!!
            if (access == 0) {
                permList.add(
                        HealthPermission.getReadPermission(dataType),
                )
            } else {
                permList.addAll(
                        listOf(
                                HealthPermission.getReadPermission(dataType),
                                HealthPermission.getWritePermission(dataType),
                        ),
                )
            }
        }
        scope.launch {
            result.success(
                    healthConnectClient
                            .permissionController
                            .getGrantedPermissions()
                            .containsAll(permList),
            )
        }
    }

    /**
     * Requests authorization for the HealthDataTypes with the the READ or READ_WRITE permission
     * type.
     */
    private fun requestAuthorization(call: MethodCall, result: Result) {
        if (context == null) {
            result.success(false)
            return
        }

        if (healthConnectRequestPermissionsLauncher == null) {
            result.success(false)
            Log.i("FLUTTER_HEALTH", "Permission launcher not found")
            return
        }

        // Store the result to be called in onHealthConnectPermissionCallback
        mResult = result
        isReplySubmitted = false
        healthConnectRequestPermissionsLauncher!!.launch(permList.toSet())
    }

    /** Get all datapoints of the DataType within the given time range */
    private fun getData(call: MethodCall, result: Result) {
        val dataType = call.argument<String>("dataTypeKey")!!
        val dataUnit = call.argument<String>("dataUnitKey")!!
        val startTime = Instant.ofEpochMilli(call.argument<Long>("startTime")!!)
        val endTime = Instant.ofEpochMilli(call.argument<Long>("endTime")!!)
        val healthConnectData = mutableListOf<Map<String, Any?>>()
        val recordingMethodsToFilter = call.argument<List<Int>>("recordingMethodsToFilter")!!
        Log.i(
                "FLUTTER_HEALTH",
                "Getting data for $dataType with unit $dataUnit between $startTime and $endTime, filtering by $recordingMethodsToFilter"
        )

        scope.launch {
            try {
                mapToType[dataType]?.let { classType ->
                    val records = mutableListOf<Record>()

                    // Set up the initial request to read health records with specified
                    // parameters
                    var request =
                            ReadRecordsRequest(
                                    recordType = classType,
                                    // Define the maximum amount of data
                                    // that HealthConnect can return
                                    // in a single request
                                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime),
                            )

                    var response = healthConnectClient.readRecords(request)
                    var pageToken = response.pageToken

                    // Add the records from the initial response to the records list
                    records.addAll(response.records)

                    // Continue making requests and fetching records while there is a
                    // page token
                    while (!pageToken.isNullOrEmpty()) {
                        request =
                                ReadRecordsRequest(
                                        recordType = classType,
                                        timeRangeFilter =
                                                TimeRangeFilter.between(startTime, endTime),
                                        pageToken = pageToken
                                )
                        response = healthConnectClient.readRecords(request)

                        pageToken = response.pageToken
                        records.addAll(response.records)
                    }

                    // Workout needs distance and total calories burned too
                    if (dataType == WORKOUT) {
                        var filteredRecords =
                                filterRecordsByRecordingMethods(recordingMethodsToFilter, records)

                        for (rec in filteredRecords) {
                            val record = rec as ExerciseSessionRecord
                            val distanceRequest =
                                    healthConnectClient.readRecords(
                                            ReadRecordsRequest(
                                                    recordType = DistanceRecord::class,
                                                    timeRangeFilter =
                                                            TimeRangeFilter.between(
                                                                    record.startTime,
                                                                    record.endTime,
                                                            ),
                                            ),
                                    )
                            var totalDistance = 0.0
                            for (distanceRec in distanceRequest.records) {
                                totalDistance += distanceRec.distance.inMeters
                            }

                            val energyBurnedRequest =
                                    healthConnectClient.readRecords(
                                            ReadRecordsRequest(
                                                    recordType = TotalCaloriesBurnedRecord::class,
                                                    timeRangeFilter =
                                                            TimeRangeFilter.between(
                                                                    record.startTime,
                                                                    record.endTime,
                                                            ),
                                            ),
                                    )
                            var totalEnergyBurned = 0.0
                            for (energyBurnedRec in energyBurnedRequest.records) {
                                totalEnergyBurned += energyBurnedRec.energy.inKilocalories
                            }

                            val stepRequest =
                                    healthConnectClient.readRecords(
                                            ReadRecordsRequest(
                                                    recordType = StepsRecord::class,
                                                    timeRangeFilter =
                                                            TimeRangeFilter.between(
                                                                    record.startTime,
                                                                    record.endTime
                                                            ),
                                            ),
                                    )
                            var totalSteps = 0.0
                            for (stepRec in stepRequest.records) {
                                totalSteps += stepRec.count
                            }

                            // val metadata = (rec as Record).metadata
                            // Add final datapoint
                            healthConnectData.add(
                                    // mapOf(
                                    mapOf<String, Any?>(
                                            "uuid" to record.metadata.id,
                                            "workoutActivityType" to
                                                    (workoutTypeMap
                                                            .filterValues {
                                                                it == record.exerciseType
                                                            }
                                                            .keys
                                                            .firstOrNull()
                                                            ?: "OTHER"),
                                            "totalDistance" to
                                                    if (totalDistance == 0.0) null
                                                    else totalDistance,
                                            "totalDistanceUnit" to "METER",
                                            "totalEnergyBurned" to
                                                    if (totalEnergyBurned == 0.0) null
                                                    else totalEnergyBurned,
                                            "totalEnergyBurnedUnit" to "KILOCALORIE",
                                            "totalSteps" to
                                                    if (totalSteps == 0.0) null else totalSteps,
                                            "totalStepsUnit" to "COUNT",
                                            "unit" to "MINUTES",
                                            "date_from" to rec.startTime.toEpochMilli(),
                                            "date_to" to rec.endTime.toEpochMilli(),
                                            "source_id" to "",
                                            "source_name" to record.metadata.dataOrigin.packageName,
                                    ),
                            )
                        }
                        // Filter sleep stages for requested stage
                    } else if (classType == SleepSessionRecord::class) {
                        val filteredRecords =
                                filterRecordsByRecordingMethods(
                                        recordingMethodsToFilter,
                                        response.records
                                )

                        for (rec in filteredRecords) {
                            if (rec is SleepSessionRecord) {
                                if (dataType == SLEEP_SESSION) {
                                    healthConnectData.addAll(convertRecord(rec, dataType))
                                } else {
                                    for (recStage in rec.stages) {
                                        if (dataType == mapSleepStageToType[recStage.stage]) {
                                            healthConnectData.addAll(
                                                    convertRecordStage(
                                                            recStage,
                                                            dataType,
                                                            rec.metadata
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        val filteredRecords =
                                filterRecordsByRecordingMethods(recordingMethodsToFilter, records)
                        for (rec in filteredRecords) {
                            healthConnectData.addAll(convertRecord(rec, dataType, dataUnit))
                        }
                    }
                }
                Handler(context!!.mainLooper).run { result.success(healthConnectData) }
            } catch (e: Exception) {
                Log.i(
                        "FLUTTER_HEALTH::ERROR",
                        "Unable to return $dataType due to the following exception:"
                )
                Log.e("FLUTTER_HEALTH::ERROR", Log.getStackTraceString(e))
                result.success(null)
            }
        }
    }

    private fun convertRecordStage(
            stage: SleepSessionRecord.Stage,
            dataType: String,
            metadata: Metadata
    ): List<Map<String, Any>> {
        var sourceName = metadata.dataOrigin.packageName
        return listOf(
                mapOf<String, Any>(
                        "uuid" to metadata.id,
                        "stage" to stage.stage,
                        "value" to ChronoUnit.MINUTES.between(stage.startTime, stage.endTime),
                        "date_from" to stage.startTime.toEpochMilli(),
                        "date_to" to stage.endTime.toEpochMilli(),
                        "source_id" to "",
                        "source_name" to sourceName,
                ),
        )
    }

    private fun getAggregateData(call: MethodCall, result: Result) {
        val dataType = call.argument<String>("dataTypeKey")!!
        val interval = call.argument<Long>("interval")!!
        val startTime = Instant.ofEpochMilli(call.argument<Long>("startTime")!!)
        val endTime = Instant.ofEpochMilli(call.argument<Long>("endTime")!!)
        val healthConnectData = mutableListOf<Map<String, Any?>>()
        scope.launch {
            try {
                mapToAggregateMetric[dataType]?.let { metricClassType ->
                    val request =
                            AggregateGroupByDurationRequest(
                                    metrics = setOf(metricClassType),
                                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime),
                                    timeRangeSlicer = Duration.ofSeconds(interval)
                            )
                    val response = healthConnectClient.aggregateGroupByDuration(request)

                    for (durationResult in response) {
                        // The result may be null if no data is available in the
                        // time range
                        var totalValue = durationResult.result[metricClassType]
                        if (totalValue is Length) {
                            totalValue = totalValue.inMeters
                        } else if (totalValue is Energy) {
                            totalValue = totalValue.inKilocalories
                        }

                        val packageNames =
                                durationResult.result.dataOrigins.joinToString { origin ->
                                    origin.packageName
                                }

                        val data =
                                mapOf<String, Any>(
                                        "value" to (totalValue ?: 0),
                                        "date_from" to durationResult.startTime.toEpochMilli(),
                                        "date_to" to durationResult.endTime.toEpochMilli(),
                                        "source_name" to packageNames,
                                        "source_id" to "",
                                        "is_manual_entry" to packageNames.contains("user_input")
                                )
                        healthConnectData.add(data)
                    }
                }
                Handler(context!!.mainLooper).run { result.success(healthConnectData) }
            } catch (e: Exception) {
                Log.i(
                        "FLUTTER_HEALTH::ERROR",
                        "Unable to return $dataType due to the following exception:"
                )
                Log.e("FLUTTER_HEALTH::ERROR", Log.getStackTraceString(e))
                result.success(null)
            }
        }
    }

    // TODO: Find alternative to SOURCE_ID or make it nullable?
    private fun convertRecord(
            record: Any,
            dataType: String,
            dataUnit: String? = null
    ): List<Map<String, Any?>> {
        val metadata = (record as Record).metadata
        when (record) {
            is WeightRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.weight.inKilograms,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is HeightRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.height.inMeters,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BodyFatRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.percentage.value,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is LeanBodyMassRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.mass.inKilograms,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is StepsRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.count,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is ActiveCaloriesBurnedRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.energy.inKilocalories,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is HeartRateRecord ->
                    return record.samples.map {
                        mapOf<String, Any>(
                                "uuid" to metadata.id,
                                "value" to it.beatsPerMinute,
                                "date_from" to it.time.toEpochMilli(),
                                "date_to" to it.time.toEpochMilli(),
                                "source_id" to "",
                                "source_name" to metadata.dataOrigin.packageName,
                                "recording_method" to metadata.recordingMethod
                        )
                    }
            is HeartRateVariabilityRmssdRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.heartRateVariabilityMillis,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BodyTemperatureRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to
                                            when (dataUnit) {
                                                "DEGREE_FAHRENHEIT" ->
                                                        record.temperature.inFahrenheit
                                                "KELVIN" -> record.temperature.inCelsius + 273.15
                                                else -> record.temperature.inCelsius
                                            },
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BodyWaterMassRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.mass.inKilograms,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BloodPressureRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to
                                            if (dataType == BLOOD_PRESSURE_DIASTOLIC)
                                                    record.diastolic.inMillimetersOfMercury
                                            else record.systolic.inMillimetersOfMercury,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is OxygenSaturationRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.percentage.value,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BloodGlucoseRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to
                                            when (dataUnit) {
                                                "MILLIMOLES_PER_LITER" ->
                                                        record.level.inMillimolesPerLiter
                                                else -> record.level.inMilligramsPerDeciliter
                                            },
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is DistanceRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.distance.inMeters,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is HydrationRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.volume.inLiters,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is TotalCaloriesBurnedRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.energy.inKilocalories,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is BasalMetabolicRateRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.basalMetabolicRate.inKilocaloriesPerDay,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is SleepSessionRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "value" to
                                            ChronoUnit.MINUTES.between(
                                                    record.startTime,
                                                    record.endTime
                                            ),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            ),
                    )
            is RestingHeartRateRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.beatsPerMinute,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            )
                    )
            is FloorsClimbedRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.floors,
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            )
                    )
            is RespiratoryRateRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.rate,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            )
                    )
            is NutritionRecord ->
                    return listOf(
                            mapOf<String, Any?>(
                                    "uuid" to metadata.id,
                                    "calories" to record.energy?.inKilocalories,
                                    "protein" to record.protein?.inGrams,
                                    "carbs" to record.totalCarbohydrate?.inGrams,
                                    "fat" to record.totalFat?.inGrams,
                                    "caffeine" to record.caffeine?.inGrams,
                                    "vitamin_a" to record.vitaminA?.inGrams,
                                    "b1_thiamine" to record.thiamin?.inGrams,
                                    "b2_riboflavin" to record.riboflavin?.inGrams,
                                    "b3_niacin" to record.niacin?.inGrams,
                                    "b5_pantothenic_acid" to record.pantothenicAcid?.inGrams,
                                    "b6_pyridoxine" to record.vitaminB6?.inGrams,
                                    "b7_biotin" to record.biotin?.inGrams,
                                    "b9_folate" to record.folate?.inGrams,
                                    "b12_cobalamin" to record.vitaminB12?.inGrams,
                                    "vitamin_c" to record.vitaminC?.inGrams,
                                    "vitamin_d" to record.vitaminD?.inGrams,
                                    "vitamin_e" to record.vitaminE?.inGrams,
                                    "vitamin_k" to record.vitaminK?.inGrams,
                                    "calcium" to record.calcium?.inGrams,
                                    "chloride" to record.chloride?.inGrams,
                                    "cholesterol" to record.cholesterol?.inGrams,
                                    "choline" to null,
                                    "chromium" to record.chromium?.inGrams,
                                    "copper" to record.copper?.inGrams,
                                    "fat_unsaturated" to record.unsaturatedFat?.inGrams,
                                    "fat_monounsaturated" to record.monounsaturatedFat?.inGrams,
                                    "fat_polyunsaturated" to record.polyunsaturatedFat?.inGrams,
                                    "fat_saturated" to record.saturatedFat?.inGrams,
                                    "fat_trans_monoenoic" to record.transFat?.inGrams,
                                    "fiber" to record.dietaryFiber?.inGrams,
                                    "iodine" to record.iodine?.inGrams,
                                    "iron" to record.iron?.inGrams,
                                    "magnesium" to record.magnesium?.inGrams,
                                    "manganese" to record.manganese?.inGrams,
                                    "molybdenum" to record.molybdenum?.inGrams,
                                    "phosphorus" to record.phosphorus?.inGrams,
                                    "potassium" to record.potassium?.inGrams,
                                    "selenium" to record.selenium?.inGrams,
                                    "sodium" to record.sodium?.inGrams,
                                    "sugar" to record.sugar?.inGrams,
                                    "water" to null,
                                    "zinc" to record.zinc?.inGrams,
                                    "name" to (record.name ?: ""),
                                    "meal_type" to
                                            (mapTypeToMealType[record.mealType]
                                                    ?: MEAL_TYPE_UNKNOWN),
                                    "date_from" to record.startTime.toEpochMilli(),
                                    "date_to" to record.endTime.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            )
                    )
            is MenstruationFlowRecord ->
                    return listOf(
                            mapOf<String, Any>(
                                    "uuid" to metadata.id,
                                    "value" to record.flow,
                                    "date_from" to record.time.toEpochMilli(),
                                    "date_to" to record.time.toEpochMilli(),
                                    "source_id" to "",
                                    "source_name" to metadata.dataOrigin.packageName,
                                    "recording_method" to metadata.recordingMethod
                            )
                    )
            // is ExerciseSessionRecord -> return listOf(mapOf<String, Any>("value" to ,
            //                                             "date_from" to ,
            //                                             "date_to" to ,
            //                                             "source_id" to "",
            //                                             "source_name" to
            // metadata.dataOrigin.packageName))
            else ->
                    throw IllegalArgumentException(
                            "Health data type not supported"
                    ) // TODO: Exception or error?
        }
    }

    private fun getMassUnit(unitKey: String?, value: Double): Mass {
        return when (unitKey) {
            null -> Mass.kilograms(value)
            "GRAM" -> Mass.grams(value)
            "KILOGRAM" -> Mass.kilograms(value)
            "OUNCE" -> Mass.ounces(value)
            "POUND" -> Mass.pounds(value)
            "STONE" -> Mass.pounds(value * 14)
            else -> Mass.kilograms(value)
        }
    }

    private fun getLengthUnit(unitKey: String?, value: Double): Length {
        return when (unitKey) {
            null -> Length.meters(value)
            "METER" -> Length.meters(value)
            "INCH" -> Length.inches(value)
            "FOOT" -> Length.feet(value)
            else -> Length.meters(value) // don't worry about yards or miles
        }
    }

    private fun getVolumeUnit(unitKey: String?, value: Double): Volume {
        return when (unitKey) {
            null -> Volume.milliliters(value)
            "LITER" -> Volume.liters(value)
            "MILLILITER" -> Volume.milliliters(value)
            else -> Volume.milliliters(value) // excludes ounces, pints, cups, ounces
        }
    }

    //    private fun getBloodPressureUnit()

    // TODO rewrite sleep to fit new update better --> compare with Apple and see if we should
    // not adopt a single type with attached stages approach
    private fun writeData(call: MethodCall, result: Result) {
        val type = call.argument<String>("dataTypeKey")!!
        val startTime = call.argument<Long>("startTime")!!
        val endTime = call.argument<Long>("endTime")!!
        val value = call.argument<Double>("value")!!
        val clientRecordId = call.argument<String>("clientRecordId")!!
        val clientRecordVersion = call.argument<Long>("clientRecordVersion")!!
        val recordingMethod = call.argument<Int>("recordingMethod")!!
        val unit = call.argument<String>("dataUnitKey")

        Log.i(
                "FLUTTER_HEALTH",
                "Writing data for $type between $startTime and $endTime, value: $value, recording method: $recordingMethod"
        )

        val metaData: Metadata
        if ((clientRecordId != null) && (clientRecordVersion != null)) {
            metaData =
                    Metadata(
                            clientRecordId = clientRecordId,
                            clientRecordVersion = clientRecordVersion,
                            recordingMethod = recordingMethod
                    )
        } else {
            metaData = Metadata(recordingMethod = recordingMethod)
        }

        val record =
                when (type) {
                    BODY_FAT_PERCENTAGE ->
                            BodyFatRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    percentage = Percentage(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    LEAN_BODY_MASS ->
                            LeanBodyMassRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    mass = getMassUnit(unit, value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    HEIGHT ->
                            HeightRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    height = Length.meters(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    WEIGHT ->
                            WeightRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    weight = Mass.kilograms(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    STEPS ->
                            StepsRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    count = value.toLong(),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    ACTIVE_ENERGY_BURNED ->
                            ActiveCaloriesBurnedRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    energy = Energy.kilocalories(value),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    HEART_RATE ->
                            HeartRateRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    samples =
                                            listOf(
                                                    HeartRateRecord.Sample(
                                                            time = Instant.ofEpochMilli(startTime),
                                                            beatsPerMinute = value.toLong(),
                                                    ),
                                            ),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    BODY_TEMPERATURE ->
                            BodyTemperatureRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    temperature = Temperature.celsius(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    BODY_WATER_MASS ->
                            BodyWaterMassRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    mass = Mass.kilograms(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    BLOOD_OXYGEN ->
                            OxygenSaturationRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    percentage = Percentage(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    BLOOD_GLUCOSE ->
                            BloodGlucoseRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    level = BloodGlucose.milligramsPerDeciliter(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    HEART_RATE_VARIABILITY_RMSSD ->
                            HeartRateVariabilityRmssdRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    heartRateVariabilityMillis = value,
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    DISTANCE_DELTA ->
                            DistanceRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    distance = Length.meters(value),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    WATER ->
                            HydrationRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    volume = Volume.milliliters(value),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    SLEEP_ASLEEP ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_SLEEPING
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_LIGHT ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_LIGHT
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_DEEP ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_DEEP
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_REM ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_REM
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_OUT_OF_BED ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_OUT_OF_BED
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_AWAKE ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_AWAKE
                                                    )
                                            ),
                                    metadata = metaData,
                            )
                    SLEEP_AWAKE_IN_BED ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord
                                                                    .STAGE_TYPE_AWAKE_IN_BED
                                                    )
                                            ),
                            )
                    SLEEP_UNKNOWN ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                                    stages =
                                            listOf(
                                                    SleepSessionRecord.Stage(
                                                            Instant.ofEpochMilli(startTime),
                                                            Instant.ofEpochMilli(endTime),
                                                            SleepSessionRecord.STAGE_TYPE_UNKNOWN
                                                    )
                                            ),
                            )
                    SLEEP_SESSION ->
                            SleepSessionRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    RESTING_HEART_RATE ->
                            RestingHeartRateRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    beatsPerMinute = value.toLong(),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    BASAL_ENERGY_BURNED ->
                            BasalMetabolicRateRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    basalMetabolicRate = Power.kilocaloriesPerDay(value),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    FLIGHTS_CLIMBED ->
                            FloorsClimbedRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    floors = value,
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    RESPIRATORY_RATE ->
                            RespiratoryRateRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    rate = value,
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    // AGGREGATE_STEP_COUNT -> StepsRecord()
                    TOTAL_CALORIES_BURNED ->
                            TotalCaloriesBurnedRecord(
                                    startTime = Instant.ofEpochMilli(startTime),
                                    endTime = Instant.ofEpochMilli(endTime),
                                    energy = Energy.kilocalories(value),
                                    startZoneOffset = null,
                                    endZoneOffset = null,
                                    metadata = metaData,
                            )
                    MENSTRUATION_FLOW ->
                            MenstruationFlowRecord(
                                    time = Instant.ofEpochMilli(startTime),
                                    flow = value.toInt(),
                                    zoneOffset = null,
                                    metadata = metaData,
                            )
                    BLOOD_PRESSURE_SYSTOLIC ->
                            throw IllegalArgumentException(
                                    "You must use the [writeBloodPressure] API "
                            )
                    BLOOD_PRESSURE_DIASTOLIC ->
                            throw IllegalArgumentException(
                                    "You must use the [writeBloodPressure] API "
                            )
                    WORKOUT ->
                            throw IllegalArgumentException(
                                    "You must use the [writeWorkoutData] API "
                            )
                    NUTRITION -> throw IllegalArgumentException("You must use the [writeMeal] API ")
                    else ->
                            throw IllegalArgumentException(
                                    "The type $type was not supported by the Health plugin or you must use another API "
                            )
                }
        scope.launch {
            try {
                healthConnectClient.insertRecords(listOf(record))
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        }
    }

    /** Save a Workout session with options for distance and calories expended */
    private fun writeWorkoutData(call: MethodCall, result: Result) {
        val type = call.argument<String>("activityType")!!
        val startTime = Instant.ofEpochMilli(call.argument<Long>("startTime")!!)
        val endTime = Instant.ofEpochMilli(call.argument<Long>("endTime")!!)
        val totalEnergyBurned = call.argument<Int>("totalEnergyBurned")
        val totalDistance = call.argument<Int>("totalDistance")
        val recordingMethod = call.argument<Int>("recordingMethod")!!
        if (!workoutTypeMap.containsKey(type)) {
            result.success(false)
            Log.w("FLUTTER_HEALTH::ERROR", "[Health Connect] Workout type not supported")
            return
        }
        val workoutType = workoutTypeMap[type]!!
        val title = call.argument<String>("title") ?: type

        scope.launch {
            try {
                val list = mutableListOf<Record>()
                list.add(
                        ExerciseSessionRecord(
                                startTime = startTime,
                                startZoneOffset = null,
                                endTime = endTime,
                                endZoneOffset = null,
                                exerciseType = workoutType,
                                title = title,
                                metadata =
                                        Metadata(
                                                recordingMethod = recordingMethod,
                                        ),
                        ),
                )
                if (totalDistance != null) {
                    list.add(
                            DistanceRecord(
                                    startTime = startTime,
                                    startZoneOffset = null,
                                    endTime = endTime,
                                    endZoneOffset = null,
                                    distance = Length.meters(totalDistance.toDouble()),
                                    metadata =
                                            Metadata(
                                                    recordingMethod = recordingMethod,
                                            ),
                            ),
                    )
                }
                if (totalEnergyBurned != null) {
                    list.add(
                            TotalCaloriesBurnedRecord(
                                    startTime = startTime,
                                    startZoneOffset = null,
                                    endTime = endTime,
                                    endZoneOffset = null,
                                    energy = Energy.kilocalories(totalEnergyBurned.toDouble()),
                                    metadata =
                                            Metadata(
                                                    recordingMethod = recordingMethod,
                                            ),
                            ),
                    )
                }
                healthConnectClient.insertRecords(
                        list,
                )
                result.success(true)
                Log.i("FLUTTER_HEALTH::SUCCESS", "[Health Connect] Workout was successfully added!")
            } catch (e: Exception) {
                Log.w(
                        "FLUTTER_HEALTH::ERROR",
                        "[Health Connect] There was an error adding the workout",
                )
                Log.w("FLUTTER_HEALTH::ERROR", e.message ?: "unknown error")
                Log.w("FLUTTER_HEALTH::ERROR", e.stackTrace.toString())
                result.success(false)
            }
        }
    }

    /** Save a Blood Pressure measurement with systolic and diastolic values */
    private fun writeBloodPressure(call: MethodCall, result: Result) {
        val systolic = call.argument<Double>("systolic")!!
        val diastolic = call.argument<Double>("diastolic")!!
        val startTime = Instant.ofEpochMilli(call.argument<Long>("startTime")!!)
        val recordingMethod = call.argument<Int>("recordingMethod")!!

        scope.launch {
            try {
                healthConnectClient.insertRecords(
                        listOf(
                                BloodPressureRecord(
                                        time = startTime,
                                        systolic = Pressure.millimetersOfMercury(systolic),
                                        diastolic = Pressure.millimetersOfMercury(diastolic),
                                        zoneOffset = null,
                                        metadata =
                                                Metadata(
                                                        recordingMethod = recordingMethod,
                                                ),
                                ),
                        ),
                )
                result.success(true)
                Log.i(
                        "FLUTTER_HEALTH::SUCCESS",
                        "[Health Connect] Blood pressure was successfully added!",
                )
            } catch (e: Exception) {
                Log.w(
                        "FLUTTER_HEALTH::ERROR",
                        "[Health Connect] There was an error adding the blood pressure",
                )
                Log.w("FLUTTER_HEALTH::ERROR", e.message ?: "unknown error")
                Log.w("FLUTTER_HEALTH::ERROR", e.stackTrace.toString())
                result.success(false)
            }
        }
    }

    /** Delete records of the given type in the time range */
    private fun deleteData(call: MethodCall, result: Result) {
        val type = call.argument<String>("dataTypeKey")!!
        val startTime = Instant.ofEpochMilli(call.argument<Long>("startTime")!!)
        val endTime = Instant.ofEpochMilli(call.argument<Long>("endTime")!!)
        if (!mapToType.containsKey(type)) {
            Log.w("FLUTTER_HEALTH::ERROR", "Datatype $type not found in HC")
            result.success(false)
            return
        }
        val classType = mapToType[type]!!

        scope.launch {
            try {
                healthConnectClient.deleteRecords(
                        recordType = classType,
                        timeRangeFilter = TimeRangeFilter.between(startTime, endTime),
                )
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        }
    }

    /** Delete records of the given type by Ids */
    private fun deleteDataByIds(call: MethodCall, result: Result) {
        val type = call.argument<String>("dataTypeKey")!!
        val idList = call.argument<List<String>>("idList") ?: emptyList()
        val clientRecordIdsList = call.argument<List<String>>("clientRecordIdsList") ?: emptyList()
        if (!mapToType.containsKey(type)) {
            Log.w("FLUTTER_HEALTH::ERROR", "Datatype $type not found in HC")
            result.success(false)
            return
        }
        val classType = mapToType[type]!!

        scope.launch {
            try {
                healthConnectClient.deleteRecords(classType, idList, clientRecordIdsList)
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        }
    }

    private val mapSleepStageToType =
            hashMapOf(
                    0 to SLEEP_UNKNOWN,
                    1 to SLEEP_AWAKE,
                    2 to SLEEP_ASLEEP,
                    3 to SLEEP_OUT_OF_BED,
                    4 to SLEEP_LIGHT,
                    5 to SLEEP_DEEP,
                    6 to SLEEP_REM,
                    7 to SLEEP_AWAKE_IN_BED
            )

    private val mapMealTypeToType =
            hashMapOf(
                    BREAKFAST to MEAL_TYPE_BREAKFAST,
                    LUNCH to MEAL_TYPE_LUNCH,
                    DINNER to MEAL_TYPE_DINNER,
                    SNACK to MEAL_TYPE_SNACK,
                    MEAL_UNKNOWN to MEAL_TYPE_UNKNOWN,
            )

    private val mapTypeToMealType =
            hashMapOf(
                    MEAL_TYPE_BREAKFAST to BREAKFAST,
                    MEAL_TYPE_LUNCH to LUNCH,
                    MEAL_TYPE_DINNER to DINNER,
                    MEAL_TYPE_SNACK to SNACK,
                    MEAL_TYPE_UNKNOWN to MEAL_UNKNOWN,
            )

    private val mapToType =
            hashMapOf(
                    BODY_FAT_PERCENTAGE to BodyFatRecord::class,
                    LEAN_BODY_MASS to LeanBodyMassRecord::class,
                    HEIGHT to HeightRecord::class,
                    WEIGHT to WeightRecord::class,
                    STEPS to StepsRecord::class,
                    AGGREGATE_STEP_COUNT to StepsRecord::class,
                    ACTIVE_ENERGY_BURNED to ActiveCaloriesBurnedRecord::class,
                    HEART_RATE to HeartRateRecord::class,
                    BODY_TEMPERATURE to BodyTemperatureRecord::class,
                    BODY_WATER_MASS to BodyWaterMassRecord::class,
                    BLOOD_PRESSURE_SYSTOLIC to BloodPressureRecord::class,
                    BLOOD_PRESSURE_DIASTOLIC to BloodPressureRecord::class,
                    BLOOD_OXYGEN to OxygenSaturationRecord::class,
                    BLOOD_GLUCOSE to BloodGlucoseRecord::class,
                    HEART_RATE_VARIABILITY_RMSSD to HeartRateVariabilityRmssdRecord::class,
                    DISTANCE_DELTA to DistanceRecord::class,
                    WATER to HydrationRecord::class,
                    SLEEP_ASLEEP to SleepSessionRecord::class,
                    SLEEP_AWAKE to SleepSessionRecord::class,
                    SLEEP_AWAKE_IN_BED to SleepSessionRecord::class,
                    SLEEP_LIGHT to SleepSessionRecord::class,
                    SLEEP_DEEP to SleepSessionRecord::class,
                    SLEEP_REM to SleepSessionRecord::class,
                    SLEEP_OUT_OF_BED to SleepSessionRecord::class,
                    SLEEP_SESSION to SleepSessionRecord::class,
                    SLEEP_UNKNOWN to SleepSessionRecord::class,
                    WORKOUT to ExerciseSessionRecord::class,
                    NUTRITION to NutritionRecord::class,
                    RESTING_HEART_RATE to RestingHeartRateRecord::class,
                    BASAL_ENERGY_BURNED to BasalMetabolicRateRecord::class,
                    FLIGHTS_CLIMBED to FloorsClimbedRecord::class,
                    RESPIRATORY_RATE to RespiratoryRateRecord::class,
                    TOTAL_CALORIES_BURNED to TotalCaloriesBurnedRecord::class,
                    MENSTRUATION_FLOW to MenstruationFlowRecord::class,
                    // TODO: Implement remaining types
                    // "ActiveCaloriesBurned" to
                    // ActiveCaloriesBurnedRecord::class,
                    // "BasalBodyTemperature" to
                    // BasalBodyTemperatureRecord::class,
                    // "BasalMetabolicRate" to BasalMetabolicRateRecord::class,
                    // "BloodGlucose" to BloodGlucoseRecord::class,
                    // "BloodPressure" to BloodPressureRecord::class,
                    // "BodyTemperature" to BodyTemperatureRecord::class,
                    // "BoneMass" to BoneMassRecord::class,
                    // "CervicalMucus" to CervicalMucusRecord::class,
                    // "CyclingPedalingCadence" to
                    // CyclingPedalingCadenceRecord::class,
                    // "Distance" to DistanceRecord::class,
                    // "ElevationGained" to ElevationGainedRecord::class,
                    // "ExerciseSession" to ExerciseSessionRecord::class,
                    // "FloorsClimbed" to FloorsClimbedRecord::class,
                    // "HeartRate" to HeartRateRecord::class,
                    // "Height" to HeightRecord::class,
                    // "Hydration" to HydrationRecord::class,
                    // "MenstruationPeriod" to MenstruationPeriodRecord::class,
                    // "Nutrition" to NutritionRecord::class,
                    // "OvulationTest" to OvulationTestRecord::class,
                    // "OxygenSaturation" to OxygenSaturationRecord::class,
                    // "Power" to PowerRecord::class,
                    // "RespiratoryRate" to RespiratoryRateRecord::class,
                    // "RestingHeartRate" to RestingHeartRateRecord::class,
                    // "SexualActivity" to SexualActivityRecord::class,
                    // "SleepSession" to SleepSessionRecord::class,
                    // "SleepStage" to SleepStageRecord::class,
                    // "Speed" to SpeedRecord::class,
                    // "StepsCadence" to StepsCadenceRecord::class,
                    // "Steps" to StepsRecord::class,
                    // "TotalCaloriesBurned" to
                    // TotalCaloriesBurnedRecord::class,
                    // "Vo2Max" to Vo2MaxRecord::class,
                    // "Weight" to WeightRecord::class,
                    // "WheelchairPushes" to WheelchairPushesRecord::class,
                    )

    private val mapToAggregateMetric =
            hashMapOf(
                    HEIGHT to HeightRecord.HEIGHT_AVG,
                    WEIGHT to WeightRecord.WEIGHT_AVG,
                    STEPS to StepsRecord.COUNT_TOTAL,
                    AGGREGATE_STEP_COUNT to StepsRecord.COUNT_TOTAL,
                    ACTIVE_ENERGY_BURNED to ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL,
                    HEART_RATE to HeartRateRecord.MEASUREMENTS_COUNT,
                    DISTANCE_DELTA to DistanceRecord.DISTANCE_TOTAL,
                    WATER to HydrationRecord.VOLUME_TOTAL,
                    SLEEP_ASLEEP to SleepSessionRecord.SLEEP_DURATION_TOTAL,
                    SLEEP_AWAKE to SleepSessionRecord.SLEEP_DURATION_TOTAL,
                    SLEEP_IN_BED to SleepSessionRecord.SLEEP_DURATION_TOTAL,
                    TOTAL_CALORIES_BURNED to TotalCaloriesBurnedRecord.ENERGY_TOTAL
            )

    private val workoutTypeMap =
            mapOf(
                    // TODO: add skiing
                    // TODO: add skating
                    // TODO: add soccer
                    // TOOD: look into paddling
                    // TODO: add runnning
                    // TODO: look into hockey
                    "AMERICAN_FOOTBALL" to ExerciseSessionRecord.EXERCISE_TYPE_FOOTBALL_AMERICAN,
                    "AUSTRALIAN_FOOTBALL" to
                            ExerciseSessionRecord.EXERCISE_TYPE_FOOTBALL_AUSTRALIAN,
                    "BADMINTON" to ExerciseSessionRecord.EXERCISE_TYPE_BADMINTON,
                    "BASEBALL" to ExerciseSessionRecord.EXERCISE_TYPE_BASEBALL,
                    "BASKETBALL" to ExerciseSessionRecord.EXERCISE_TYPE_BASKETBALL,
                    "BIKING" to ExerciseSessionRecord.EXERCISE_TYPE_BIKING,
                    // "BIKING_STATIONARY" to ExerciseSessionRecord.EXERCISE_TYPE_BIKING_STATIONARY,
                    "BOXING" to ExerciseSessionRecord.EXERCISE_TYPE_BOXING,
                    "CALISTHENICS" to ExerciseSessionRecord.EXERCISE_TYPE_CALISTHENICS,
                    "CARDIO_DANCE" to ExerciseSessionRecord.EXERCISE_TYPE_DANCING,
                    "CRICKET" to ExerciseSessionRecord.EXERCISE_TYPE_CRICKET,
                    "CROSS_COUNTRY_SKIING" to ExerciseSessionRecord.EXERCISE_TYPE_SKIING,
                    "DANCING" to ExerciseSessionRecord.EXERCISE_TYPE_DANCING,
                    "DOWNHILL_SKIING" to ExerciseSessionRecord.EXERCISE_TYPE_SKIING,
                    "ELLIPTICAL" to ExerciseSessionRecord.EXERCISE_TYPE_ELLIPTICAL,
                    "FENCING" to ExerciseSessionRecord.EXERCISE_TYPE_FENCING,
                    "FRISBEE_DISC" to ExerciseSessionRecord.EXERCISE_TYPE_FRISBEE_DISC,
                    "GOLF" to ExerciseSessionRecord.EXERCISE_TYPE_GOLF,
                    "GUIDED_BREATHING" to ExerciseSessionRecord.EXERCISE_TYPE_GUIDED_BREATHING,
                    "GYMNASTICS" to ExerciseSessionRecord.EXERCISE_TYPE_GYMNASTICS,
                    "HANDBALL" to ExerciseSessionRecord.EXERCISE_TYPE_HANDBALL,
                    "HIGH_INTENSITY_INTERVAL_TRAINING" to
                            ExerciseSessionRecord.EXERCISE_TYPE_HIGH_INTENSITY_INTERVAL_TRAINING,
                    "HIKING" to ExerciseSessionRecord.EXERCISE_TYPE_HIKING,
                    // "HOCKEY" to ExerciseSessionRecord.EXERCISE_TYPE_HOCKEY,
                    "ICE_SKATING" to ExerciseSessionRecord.EXERCISE_TYPE_ICE_SKATING,
                    "MARTIAL_ARTS" to ExerciseSessionRecord.EXERCISE_TYPE_MARTIAL_ARTS,
                    "PARAGLIDING" to ExerciseSessionRecord.EXERCISE_TYPE_PARAGLIDING,
                    "PILATES" to ExerciseSessionRecord.EXERCISE_TYPE_PILATES,
                    "RACQUETBALL" to ExerciseSessionRecord.EXERCISE_TYPE_RACQUETBALL,
                    "ROCK_CLIMBING" to ExerciseSessionRecord.EXERCISE_TYPE_ROCK_CLIMBING,
                    "ROWING" to ExerciseSessionRecord.EXERCISE_TYPE_ROWING,
                    "ROWING_MACHINE" to ExerciseSessionRecord.EXERCISE_TYPE_ROWING_MACHINE,
                    "RUGBY" to ExerciseSessionRecord.EXERCISE_TYPE_RUGBY,
                    "RUNNING_TREADMILL" to ExerciseSessionRecord.EXERCISE_TYPE_RUNNING_TREADMILL,
                    "RUNNING" to ExerciseSessionRecord.EXERCISE_TYPE_RUNNING,
                    "SAILING" to ExerciseSessionRecord.EXERCISE_TYPE_SAILING,
                    "SCUBA_DIVING" to ExerciseSessionRecord.EXERCISE_TYPE_SCUBA_DIVING,
                    "SKATING" to ExerciseSessionRecord.EXERCISE_TYPE_SKATING,
                    "SKIING" to ExerciseSessionRecord.EXERCISE_TYPE_SKIING,
                    "SNOWBOARDING" to ExerciseSessionRecord.EXERCISE_TYPE_SNOWBOARDING,
                    "SNOWSHOEING" to ExerciseSessionRecord.EXERCISE_TYPE_SNOWSHOEING,
                    // "SOCCER" to ExerciseSessionRecord.EXERCISE_TYPE_FOOTBALL_SOCCER,
                    "SOCIAL_DANCE" to ExerciseSessionRecord.EXERCISE_TYPE_DANCING,
                    "SOFTBALL" to ExerciseSessionRecord.EXERCISE_TYPE_SOFTBALL,
                    "SQUASH" to ExerciseSessionRecord.EXERCISE_TYPE_SQUASH,
                    "STAIR_CLIMBING_MACHINE" to
                            ExerciseSessionRecord.EXERCISE_TYPE_STAIR_CLIMBING_MACHINE,
                    "STAIR_CLIMBING" to ExerciseSessionRecord.EXERCISE_TYPE_STAIR_CLIMBING,
                    "STRENGTH_TRAINING" to ExerciseSessionRecord.EXERCISE_TYPE_STRENGTH_TRAINING,
                    "SURFING" to ExerciseSessionRecord.EXERCISE_TYPE_SURFING,
                    "SWIMMING_OPEN_WATER" to
                            ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_OPEN_WATER,
                    "SWIMMING_POOL" to ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_POOL,
                    "TABLE_TENNIS" to ExerciseSessionRecord.EXERCISE_TYPE_TABLE_TENNIS,
                    "TENNIS" to ExerciseSessionRecord.EXERCISE_TYPE_TENNIS,
                    "VOLLEYBALL" to ExerciseSessionRecord.EXERCISE_TYPE_VOLLEYBALL,
                    "WALKING" to ExerciseSessionRecord.EXERCISE_TYPE_WALKING,
                    "WATER_POLO" to ExerciseSessionRecord.EXERCISE_TYPE_WATER_POLO,
                    "WEIGHTLIFTING" to ExerciseSessionRecord.EXERCISE_TYPE_WEIGHTLIFTING,
                    "WHEELCHAIR" to ExerciseSessionRecord.EXERCISE_TYPE_WHEELCHAIR,
                    "WHEELCHAIR_RUN_PACE" to ExerciseSessionRecord.EXERCISE_TYPE_WHEELCHAIR,
                    "WHEELCHAIR_WALK_PACE" to ExerciseSessionRecord.EXERCISE_TYPE_WHEELCHAIR,
                    "YOGA" to ExerciseSessionRecord.EXERCISE_TYPE_YOGA,
                    "OTHER" to ExerciseSessionRecord.EXERCISE_TYPE_OTHER_WORKOUT,
            )
}
