package net.petleo.flutter_health

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
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import android.os.Looper
import com.google.android.gms.fitness.data.*
import kotlin.collections.HashMap

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111

class FlutterHealthPlugin(val activity: Activity, val channel: MethodChannel) : MethodCallHandler, ActivityResultListener, Result {

    private var result: Result? = null
    private var handler: Handler? = null

    private var BODY_FAT_PERCENTAGE = "bodyFatPercentage"
    private var HEIGHT = "height"
    private var WEIGHT = "bodyMass"
    private var BODY_MASS_INDEX = "bodyMassIndex"
    private var WAIST_CIRCUMFERENCE = "waistCircumference"
    private var STEPS = "stepCount"
    private var BASAL_ENERGY_BURNED = "basalEnergyBurned"
    private var ACTIVE_ENERGY_BURNED = "activeEnergyBurned"
    private var HEART_RATE = "heartRate"
    private var BODY_TEMPERATURE = "bodyTemperature"
    private var BLOOD_PRESSURE_SYSTOLIC = "bloodPressureSystolic"
    private var BLOOD_PRESSURE_DIASTOLIC = "bloodPressureDiastolic"
    private var RESTING_HEART_RATE = "restingHeartRate"
    private var WALKING_HEART_RATE = "walkingHeartRateAverage"
    private var BLOOD_OXYGEN = "oxygenSaturation"
    private var BLOOD_GLUCOSE = "bloodGlucose"

    var unitDict: Map<String, Field>? = null


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_health")
            val plugin = FlutterHealthPlugin(registrar.activity(), channel)
            plugin.init()
            print(plugin.unitDict)
            registrar.addActivityResultListener(plugin)
            channel.setMethodCallHandler(plugin)
        }
    }

    fun init() {
        unitDict = mapOf<String, Field>(
                BODY_FAT_PERCENTAGE to Field.FIELD_PERCENTAGE,
                HEIGHT to Field.FIELD_HEIGHT,
                WEIGHT to Field.FIELD_WEIGHT,
                STEPS to Field.FIELD_STEPS,
                ACTIVE_ENERGY_BURNED to Field.FIELD_CALORIES,
                HEART_RATE to Field.FIELD_BPM,
                BODY_TEMPERATURE to HealthFields.FIELD_BODY_TEMPERATURE,
                BLOOD_PRESSURE_SYSTOLIC to HealthFields.FIELD_BLOOD_PRESSURE_SYSTOLIC,
                BLOOD_PRESSURE_DIASTOLIC to HealthFields.FIELD_BLOOD_PRESSURE_DIASTOLIC,
                BLOOD_OXYGEN to HealthFields.FIELD_OXYGEN_SATURATION,
                BLOOD_GLUCOSE to HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL
        )
    }


    fun MainThreadResult(result: Result) {
        this.result = result
        handler = Handler(Looper.getMainLooper())
    }

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



    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent): Boolean {
        Log.d("FLUTTER_HEALTH", "GOOGLE FIT ON ACTIVITY RESULT $resultCode")
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == GOOGLE_FIT_PERMISSIONS_REQUEST_CODE) {
                Log.d("FLUTTER_HEALTH", "Access Granted!")
                mResult?.success(true)
            } else {
                Log.d("FLUTTER_HEALTH", "Access Denied!")
            }
        }
        return false
    }

    var mResult: Result? = null

    fun getDataType(type: String): DataType {
        val dataType = when (type) {
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
            else -> DataType.TYPE_STEP_COUNT_DELTA
        }
        return dataType
    }

    val fitnessOptions = FitnessOptions.builder()
            .addDataType(getDataType(BODY_FAT_PERCENTAGE), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(HEIGHT), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(WEIGHT), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(STEPS), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(ACTIVE_ENERGY_BURNED), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(HEART_RATE), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(BODY_TEMPERATURE), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(BLOOD_PRESSURE_SYSTOLIC), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(BLOOD_OXYGEN), FitnessOptions.ACCESS_READ)
            .addDataType(getDataType(BLOOD_GLUCOSE), FitnessOptions.ACCESS_READ)
            .build()


    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "requestAuthorization") {
            mResult = result

            if (!GoogleSignIn.hasPermissions(GoogleSignIn.getLastSignedInAccount(activity), fitnessOptions)) {
                Log.d("authResult 111", activity.localClassName)
                GoogleSignIn.requestPermissions(
                        activity, // your activity
                        GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
                        GoogleSignIn.getLastSignedInAccount(activity),
                        fitnessOptions)
            } else {
                mResult?.success(true)
                Log.d("FLUTTER_HEALTH", "Access already granted before!")
            }
        } else if (call.method == "getData") {
            val type = call.argument<String>("dataTypeKey")
            val startTime = call.argument<Long>("startDate")
            val endTime = call.argument<Long>("endDate")
            val dataType = getDataType(type!!)

            thread {
                val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity.applicationContext, fitnessOptions)

                val response = Fitness.getHistoryClient(activity.applicationContext, googleSignInAccount)
                        .readData(DataReadRequest.Builder()
                                .read(dataType)
                                .setTimeRange(startTime ?: 0, endTime
                                        ?: 0, TimeUnit.MILLISECONDS)
                                .build())

                val readDataResult = Tasks.await<DataReadResponse>(response)
                val dataSet = readDataResult.getDataSet(dataType)
                val unit = unitDict?.get(type)

                val map = dataSet.dataPoints.map {
                    val map = HashMap<String, Any>()

                    map["value"] = try {
                        it.getValue(unit).asFloat()
                    } catch (e1: Exception) {
                        try {
                            it.getValue(unit).asInt()
                        } catch (e2: Exception) {
                            try {
                                it.getValue(unit).asString()
                            } catch (e3: Exception) {
                                Log.e("FLUTTER_HEALTH::ERROR", e3.toString())
                            }
                        }
                    }

                    map["date_from"] = it.getStartTime(TimeUnit.MILLISECONDS)
                    map["date_to"] = it.getEndTime(TimeUnit.MILLISECONDS)
                    map["unit"] = unit.toString()
                    return@map map
                }
                activity.runOnUiThread { result.success(map) }
            }

        } else {
            result.notImplemented()
        }
    }
}