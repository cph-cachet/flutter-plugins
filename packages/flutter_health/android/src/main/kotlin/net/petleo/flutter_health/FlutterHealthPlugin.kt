package net.petleo.flutter_health

import android.app.Activity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
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
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import android.os.Looper
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.data.HealthDataTypes
import com.google.android.gms.fitness.data.HealthFields
import kotlin.collections.HashMap

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111

class FlutterHealthPlugin(val activity: Activity, val channel: MethodChannel) : MethodCallHandler, ActivityResultListener, Result {

    private var result: Result? = null
    private var handler: Handler? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_health")
            val plugin = FlutterHealthPlugin(registrar.activity(), channel)

            registrar.addActivityResultListener(plugin)
            channel.setMethodCallHandler(plugin)
        }
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

    val fitnessOptions = FitnessOptions.builder()
            .addDataType(DataType.TYPE_BODY_FAT_PERCENTAGE, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_HEIGHT, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_CALORIES_EXPENDED, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_HEART_RATE_BPM, FitnessOptions.ACCESS_READ)
            .addDataType(HealthDataTypes.TYPE_BODY_TEMPERATURE, FitnessOptions.ACCESS_READ)
            .addDataType(HealthDataTypes.TYPE_BLOOD_PRESSURE, FitnessOptions.ACCESS_READ)
            .addDataType(HealthDataTypes.TYPE_OXYGEN_SATURATION, FitnessOptions.ACCESS_READ)
            .addDataType(HealthDataTypes.TYPE_BLOOD_GLUCOSE, FitnessOptions.ACCESS_READ)
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
        } else if (call.method == "getGFHealthData") {
            val type = call.argument<Int>("index")
            val startTime = call.argument<Long>("startDate")
            val endTime = call.argument<Long>("endDate")
            val fields = listOf(Field.FIELD_PERCENTAGE, Field.FIELD_HEIGHT, Field.FIELD_STEPS, Field.FIELD_CALORIES, Field.FIELD_BPM, HealthFields.FIELD_BODY_TEMPERATURE, HealthFields.FIELD_BLOOD_PRESSURE_SYSTOLIC, HealthFields.FIELD_OXYGEN_SATURATION, HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL)
            val dataType = when (type) {
                0 -> DataType.TYPE_BODY_FAT_PERCENTAGE
                1 -> DataType.TYPE_HEIGHT
                2 -> DataType.TYPE_STEP_COUNT_DELTA
                3 -> DataType.TYPE_CALORIES_EXPENDED
                4 -> DataType.TYPE_HEART_RATE_BPM
                5 -> HealthDataTypes.TYPE_BODY_TEMPERATURE
                6 -> HealthDataTypes.TYPE_BLOOD_PRESSURE
                7 -> HealthDataTypes.TYPE_OXYGEN_SATURATION
                8 -> HealthDataTypes.TYPE_BLOOD_GLUCOSE
                else -> DataType.TYPE_STEP_COUNT_DELTA
            }
            thread {
                val gsa = GoogleSignIn.getAccountForExtension(activity.applicationContext, fitnessOptions)

                val response = Fitness.getHistoryClient(activity.applicationContext, gsa)
                        .readData(DataReadRequest.Builder()
                                .read(dataType)
                                .setTimeRange(startTime ?: 0, endTime
                                        ?: 0, TimeUnit.MILLISECONDS)
                                .build())

                val readDataResult = Tasks.await<DataReadResponse>(response)
                val dataSet = readDataResult.getDataSet(dataType)

                val map = dataSet.dataPoints.map {
                    val map = HashMap<String, Any>()
                    map["value"] = try {
                        it.getValue(fields[type ?: 0]).asFloat()
                    } catch (e1: Exception) {
                        try {
                            it.getValue(fields[type ?: 0]).asInt()
                        } catch (e2: Exception) {
                            try {
                                it.getValue(fields[type ?: 0]).asString()
                            }catch (e3: Exception){
                                Log.e("FLUTTER_HEALTH::ERROR", e3.toString())
                            }
                        }
                    }
                    if(dataType == HealthDataTypes.TYPE_BLOOD_PRESSURE)
                        map["value2"] = try {
                            it.getValue(HealthFields.FIELD_BLOOD_PRESSURE_DIASTOLIC).asFloat()
                        } catch (e1: Exception) {
                            try {
                                it.getValue(fields[type ?: 0]).asInt()
                            } catch (e2: Exception) {
                                try {
                                    it.getValue(fields[type ?: 0]).asString()
                                }catch (e3: Exception){
                                    Log.e("FLUTTER_HEALTH::ERROR", e3.toString())
                                }
                            }
                        }
                    map["date_from"] = it.getStartTime(TimeUnit.MILLISECONDS)
                    map["date_to"] = it.getEndTime(TimeUnit.MILLISECONDS)
                    map["unit"] = ""
                    map["data_type_index"] = type?:-1
                    return@map map
                }
                activity.runOnUiThread { result.success(map) }
            }

        } else {
            result.notImplemented()
        }
    }
}