package cachet.plugins.health

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.*
import kotlin.collections.ArrayList
import kotlin.reflect.KClass

const val HEALTH_CONNECT_PERMISSIONS_REQUEST_CODE = 2222
const val CHANNEL_NAME = "flutter_health"

class HealthPlugin(private var channel: MethodChannel? = null) : MethodCallHandler,
    ActivityResultListener, Result, ActivityAware, FlutterPlugin {
    private var result: Result? = null
    private var handler: Handler? = null
    private var activity: Activity? = null
    private var healthConnectRequestPermissionsLauncher: ActivityResultLauncher<Set<String>>? = null
    private var BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    private var WEIGHT = "WEIGHT"
    private var NUTRITION = "NUTRITION"

    // The scope for the UI thread
    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    private fun checkAvailability() {
        val healthConnectStatus = HealthConnectClient.getSdkStatus(activity!!.applicationContext)
        healthConnectAvailable = healthConnectStatus == HealthConnectClient.SDK_AVAILABLE

        Log.i("FLUTTER_HEALTH", "checkAvailability")
        Log.i("FLUTTER_HEALTH", healthConnectAvailable.toString())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
        activity = null
    }

    override fun success(p0: Any?) {
        handler?.post { result?.success(p0) }
    }

    override fun notImplemented() {
        handler?.post { result?.notImplemented() }
    }

    override fun error(
        errorCode: String, errorMessage: String?, errorDetails: Any?
    ) {
        handler?.post { result?.error(errorCode, errorMessage, errorDetails) }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == HEALTH_CONNECT_PERMISSIONS_REQUEST_CODE) {
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

    @Suppress("UNCHECKED_CAST")
    private suspend fun writeDataHealthConnect(call: MethodCall, result: Result) {
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

    private suspend fun getHealthConnectData(call: MethodCall, result: Result) {
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
                val startDateInner = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDateInner = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDateInner.toInstant(),
                        endDateInner.toInstant()
                    )
                )

                try {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<WeightRecord> = response.records

                    val healthData = dataList.mapIndexed { _, it ->
                        val zonedDateTime =
                            dateTimeWithOffsetOrDefault(it.time, it.zoneOffset)
                        val uid = it.metadata.id
                        val weight = it.weight.inGrams
                        return@mapIndexed hashMapOf(
                            "zonedDateTime" to zonedDateTime.toInstant().toEpochMilli(),
                            "uid" to uid,
                            "weight" to weight
                        )
                    }
                    result.success(healthData)
                } catch (e: Exception) {
                    Log.e("FLUTTER_HEALTH", e.message, null)
                    result.success(false)
                }

            }
            BODY_FAT_PERCENTAGE -> {
                val startDateInner = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDateInner = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = BodyFatRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDateInner.toInstant(),
                        endDateInner.toInstant()
                    )
                )
                try {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<BodyFatRecord> = response.records

                    val healthData = dataList.mapIndexed { _, it ->
                        val zonedDateTime =
                            dateTimeWithOffsetOrDefault(it.time, it.zoneOffset)
                        val uid = it.metadata.id
                        val bodyFat = it.percentage.value
                        return@mapIndexed hashMapOf(
                            "zonedDateTime" to zonedDateTime.toInstant().toEpochMilli(),
                            "uid" to uid,
                            "bodyFat" to bodyFat
                        )
                    }
                    result.success(healthData)
                } catch (e: Exception) {
                    Log.e("FLUTTER_HEALTH", e.message, null)
                    result.success(false)
                }
            }
            NUTRITION -> {
                val startDateInner = ZonedDateTime.parse(
                    startDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val endDateInner = ZonedDateTime.parse(
                    endDate,
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.withZone(ZoneId.systemDefault())
                )
                val request = ReadRecordsRequest(
                    recordType = NutritionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDateInner.toInstant(),
                        endDateInner.toInstant()
                    ),
                )
                try {
                    val response = healthConnectClient.readRecords(request)
                    val dataList: List<NutritionRecord> = response.records
                    val healthData = dataList.mapIndexed { _, it ->
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
                    result.success(healthData)
                } catch (e: Exception) {
                    Log.e("FLUTTER_HEALTH", e.message, null)
                    result.success(false)
                }
            }
        }
    }

    private suspend fun deleteHealthConnectData(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val type = call.argument<String>("dataTypeKey")!!
        val uID = call.argument<String>("uID")!!
        mResult = result
        when (type) {
            WEIGHT -> {
                healthConnectClient.deleteRecords(
                    WeightRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
            BODY_FAT_PERCENTAGE -> {
                healthConnectClient.deleteRecords(
                    BodyFatRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
            NUTRITION -> {
                healthConnectClient.deleteRecords(
                    NutritionRecord::class,
                    recordIdsList = listOf(uID),
                    clientRecordIdsList = emptyList()
                )
                result.success(true)
            }
        }

    }

    private suspend fun deleteHealthConnectDataByDateRange(call: MethodCall, result: Result) {
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

                healthConnectClient.deleteRecords(
                    WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    )
                )
                result.success(true)
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

                healthConnectClient.deleteRecords(
                    BodyFatRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        startDate.toInstant(),
                        endDate.toInstant()
                    )
                )
                result.success(true)
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

    private fun dateTimeWithOffsetOrDefault(time: Instant, offset: ZoneOffset?): ZonedDateTime =
        if (offset != null) {
            ZonedDateTime.ofInstant(time, offset)
        } else {
            ZonedDateTime.ofInstant(time, ZoneId.systemDefault())
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

    private var healthConnectAvailable = false

    private fun isHealthConnectAvailable(activityLocal: Activity?, call: MethodCall, result: Result) {
        if (activityLocal == null) {
            result.success(false)
            return
        }

        val install = call.argument<Boolean>("install")!!

        val sdkStatus = HealthConnectClient.getSdkStatus(activityLocal)
        val success = sdkStatus == HealthConnectClient.SDK_AVAILABLE

        healthConnectAvailable = success

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
            } catch (e: Exception) {
                Log.e("FLUTTER_HEALTH", e.message, null)
                result.success(false)
                return
            }
        }

        result.success(success)
    }

    private suspend fun hasPermissionHealthConnect(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val permissionList = callToHealthConnectTypes(call)
        mResult = result

        val granted = healthConnectClient.permissionController.getGrantedPermissions()

        if (granted.containsAll(permissionList.toSet())) {
            mResult?.success(true)
        } else {
            mResult?.success(false)
            // Do we need to request here?
        }
    }

    private suspend fun requestHealthConnectPermission(call: MethodCall, result: Result) {
        if (activity == null) {
            result.success(false)
            return
        }
        mResult = result
        val healthConnectClient = HealthConnectClient.getOrCreate(activity!!.applicationContext)
        val permissionList = callToHealthConnectTypes(call)
        val permissionListSet = permissionList.toSet()

        val granted = healthConnectClient.permissionController.getGrantedPermissions()

        if (granted.containsAll(permissionListSet)) {
            mResult?.success(true)
        } else {
            if(healthConnectRequestPermissionsLauncher == null) {
                mResult?.success(false)
                Log.i("FLUTTER_HEALTH", "Permission launcher not found")
            } else {
                healthConnectRequestPermissionsLauncher!!.launch(permissionListSet)
            }
        }
    }

    private fun onHealthConnectPermissionCallback(permissionGranted: Set<String>)
    {
        if(permissionGranted.isEmpty()) {
            mResult?.success(false)
            Log.i("FLUTTER_HEALTH", "Access Denied (to Health Connect)!")

        } else {
            mResult?.success(true)
            Log.i("FLUTTER_HEALTH", "Access Granted (to Health Connect)!")
        }

    }

    /// Handle calls from the MethodChannel
    override fun onMethodCall(call: MethodCall, result: Result) {
        val activityContext = activity

        mainScope.launch {
            when (call.method) {
                "hasPermissionsHealthConnect" -> {
                    hasPermissionHealthConnect(call, result)
                }
                "writeDataHealthConnect" -> {
                    try {
                        writeDataHealthConnect(call, result)
                    } catch (e: Exception) {
                        Log.e("FLUTTER_HEALTH", e.message, null)
                    }
                }
                "getHealthConnectData" -> {
                    getHealthConnectData(call, result)
                }
                "deleteHealthConnectData" -> {
                    deleteHealthConnectData(call, result)
                }
                "requestHealthConnectPermission" -> {
                    requestHealthConnectPermission(call, result)
                }
                "isHealthConnectAvailable" -> {
                    isHealthConnectAvailable(activityContext, call, result)
                }
                "deleteHealthConnectDataByDateRange" -> {
                    deleteHealthConnectDataByDateRange(call, result)
                }
                else -> result.notImplemented()
            }
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

        checkAvailability()

        val requestPermissionActivityContract = PermissionController.createRequestPermissionResultContract()

        healthConnectRequestPermissionsLauncher =(activity as ComponentActivity).registerForActivityResult(requestPermissionActivityContract) { granted ->
            onHealthConnectPermissionCallback(granted)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
        healthConnectRequestPermissionsLauncher = null
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