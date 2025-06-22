import Flutter
import HealthKit
import UIKit

/// Main plugin class that coordinates health data operations
public class SwiftHealthPlugin: NSObject, FlutterPlugin {
    
    // Health store and type dictionaries
    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()
    var healthDataQuantityTypes = [HKQuantityType]()
    var characteristicsDataTypes = [HKCharacteristicType]()
    var heartRateEventTypes = Set<HKSampleType>()
    var headacheType = Set<HKSampleType>()
    var allDataTypes = Set<HKSampleType>()
    var dataTypesDict: [String: HKSampleType] = [:]
    var dataQuantityTypesDict: [String: HKQuantityType] = [:]
    var unitDict: [String: HKUnit] = [:]
    var workoutActivityTypeMap: [String: HKWorkoutActivityType] = [:]
    var characteristicsTypesDict: [String: HKCharacteristicType] = [:]
    var nutritionList: [String] = []
    
    // Health Data Type Keys
    let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    let ATRIAL_FIBRILLATION_BURDEN = "ATRIAL_FIBRILLATION_BURDEN"
    let AUDIOGRAM = "AUDIOGRAM"
    let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
    let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    let BLOOD_OXYGEN = "BLOOD_OXYGEN"
    let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    let LEAN_BODY_MASS = "LEAN_BODY_MASS"
    let BODY_MASS_INDEX = "BODY_MASS_INDEX"
    let BODY_TEMPERATURE = "BODY_TEMPERATURE"
    // Nutrition
    let DIETARY_CARBS_CONSUMED = "DIETARY_CARBS_CONSUMED"
    let DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
    let DIETARY_FATS_CONSUMED = "DIETARY_FATS_CONSUMED"
    let DIETARY_PROTEIN_CONSUMED = "DIETARY_PROTEIN_CONSUMED"
    let DIETARY_CAFFEINE = "DIETARY_CAFFEINE"
    let DIETARY_FIBER = "DIETARY_FIBER"
    let DIETARY_SUGAR = "DIETARY_SUGAR"
    let DIETARY_FAT_MONOUNSATURATED = "DIETARY_FAT_MONOUNSATURATED"
    let DIETARY_FAT_POLYUNSATURATED = "DIETARY_FAT_POLYUNSATURATED"
    let DIETARY_FAT_SATURATED = "DIETARY_FAT_SATURATED"
    let DIETARY_CHOLESTEROL = "DIETARY_CHOLESTEROL"
    let DIETARY_VITAMIN_A = "DIETARY_VITAMIN_A"
    let DIETARY_THIAMIN = "DIETARY_THIAMIN"
    let DIETARY_RIBOFLAVIN = "DIETARY_RIBOFLAVIN"
    let DIETARY_NIACIN = "DIETARY_NIACIN"
    let DIETARY_PANTOTHENIC_ACID = "DIETARY_PANTOTHENIC_ACID"
    let DIETARY_VITAMIN_B6 = "DIETARY_VITAMIN_B6"
    let DIETARY_BIOTIN = "DIETARY_BIOTIN"
    let DIETARY_VITAMIN_B12 = "DIETARY_VITAMIN_B12"
    let DIETARY_VITAMIN_C = "DIETARY_VITAMIN_C"
    let DIETARY_VITAMIN_D = "DIETARY_VITAMIN_D"
    let DIETARY_VITAMIN_E = "DIETARY_VITAMIN_E"
    let DIETARY_VITAMIN_K = "DIETARY_VITAMIN_K"
    let DIETARY_FOLATE = "DIETARY_FOLATE"
    let DIETARY_CALCIUM = "DIETARY_CALCIUM"
    let DIETARY_CHLORIDE = "DIETARY_CHLORIDE"
    let DIETARY_IRON = "DIETARY_IRON"
    let DIETARY_MAGNESIUM = "DIETARY_MAGNESIUM"
    let DIETARY_PHOSPHORUS = "DIETARY_PHOSPHORUS"
    let DIETARY_POTASSIUM = "DIETARY_POTASSIUM"
    let DIETARY_SODIUM = "DIETARY_SODIUM"
    let DIETARY_ZINC = "DIETARY_ZINC"
    let DIETARY_WATER = "WATER"
    let DIETARY_CHROMIUM = "DIETARY_CHROMIUM"
    let DIETARY_COPPER = "DIETARY_COPPER"
    let DIETARY_IODINE = "DIETARY_IODINE"
    let DIETARY_MANGANESE = "DIETARY_MANGANESE"
    let DIETARY_MOLYBDENUM = "DIETARY_MOLYBDENUM"
    let DIETARY_SELENIUM = "DIETARY_SELENIUM"
    let NUTRITION_KEYS: [String: HKQuantityTypeIdentifier] = [
        "calories": .dietaryEnergyConsumed,
        "protein": .dietaryProtein,
        "carbs": .dietaryCarbohydrates,
        "fat": .dietaryFatTotal,
        "caffeine": .dietaryCaffeine,
        "vitamin_a": .dietaryVitaminA,
        "b1_thiamine": .dietaryThiamin,
        "b2_riboflavin": .dietaryRiboflavin,
        "b3_niacin" : .dietaryNiacin,
        "b5_pantothenic_acid" : .dietaryPantothenicAcid,
        "b6_pyridoxine" : .dietaryVitaminB6,
        "b7_biotin" : .dietaryBiotin,
        "b9_folate" : .dietaryFolate,
        "b12_cobalamin": .dietaryVitaminB12,
        "vitamin_c": .dietaryVitaminC,
        "vitamin_d": .dietaryVitaminD,
        "vitamin_e": .dietaryVitaminE,
        "vitamin_k": .dietaryVitaminK,
        "calcium": .dietaryCalcium,
        "chloride": .dietaryChloride,
        "cholesterol": .dietaryCholesterol,
        "chromium": .dietaryChromium,
        "copper": .dietaryCopper,
        "fat_unsaturated": .dietaryFatMonounsaturated,
        "fat_monounsaturated": .dietaryFatMonounsaturated,
        "fat_polyunsaturated": .dietaryFatPolyunsaturated,
        "fat_saturated": .dietaryFatSaturated,
        // "fat_trans_monoenoic": .dietaryFatTransMonoenoic,
        "fiber": .dietaryFiber,
        "iodine": .dietaryIodine,
        "iron": .dietaryIron,
        "magnesium": .dietaryMagnesium,
        "manganese": .dietaryManganese,
        "molybdenum": .dietaryMolybdenum,
        "phosphorus": .dietaryPhosphorus,
        "potassium": .dietaryPotassium,
        "selenium": .dietarySelenium,
        "sodium": .dietarySodium,
        "sugar": .dietarySugar,
        "water": .dietaryWater,
        "zinc": .dietaryZinc,
    ]
    let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
    let FORCED_EXPIRATORY_VOLUME = "FORCED_EXPIRATORY_VOLUME"
    let HEART_RATE = "HEART_RATE"
    let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
    let HEIGHT = "HEIGHT"
    let INSULIN_DELIVERY = "INSULIN_DELIVERY"
    let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
    let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
    let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
    let RESTING_HEART_RATE = "RESTING_HEART_RATE"
    let RESPIRATORY_RATE = "RESPIRATORY_RATE"
    let PERIPHERAL_PERFUSION_INDEX = "PERIPHERAL_PERFUSION_INDEX"
    let STEPS = "STEPS"
    let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
    let WALKING_HEART_RATE = "WALKING_HEART_RATE"
    let WEIGHT = "WEIGHT"
    let DISTANCE_WALKING_RUNNING = "DISTANCE_WALKING_RUNNING"
    let DISTANCE_SWIMMING = "DISTANCE_SWIMMING"
    let DISTANCE_CYCLING = "DISTANCE_CYCLING"
    let WALKING_SPEED = "WALKING_SPEED"
    let FLIGHTS_CLIMBED = "FLIGHTS_CLIMBED"
    let MINDFULNESS = "MINDFULNESS"
    let SLEEP_ASLEEP = "SLEEP_ASLEEP"
    let SLEEP_AWAKE = "SLEEP_AWAKE"
    let SLEEP_DEEP = "SLEEP_DEEP"
    let SLEEP_IN_BED = "SLEEP_IN_BED"
    let SLEEP_LIGHT = "SLEEP_LIGHT"
    let SLEEP_REM = "SLEEP_REM"
    
    let EXERCISE_TIME = "EXERCISE_TIME"
    let WORKOUT = "WORKOUT"
    let HEADACHE_UNSPECIFIED = "HEADACHE_UNSPECIFIED"
    let HEADACHE_NOT_PRESENT = "HEADACHE_NOT_PRESENT"
    let HEADACHE_MILD = "HEADACHE_MILD"
    let HEADACHE_MODERATE = "HEADACHE_MODERATE"
    let HEADACHE_SEVERE = "HEADACHE_SEVERE"
    let ELECTROCARDIOGRAM = "ELECTROCARDIOGRAM"
    let NUTRITION = "NUTRITION"
    let BIRTH_DATE = "BIRTH_DATE"
    let GENDER = "GENDER"
    let BLOOD_TYPE = "BLOOD_TYPE"
    let MENSTRUATION_FLOW = "MENSTRUATION_FLOW"
    let WATER_TEMPERATURE = "WATER_TEMPERATURE"
    let UNDERWATER_DEPTH = "UNDERWATER_DEPTH"
    let UV_INDEX = "UV_INDEX"
    
    
    // Health Unit types
    // MOLE_UNIT_WITH_MOLAR_MASS, // requires molar mass input - not supported yet
    // MOLE_UNIT_WITH_PREFIX_MOLAR_MASS, // requires molar mass & prefix input - not supported yet
    let GRAM = "GRAM"
    let KILOGRAM = "KILOGRAM"
    let OUNCE = "OUNCE"
    let POUND = "POUND"
    let STONE = "STONE"
    let METER = "METER"
    let INCH = "INCH"
    let FOOT = "FOOT"
    let YARD = "YARD"
    let MILE = "MILE"
    let LITER = "LITER"
    let MILLILITER = "MILLILITER"
    let FLUID_OUNCE_US = "FLUID_OUNCE_US"
    let FLUID_OUNCE_IMPERIAL = "FLUID_OUNCE_IMPERIAL"
    let CUP_US = "CUP_US"
    let CUP_IMPERIAL = "CUP_IMPERIAL"
    let PINT_US = "PINT_US"
    let PINT_IMPERIAL = "PINT_IMPERIAL"
    let PASCAL = "PASCAL"
    let MILLIMETER_OF_MERCURY = "MILLIMETER_OF_MERCURY"
    let INCHES_OF_MERCURY = "INCHES_OF_MERCURY"
    let CENTIMETER_OF_WATER = "CENTIMETER_OF_WATER"
    let ATMOSPHERE = "ATMOSPHERE"
    let DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL = "DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL"
    let SECOND = "SECOND"
    let MILLISECOND = "MILLISECOND"
    let MINUTE = "MINUTE"
    let HOUR = "HOUR"
    let DAY = "DAY"
    let JOULE = "JOULE"
    let KILOCALORIE = "KILOCALORIE"
    let LARGE_CALORIE = "LARGE_CALORIE"
    let SMALL_CALORIE = "SMALL_CALORIE"
    let DEGREE_CELSIUS = "DEGREE_CELSIUS"
    let DEGREE_FAHRENHEIT = "DEGREE_FAHRENHEIT"
    let KELVIN = "KELVIN"
    let DECIBEL_HEARING_LEVEL = "DECIBEL_HEARING_LEVEL"
    let HERTZ = "HERTZ"
    let SIEMEN = "SIEMEN"
    let VOLT = "VOLT"
    let INTERNATIONAL_UNIT = "INTERNATIONAL_UNIT"
    let COUNT = "COUNT"
    let PERCENT = "PERCENT"
    let BEATS_PER_MINUTE = "BEATS_PER_MINUTE"
    let RESPIRATIONS_PER_MINUTE = "RESPIRATIONS_PER_MINUTE"
    let MILLIGRAM_PER_DECILITER = "MILLIGRAM_PER_DECILITER"
    let METER_PER_SECOND = "METER_PER_SECOND"
    let UNKNOWN_UNIT = "UNKNOWN_UNIT"
    let NO_UNIT = "NO_UNIT"
    
    struct PluginError: Error {
        let message: String
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_health", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        initializeTypes()
        
        switch call.method {
        case "checkIfHealthDataAvailable":
            healthDataOperations.checkIfHealthDataAvailable(call: call, result: result)
            
        case "requestAuthorization":
            do {
                try healthDataOperations.requestAuthorization(call: call, result: result)
            } catch {
                result(FlutterError(code: "REQUEST_AUTH_ERROR",
                                    message: "Error requesting authorization: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "getData":
            healthDataReader.getData(call: call, result: result)
            
        case "getIntervalData":
            healthDataReader.getIntervalData(call: call, result: result)
            
        case "getTotalStepsInInterval":
            healthDataReader.getTotalStepsInInterval(call: call, result: result)
            
        case "writeData":
            do {
                try healthDataWriter.writeData(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing data: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeAudiogram":
            do {
                try healthDataWriter.writeAudiogram(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing audiogram: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeBloodPressure":
            do {
                try healthDataWriter.writeBloodPressure(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing blood pressure: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeMeal":
            do {
                try healthDataWriter.writeMeal(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing meal: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeInsulinDelivery":
            do {
                try healthDataWriter.writeInsulinDelivery(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing insulin delivery: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeWorkoutData":
            do {
                try healthDataWriter.writeWorkoutData(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing workout: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "writeMenstruationFlow":
            do {
                try healthDataWriter.writeMenstruationFlow(call: call, result: result)
            } catch {
                result(FlutterError(code: "WRITE_ERROR",
                                    message: "Error writing menstruation flow: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "hasPermissions":
            do {
                try healthDataOperations.hasPermissions(call: call, result: result)
            } catch {
                result(FlutterError(code: "PERMISSION_ERROR",
                                    message: "Error checking permissions: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "delete":
            do {
                healthDataOperations.delete(call: call, result: result)
            } catch {
                result(FlutterError(code: "DELETE_ERROR",
                                    message: "Error deleting data: \(error.localizedDescription)",
                                    details: nil))
            }
            
        case "deleteByUUID":
            do {
                try healthDataOperations.deleteByUUID(call: call, result: result)
            } catch {
                result(FlutterError(code: "DELETE_ERROR",
                                    message: "Error deleting data by UUID: \(error.localizedDescription)",
                                    details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Initialize all the health data types, unit dictionaries, and other required data structures
    func initializeTypes() {
        // init units
        unitDict[HealthConstants.GRAM] = HKUnit.gram()
        unitDict[HealthConstants.KILOGRAM] = HKUnit.gramUnit(with: .kilo)
        unitDict[HealthConstants.OUNCE] = HKUnit.ounce()
        unitDict[HealthConstants.POUND] = HKUnit.pound()
        unitDict[HealthConstants.STONE] = HKUnit.stone()
        unitDict[HealthConstants.METER] = HKUnit.meter()
        unitDict[HealthConstants.INCH] = HKUnit.inch()
        unitDict[HealthConstants.FOOT] = HKUnit.foot()
        unitDict[HealthConstants.YARD] = HKUnit.yard()
        unitDict[HealthConstants.MILE] = HKUnit.mile()
        unitDict[HealthConstants.LITER] = HKUnit.liter()
        unitDict[HealthConstants.MILLILITER] = HKUnit.literUnit(with: .milli)
        unitDict[HealthConstants.FLUID_OUNCE_US] = HKUnit.fluidOunceUS()
        unitDict[HealthConstants.FLUID_OUNCE_IMPERIAL] = HKUnit.fluidOunceImperial()
        unitDict[HealthConstants.CUP_US] = HKUnit.cupUS()
        unitDict[HealthConstants.CUP_IMPERIAL] = HKUnit.cupImperial()
        unitDict[HealthConstants.PINT_US] = HKUnit.pintUS()
        unitDict[HealthConstants.PINT_IMPERIAL] = HKUnit.pintImperial()
        unitDict[HealthConstants.PASCAL] = HKUnit.pascal()
        unitDict[HealthConstants.MILLIMETER_OF_MERCURY] = HKUnit.millimeterOfMercury()
        unitDict[HealthConstants.CENTIMETER_OF_WATER] = HKUnit.centimeterOfWater()
        unitDict[HealthConstants.ATMOSPHERE] = HKUnit.atmosphere()
        unitDict[HealthConstants.DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL] = HKUnit.decibelAWeightedSoundPressureLevel()
        unitDict[HealthConstants.SECOND] = HKUnit.second()
        unitDict[HealthConstants.MILLISECOND] = HKUnit.secondUnit(with: .milli)
        unitDict[HealthConstants.MINUTE] = HKUnit.minute()
        unitDict[HealthConstants.HOUR] = HKUnit.hour()
        unitDict[HealthConstants.DAY] = HKUnit.day()
        unitDict[HealthConstants.JOULE] = HKUnit.joule()
        unitDict[HealthConstants.KILOCALORIE] = HKUnit.kilocalorie()
        unitDict[HealthConstants.LARGE_CALORIE] = HKUnit.largeCalorie()
        unitDict[HealthConstants.SMALL_CALORIE] = HKUnit.smallCalorie()
        unitDict[HealthConstants.DEGREE_CELSIUS] = HKUnit.degreeCelsius()
        unitDict[HealthConstants.DEGREE_FAHRENHEIT] = HKUnit.degreeFahrenheit()
        unitDict[HealthConstants.KELVIN] = HKUnit.kelvin()
        unitDict[HealthConstants.DECIBEL_HEARING_LEVEL] = HKUnit.decibelHearingLevel()
        unitDict[HealthConstants.HERTZ] = HKUnit.hertz()
        unitDict[HealthConstants.SIEMEN] = HKUnit.siemen()
        unitDict[HealthConstants.INTERNATIONAL_UNIT] = HKUnit.internationalUnit()
        unitDict[HealthConstants.COUNT] = HKUnit.count()
        unitDict[HealthConstants.PERCENT] = HKUnit.percent()
        unitDict[HealthConstants.BEATS_PER_MINUTE] = HKUnit.init(from: "count/min")
        unitDict[HealthConstants.RESPIRATIONS_PER_MINUTE] = HKUnit.init(from: "count/min")
        unitDict[HealthConstants.MILLIGRAM_PER_DECILITER] = HKUnit.init(from: "mg/dL")
        unitDict[HealthConstants.UNKNOWN_UNIT] = HKUnit.init(from: "")
        unitDict[HealthConstants.NO_UNIT] = HKUnit.init(from: "")
        
        // init workout activity types
        initializeWorkoutTypes()
        
        nutritionList = [
            HealthConstants.DIETARY_ENERGY_CONSUMED,
            HealthConstants.DIETARY_CARBS_CONSUMED,
            HealthConstants.DIETARY_PROTEIN_CONSUMED,
            HealthConstants.DIETARY_FATS_CONSUMED,
            HealthConstants.DIETARY_CAFFEINE,
            HealthConstants.DIETARY_FIBER,
            HealthConstants.DIETARY_SUGAR,
            HealthConstants.DIETARY_FAT_MONOUNSATURATED,
            HealthConstants.DIETARY_FAT_POLYUNSATURATED,
            HealthConstants.DIETARY_FAT_SATURATED,
            HealthConstants.DIETARY_CHOLESTEROL,
            HealthConstants.DIETARY_VITAMIN_A,
            HealthConstants.DIETARY_THIAMIN,
            HealthConstants.DIETARY_RIBOFLAVIN,
            HealthConstants.DIETARY_NIACIN,
            HealthConstants.DIETARY_PANTOTHENIC_ACID,
            HealthConstants.DIETARY_VITAMIN_B6,
            HealthConstants.DIETARY_BIOTIN,
            HealthConstants.DIETARY_VITAMIN_B12,
            HealthConstants.DIETARY_VITAMIN_C,
            HealthConstants.DIETARY_VITAMIN_D,
            HealthConstants.DIETARY_VITAMIN_E,
            HealthConstants.DIETARY_VITAMIN_K,
            HealthConstants.DIETARY_FOLATE,
            HealthConstants.DIETARY_CALCIUM,
            HealthConstants.DIETARY_CHLORIDE,
            HealthConstants.DIETARY_IRON,
            HealthConstants.DIETARY_MAGNESIUM,
            HealthConstants.DIETARY_PHOSPHORUS,
            HealthConstants.DIETARY_POTASSIUM,
            HealthConstants.DIETARY_SODIUM,
            HealthConstants.DIETARY_ZINC,
            HealthConstants.DIETARY_WATER,
            HealthConstants.DIETARY_CHROMIUM,
            HealthConstants.DIETARY_COPPER,
            HealthConstants.DIETARY_IODINE,
            HealthConstants.DIETARY_MANGANESE,
            HealthConstants.DIETARY_MOLYBDENUM,
            HealthConstants.DIETARY_SELENIUM,
        ]
        
        // Set up iOS 11 specific types (ordinary health data quantity types)
        if #available(iOS 11.0, *) {
            initializeIOS11Types()
            healthDataQuantityTypes = Array(dataQuantityTypesDict.values)
        }
        
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *) {
            initializeIOS12Types()
        }
        
        // Set up iOS 13 specific types (ordinary health data types)
        if #available(iOS 13.0, *) {
            initializeIOS13Types()
            healthDataTypes = Array(dataTypesDict.values)
            characteristicsDataTypes = Array(characteristicsTypesDict.values)
        }
        
        if #available(iOS 13.6, *) {
            initializeIOS13_6Types()
        }
        
        if #available(iOS 14.0, *) {
            initializeIOS14Types()
        }
        
        if #available(iOS 16.0, *) {
            initializeIOS16Types()
        }
        
        // Concatenate heart events, headache and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
        allDataTypes = allDataTypes.union(headacheType)
    }
    
    /// Initialize iOS 11 specific data types
    @available(iOS 11.0, *)
    private func initializeIOS11Types() {
        dataTypesDict[HealthConstants.APPLE_STAND_HOUR] = HKSampleType.categoryType(forIdentifier: .appleStandHour)!
        
        dataQuantityTypesDict[HealthConstants.ACTIVE_ENERGY_BURNED] = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        dataQuantityTypesDict[HealthConstants.BASAL_ENERGY_BURNED] = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
        dataQuantityTypesDict[HealthConstants.BLOOD_GLUCOSE] = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        dataQuantityTypesDict[HealthConstants.BLOOD_OXYGEN] = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        dataQuantityTypesDict[HealthConstants.BLOOD_PRESSURE_DIASTOLIC] = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        dataQuantityTypesDict[HealthConstants.BLOOD_PRESSURE_SYSTOLIC] = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        dataQuantityTypesDict[HealthConstants.BODY_FAT_PERCENTAGE] = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
        dataQuantityTypesDict[HealthConstants.LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
        dataQuantityTypesDict[HealthConstants.BODY_MASS_INDEX] = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
        dataQuantityTypesDict[HealthConstants.BODY_TEMPERATURE] = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
        
        // Initialize nutrition quantity types
        initializeNutritionQuantityTypes()
        
        dataQuantityTypesDict[HealthConstants.ELECTRODERMAL_ACTIVITY] = HKQuantityType.quantityType(forIdentifier: .electrodermalActivity)!
        dataQuantityTypesDict[HealthConstants.FORCED_EXPIRATORY_VOLUME] = HKQuantityType.quantityType(forIdentifier: .forcedExpiratoryVolume1)!
        dataQuantityTypesDict[HealthConstants.HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        dataQuantityTypesDict[HealthConstants.HEART_RATE_VARIABILITY_SDNN] = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        dataQuantityTypesDict[HealthConstants.HEIGHT] = HKQuantityType.quantityType(forIdentifier: .height)!
        dataQuantityTypesDict[HealthConstants.RESTING_HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        dataQuantityTypesDict[HealthConstants.STEPS] = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        dataQuantityTypesDict[HealthConstants.WAIST_CIRCUMFERENCE] = HKQuantityType.quantityType(forIdentifier: .waistCircumference)!
        dataQuantityTypesDict[HealthConstants.WALKING_HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        dataQuantityTypesDict[HealthConstants.WEIGHT] = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        dataQuantityTypesDict[HealthConstants.DISTANCE_WALKING_RUNNING] = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        dataQuantityTypesDict[HealthConstants.DISTANCE_SWIMMING] = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
        dataQuantityTypesDict[HealthConstants.DISTANCE_CYCLING] = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        dataQuantityTypesDict[HealthConstants.FLIGHTS_CLIMBED] = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
    }
    
    /// Initialize nutrition quantity types
    @available(iOS 11.0, *)
    private func initializeNutritionQuantityTypes() {
        dataQuantityTypesDict[HealthConstants.DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
        dataQuantityTypesDict[HealthConstants.DIETARY_CAFFEINE] = HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
        dataQuantityTypesDict[HealthConstants.DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
        dataQuantityTypesDict[HealthConstants.DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
        dataQuantityTypesDict[HealthConstants.DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FAT_MONOUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FAT_POLYUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
        dataQuantityTypesDict[HealthConstants.DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
        dataQuantityTypesDict[HealthConstants.DIETARY_THIAMIN] = HKSampleType.quantityType(forIdentifier: .dietaryThiamin)!
        dataQuantityTypesDict[HealthConstants.DIETARY_RIBOFLAVIN] = HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)!
        dataQuantityTypesDict[HealthConstants.DIETARY_NIACIN] = HKSampleType.quantityType(forIdentifier: .dietaryNiacin)!
        dataQuantityTypesDict[HealthConstants.DIETARY_PANTOTHENIC_ACID] = HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_B6] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)!
        dataQuantityTypesDict[HealthConstants.DIETARY_BIOTIN] = HKSampleType.quantityType(forIdentifier: .dietaryBiotin)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_B12] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_E] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)!
        dataQuantityTypesDict[HealthConstants.DIETARY_VITAMIN_K] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)!
        dataQuantityTypesDict[HealthConstants.DIETARY_FOLATE] = HKSampleType.quantityType(forIdentifier: .dietaryFolate)!
        dataQuantityTypesDict[HealthConstants.DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
        dataQuantityTypesDict[HealthConstants.DIETARY_CHLORIDE] = HKSampleType.quantityType(forIdentifier: .dietaryChloride)!
        dataQuantityTypesDict[HealthConstants.DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
        dataQuantityTypesDict[HealthConstants.DIETARY_MAGNESIUM] = HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)!
        dataQuantityTypesDict[HealthConstants.DIETARY_PHOSPHORUS] = HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)!
        dataQuantityTypesDict[HealthConstants.DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
        dataQuantityTypesDict[HealthConstants.DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
        dataQuantityTypesDict[HealthConstants.DIETARY_ZINC] = HKSampleType.quantityType(forIdentifier: .dietaryZinc)!
        dataQuantityTypesDict[HealthConstants.DIETARY_WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
        dataQuantityTypesDict[HealthConstants.DIETARY_CHROMIUM] = HKSampleType.quantityType(forIdentifier: .dietaryChromium)!
        dataQuantityTypesDict[HealthConstants.DIETARY_COPPER] = HKSampleType.quantityType(forIdentifier: .dietaryCopper)!
        dataQuantityTypesDict[HealthConstants.DIETARY_IODINE] = HKSampleType.quantityType(forIdentifier: .dietaryIodine)!
        dataQuantityTypesDict[HealthConstants.DIETARY_MANGANESE] = HKSampleType.quantityType(forIdentifier: .dietaryManganese)!
        dataQuantityTypesDict[HealthConstants.DIETARY_MOLYBDENUM] = HKSampleType.quantityType(forIdentifier: .dietaryMolybdenum)!
        dataQuantityTypesDict[HealthConstants.DIETARY_SELENIUM] = HKSampleType.quantityType(forIdentifier: .dietarySelenium)!
    }
    
    /// Initialize iOS 13 specific data types
    @available(iOS 13.0, *)
    private func initializeIOS13Types() {
        dataTypesDict[HealthConstants.ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
        dataTypesDict[HealthConstants.APPLE_STAND_TIME] = HKSampleType.quantityType(forIdentifier: .appleStandTime)!
        dataTypesDict[HealthConstants.AUDIOGRAM] = HKSampleType.audiogramSampleType()
        dataTypesDict[HealthConstants.BASAL_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!
        dataTypesDict[HealthConstants.BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
        dataTypesDict[HealthConstants.BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
        dataTypesDict[HealthConstants.RESPIRATORY_RATE] = HKSampleType.quantityType(forIdentifier: .respiratoryRate)!
        dataTypesDict[HealthConstants.PERIPHERAL_PERFUSION_INDEX] = HKSampleType.quantityType(forIdentifier: .peripheralPerfusionIndex)!
        
        dataTypesDict[HealthConstants.BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        dataTypesDict[HealthConstants.BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!
        dataTypesDict[HealthConstants.BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!
        dataTypesDict[HealthConstants.LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
        dataTypesDict[HealthConstants.BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
        dataTypesDict[HealthConstants.BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
        
        // Initialize nutrition types
        initializeNutritionTypes()
        
        dataTypesDict[HealthConstants.ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(forIdentifier: .electrodermalActivity)!
        dataTypesDict[HealthConstants.FORCED_EXPIRATORY_VOLUME] = HKSampleType.quantityType(forIdentifier: .forcedExpiratoryVolume1)!
        dataTypesDict[HealthConstants.HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
        dataTypesDict[HealthConstants.HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        dataTypesDict[HealthConstants.HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
        dataTypesDict[HealthConstants.INSULIN_DELIVERY] = HKSampleType.quantityType(forIdentifier: .insulinDelivery)!
        dataTypesDict[HealthConstants.RESTING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .restingHeartRate)!
        dataTypesDict[HealthConstants.STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
        dataTypesDict[HealthConstants.WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(forIdentifier: .waistCircumference)!
        dataTypesDict[HealthConstants.WALKING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        dataTypesDict[HealthConstants.WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        dataTypesDict[HealthConstants.DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
        dataTypesDict[HealthConstants.DISTANCE_SWIMMING] = HKSampleType.quantityType(forIdentifier: .distanceSwimming)!
        dataTypesDict[HealthConstants.DISTANCE_CYCLING] = HKSampleType.quantityType(forIdentifier: .distanceCycling)!
        dataTypesDict[HealthConstants.FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
        dataTypesDict[HealthConstants.MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
        dataTypesDict[HealthConstants.SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.SLEEP_DEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.SLEEP_LIGHT] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.SLEEP_REM] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        dataTypesDict[HealthConstants.MENSTRUATION_FLOW] = HKSampleType.categoryType(forIdentifier: .menstrualFlow)!
        
        dataTypesDict[HealthConstants.EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
        dataTypesDict[HealthConstants.WORKOUT] = HKSampleType.workoutType()
        dataTypesDict[HealthConstants.NUTRITION] = HKSampleType.correlationType(forIdentifier: .food)!
        
        characteristicsTypesDict[HealthConstants.BIRTH_DATE] = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        characteristicsTypesDict[HealthConstants.GENDER] = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        characteristicsTypesDict[HealthConstants.BLOOD_TYPE] = HKObjectType.characteristicType(forIdentifier: .bloodType)!
    }
    
    /// Initialize nutrition types for iOS 13+
    @available(iOS 13.0, *)
    private func initializeNutritionTypes() {
        dataTypesDict[HealthConstants.DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
        dataTypesDict[HealthConstants.DIETARY_CAFFEINE] = HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
        dataTypesDict[HealthConstants.DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        dataTypesDict[HealthConstants.DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
        dataTypesDict[HealthConstants.DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
        dataTypesDict[HealthConstants.DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
        dataTypesDict[HealthConstants.DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
        dataTypesDict[HealthConstants.DIETARY_FAT_MONOUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)!
        dataTypesDict[HealthConstants.DIETARY_FAT_POLYUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)!
        dataTypesDict[HealthConstants.DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
        dataTypesDict[HealthConstants.DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
        dataTypesDict[HealthConstants.DIETARY_THIAMIN] = HKSampleType.quantityType(forIdentifier: .dietaryThiamin)!
        dataTypesDict[HealthConstants.DIETARY_RIBOFLAVIN] = HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)!
        dataTypesDict[HealthConstants.DIETARY_NIACIN] = HKSampleType.quantityType(forIdentifier: .dietaryNiacin)!
        dataTypesDict[HealthConstants.DIETARY_PANTOTHENIC_ACID] = HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_B6] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)!
        dataTypesDict[HealthConstants.DIETARY_BIOTIN] = HKSampleType.quantityType(forIdentifier: .dietaryBiotin)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_B12] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_E] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)!
        dataTypesDict[HealthConstants.DIETARY_VITAMIN_K] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)!
        dataTypesDict[HealthConstants.DIETARY_FOLATE] = HKSampleType.quantityType(forIdentifier: .dietaryFolate)!
        dataTypesDict[HealthConstants.DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
        dataTypesDict[HealthConstants.DIETARY_CHLORIDE] = HKSampleType.quantityType(forIdentifier: .dietaryChloride)!
        dataTypesDict[HealthConstants.DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
        dataTypesDict[HealthConstants.DIETARY_MAGNESIUM] = HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)!
        dataTypesDict[HealthConstants.DIETARY_PHOSPHORUS] = HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)!
        dataTypesDict[HealthConstants.DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
        dataTypesDict[HealthConstants.DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
        dataTypesDict[HealthConstants.DIETARY_ZINC] = HKSampleType.quantityType(forIdentifier: .dietaryZinc)!
        dataTypesDict[HealthConstants.DIETARY_WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
        dataTypesDict[HealthConstants.DIETARY_CHROMIUM] = HKSampleType.quantityType(forIdentifier: .dietaryChromium)!
        dataTypesDict[HealthConstants.DIETARY_COPPER] = HKSampleType.quantityType(forIdentifier: .dietaryCopper)!
        dataTypesDict[HealthConstants.DIETARY_IODINE] = HKSampleType.quantityType(forIdentifier: .dietaryIodine)!
        dataTypesDict[HealthConstants.DIETARY_MANGANESE] = HKSampleType.quantityType(forIdentifier: .dietaryManganese)!
        dataTypesDict[HealthConstants.DIETARY_MOLYBDENUM] = HKSampleType.quantityType(forIdentifier: .dietaryMolybdenum)!
        dataTypesDict[HealthConstants.DIETARY_SELENIUM] = HKSampleType.quantityType(forIdentifier: .dietarySelenium)!
    }
    
    /// Initialize iOS 12 specific data types
    @available(iOS 12.2, *)
    private func initializeIOS12Types() {
        dataTypesDict[HealthConstants.HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!
        dataTypesDict[HealthConstants.LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!
        dataTypesDict[HealthConstants.IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!
        
        heartRateEventTypes = Set([
            HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
            HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
            HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
        ])
    }
    
    /// Initialize iOS 13.6 specific data types
    @available(iOS 13.6, *)
    private func initializeIOS13_6Types() {
        dataTypesDict[HealthConstants.HEADACHE_UNSPECIFIED] = HKSampleType.categoryType(forIdentifier: .headache)!
        dataTypesDict[HealthConstants.HEADACHE_NOT_PRESENT] = HKSampleType.categoryType(forIdentifier: .headache)!
        dataTypesDict[HealthConstants.HEADACHE_MILD] = HKSampleType.categoryType(forIdentifier: .headache)!
        dataTypesDict[HealthConstants.HEADACHE_MODERATE] = HKSampleType.categoryType(forIdentifier: .headache)!
        dataTypesDict[HealthConstants.HEADACHE_SEVERE] = HKSampleType.categoryType(forIdentifier: .headache)!
        
        headacheType = Set([
            HKSampleType.categoryType(forIdentifier: .headache)!
        ])
    }
    
    /// Initialize iOS 14 specific data types
    @available(iOS 14.0, *)
    private func initializeIOS14Types() {
        dataTypesDict[HealthConstants.ELECTROCARDIOGRAM] = HKSampleType.electrocardiogramType()
        dataTypesDict[HealthConstants.WALKING_SPEED] = HKSampleType.quantityType(forIdentifier: .walkingSpeed)
        
        unitDict[HealthConstants.VOLT] = HKUnit.volt()
        unitDict[HealthConstants.INCHES_OF_MERCURY] = HKUnit.inchesOfMercury()
        
        workoutActivityTypeMap["CARDIO_DANCE"] = HKWorkoutActivityType.cardioDance
        workoutActivityTypeMap["SOCIAL_DANCE"] = HKWorkoutActivityType.socialDance
        workoutActivityTypeMap["PICKLEBALL"] = HKWorkoutActivityType.pickleball
        workoutActivityTypeMap["COOLDOWN"] = HKWorkoutActivityType.cooldown
        
        if #available(iOS 14.5, *) {
            dataTypesDict[HealthConstants.APPLE_MOVE_TIME] = HKSampleType.quantityType(forIdentifier: .appleMoveTime)!
        }
    }
    
    /// Initialize iOS 16 specific data types
    @available(iOS 16.0, *)
    private func initializeIOS16Types() {
        dataTypesDict[HealthConstants.ATRIAL_FIBRILLATION_BURDEN] = HKQuantityType.quantityType(forIdentifier: .atrialFibrillationBurden)!
        dataTypesDict[HealthConstants.WATER_TEMPERATURE] = HKQuantityType.quantityType(forIdentifier: .waterTemperature)!
        dataTypesDict[HealthConstants.UNDERWATER_DEPTH] = HKQuantityType.quantityType(forIdentifier: .underwaterDepth)!
        dataTypesDict[HealthConstants.UV_INDEX] = HKSampleType.quantityType(forIdentifier: .uvExposure)!
        
        dataQuantityTypesDict[HealthConstants.UV_INDEX] = HKQuantityType.quantityType(forIdentifier: .uvExposure)!
    }
    
    /// Initialize workout activity types
    private func initializeWorkoutTypes() {
        workoutActivityTypeMap["ARCHERY"] = .archery
        workoutActivityTypeMap["BOWLING"] = .bowling
        workoutActivityTypeMap["FENCING"] = .fencing
        workoutActivityTypeMap["GYMNASTICS"] = .gymnastics
        workoutActivityTypeMap["TRACK_AND_FIELD"] = .trackAndField
        workoutActivityTypeMap["AMERICAN_FOOTBALL"] = .americanFootball
        workoutActivityTypeMap["AUSTRALIAN_FOOTBALL"] = .australianFootball
        workoutActivityTypeMap["BASEBALL"] = .baseball
        workoutActivityTypeMap["BASKETBALL"] = .basketball
        workoutActivityTypeMap["CRICKET"] = .cricket
        workoutActivityTypeMap["DISC_SPORTS"] = .discSports
        workoutActivityTypeMap["HANDBALL"] = .handball
        workoutActivityTypeMap["HOCKEY"] = .hockey
        workoutActivityTypeMap["LACROSSE"] = .lacrosse
        workoutActivityTypeMap["RUGBY"] = .rugby
        workoutActivityTypeMap["SOCCER"] = .soccer
        workoutActivityTypeMap["SOFTBALL"] = .softball
        workoutActivityTypeMap["VOLLEYBALL"] = .volleyball
        workoutActivityTypeMap["PREPARATION_AND_RECOVERY"] = .preparationAndRecovery
        workoutActivityTypeMap["FLEXIBILITY"] = .flexibility
        workoutActivityTypeMap["WALKING"] = .walking
        workoutActivityTypeMap["RUNNING"] = .running
        workoutActivityTypeMap["RUNNING_TREADMILL"] = .running  // Supported due to combining with Android naming
        workoutActivityTypeMap["WHEELCHAIR_WALK_PACE"] = .wheelchairWalkPace
        workoutActivityTypeMap["WHEELCHAIR_RUN_PACE"] = .wheelchairRunPace
        workoutActivityTypeMap["BIKING"] = .cycling
        workoutActivityTypeMap["HAND_CYCLING"] = .handCycling
        workoutActivityTypeMap["CORE_TRAINING"] = .coreTraining
        workoutActivityTypeMap["ELLIPTICAL"] = .elliptical
        workoutActivityTypeMap["FUNCTIONAL_STRENGTH_TRAINING"] = .functionalStrengthTraining
        workoutActivityTypeMap["TRADITIONAL_STRENGTH_TRAINING"] = .traditionalStrengthTraining
        workoutActivityTypeMap["CROSS_TRAINING"] = .crossTraining
        workoutActivityTypeMap["MIXED_CARDIO"] = .mixedCardio
        workoutActivityTypeMap["HIGH_INTENSITY_INTERVAL_TRAINING"] = .highIntensityIntervalTraining
        workoutActivityTypeMap["JUMP_ROPE"] = .jumpRope
        workoutActivityTypeMap["STAIR_CLIMBING"] = .stairClimbing
        workoutActivityTypeMap["STAIRS"] = .stairs
        workoutActivityTypeMap["STEP_TRAINING"] = .stepTraining
        workoutActivityTypeMap["FITNESS_GAMING"] = .fitnessGaming
        workoutActivityTypeMap["BARRE"] = .barre
        workoutActivityTypeMap["YOGA"] = .yoga
        workoutActivityTypeMap["MIND_AND_BODY"] = .mindAndBody
        workoutActivityTypeMap["PILATES"] = .pilates
        workoutActivityTypeMap["BADMINTON"] = .badminton
        workoutActivityTypeMap["RACQUETBALL"] = .racquetball
        workoutActivityTypeMap["SQUASH"] = .squash
        workoutActivityTypeMap["TABLE_TENNIS"] = .tableTennis
        workoutActivityTypeMap["TENNIS"] = .tennis
        workoutActivityTypeMap["CLIMBING"] = .climbing
        workoutActivityTypeMap["ROCK_CLIMBING"] = .climbing  // Supported due to combining with Android naming
        workoutActivityTypeMap["EQUESTRIAN_SPORTS"] = .equestrianSports
        workoutActivityTypeMap["FISHING"] = .fishing
        workoutActivityTypeMap["GOLF"] = .golf
        workoutActivityTypeMap["HIKING"] = .hiking
        workoutActivityTypeMap["HUNTING"] = .hunting
        workoutActivityTypeMap["PLAY"] = .play
        workoutActivityTypeMap["CROSS_COUNTRY_SKIING"] = .crossCountrySkiing
        workoutActivityTypeMap["CURLING"] = .curling
        workoutActivityTypeMap["DOWNHILL_SKIING"] = .downhillSkiing
        workoutActivityTypeMap["SNOW_SPORTS"] = .snowSports
        workoutActivityTypeMap["SNOWBOARDING"] = .snowboarding
        workoutActivityTypeMap["SKATING"] = .skatingSports
        workoutActivityTypeMap["PADDLE_SPORTS"] = .paddleSports
        workoutActivityTypeMap["ROWING"] = .rowing
        workoutActivityTypeMap["SAILING"] = .sailing
        workoutActivityTypeMap["SURFING"] = .surfingSports
        workoutActivityTypeMap["SWIMMING"] = .swimming
        workoutActivityTypeMap["SWIMMING_OPEN_WATER"] = .swimming
        workoutActivityTypeMap["SWIMMING_POOL"] = .swimming
        workoutActivityTypeMap["WATER_FITNESS"] = .waterFitness
        workoutActivityTypeMap["WATER_POLO"] = .waterPolo
        workoutActivityTypeMap["WATER_SPORTS"] = .waterSports
        workoutActivityTypeMap["BOXING"] = .boxing
        workoutActivityTypeMap["KICKBOXING"] = .kickboxing
        workoutActivityTypeMap["MARTIAL_ARTS"] = .martialArts
        workoutActivityTypeMap["TAI_CHI"] = .taiChi
        workoutActivityTypeMap["WRESTLING"] = .wrestling
        workoutActivityTypeMap["OTHER"] = .other
        if #available(iOS 17.0, *) {
            workoutActivityTypeMap["UNDERWATER_DIVING"] = .underwaterDiving
        }

        nutritionList = [
            DIETARY_ENERGY_CONSUMED, DIETARY_CARBS_CONSUMED, DIETARY_PROTEIN_CONSUMED,
            DIETARY_FATS_CONSUMED, DIETARY_CAFFEINE, DIETARY_FIBER, DIETARY_SUGAR,
            DIETARY_FAT_MONOUNSATURATED, DIETARY_FAT_POLYUNSATURATED, DIETARY_FAT_SATURATED,
            DIETARY_CHOLESTEROL, DIETARY_VITAMIN_A, DIETARY_THIAMIN, DIETARY_RIBOFLAVIN,
            DIETARY_NIACIN, DIETARY_PANTOTHENIC_ACID, DIETARY_VITAMIN_B6, DIETARY_BIOTIN,
            DIETARY_VITAMIN_B12, DIETARY_VITAMIN_C, DIETARY_VITAMIN_D, DIETARY_VITAMIN_E,
            DIETARY_VITAMIN_K, DIETARY_FOLATE, DIETARY_CALCIUM, DIETARY_CHLORIDE,
            DIETARY_IRON, DIETARY_MAGNESIUM, DIETARY_PHOSPHORUS, DIETARY_POTASSIUM,
            DIETARY_SODIUM, DIETARY_ZINC, DIETARY_WATER, DIETARY_CHROMIUM, DIETARY_COPPER,
            DIETARY_IODINE, DIETARY_MANGANESE, DIETARY_MOLYBDENUM, DIETARY_SELENIUM,
        ]
        // Set up iOS 13 specific types (ordinary health data types)
        if #available(iOS 13.0, *) {
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(
                forIdentifier: .activeEnergyBurned)!
            dataTypesDict[AUDIOGRAM] = HKSampleType.audiogramSampleType()
            dataTypesDict[BASAL_ENERGY_BURNED] = HKSampleType.quantityType(
                forIdentifier: .basalEnergyBurned)!
            dataTypesDict[BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
            dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
            dataTypesDict[RESPIRATORY_RATE] = HKSampleType.quantityType(forIdentifier: .respiratoryRate)!
            dataTypesDict[PERIPHERAL_PERFUSION_INDEX] = HKSampleType.quantityType(
                forIdentifier: .peripheralPerfusionIndex)!
            
            dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(
                forIdentifier: .bloodPressureDiastolic)!
            dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(
                forIdentifier: .bloodPressureSystolic)!
            dataTypesDict[BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(
                forIdentifier: .bodyFatPercentage)!
            dataTypesDict[LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
            dataTypesDict[BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
            dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
            
            // Nutrition
            dataTypesDict[DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            dataTypesDict[DIETARY_CAFFEINE] = HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
            dataTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            dataTypesDict[DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
            dataTypesDict[DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
            dataTypesDict[DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
            dataTypesDict[DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
            dataTypesDict[DIETARY_FAT_MONOUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)!
            dataTypesDict[DIETARY_FAT_POLYUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)!
            dataTypesDict[DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
            dataTypesDict[DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
            dataTypesDict[DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
            dataTypesDict[DIETARY_THIAMIN] = HKSampleType.quantityType(forIdentifier: .dietaryThiamin)!
            dataTypesDict[DIETARY_RIBOFLAVIN] = HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)!
            dataTypesDict[DIETARY_NIACIN] = HKSampleType.quantityType(forIdentifier: .dietaryNiacin)!
            dataTypesDict[DIETARY_PANTOTHENIC_ACID] = HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)!
            dataTypesDict[DIETARY_VITAMIN_B6] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)!
            dataTypesDict[DIETARY_BIOTIN] = HKSampleType.quantityType(forIdentifier: .dietaryBiotin)!
            dataTypesDict[DIETARY_VITAMIN_B12] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)!
            dataTypesDict[DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
            dataTypesDict[DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
            dataTypesDict[DIETARY_VITAMIN_E] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)!
            dataTypesDict[DIETARY_VITAMIN_K] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)!
            dataTypesDict[DIETARY_FOLATE] = HKSampleType.quantityType(forIdentifier: .dietaryFolate)!
            dataTypesDict[DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
            dataTypesDict[DIETARY_CHLORIDE] = HKSampleType.quantityType(forIdentifier: .dietaryChloride)!
            dataTypesDict[DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
            dataTypesDict[DIETARY_MAGNESIUM] = HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)!
            dataTypesDict[DIETARY_PHOSPHORUS] = HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)!
            dataTypesDict[DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
            dataTypesDict[DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
            dataTypesDict[DIETARY_ZINC] = HKSampleType.quantityType(forIdentifier: .dietaryZinc)!
            dataTypesDict[DIETARY_WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataTypesDict[DIETARY_CHROMIUM] = HKSampleType.quantityType(forIdentifier: .dietaryChromium)!
            dataTypesDict[DIETARY_COPPER] = HKSampleType.quantityType(forIdentifier: .dietaryCopper)!
            dataTypesDict[DIETARY_IODINE] = HKSampleType.quantityType(forIdentifier: .dietaryIodine)!
            dataTypesDict[DIETARY_MANGANESE] = HKSampleType.quantityType(forIdentifier: .dietaryManganese)!
            dataTypesDict[DIETARY_MOLYBDENUM] = HKSampleType.quantityType(forIdentifier: .dietaryMolybdenum)!
            dataTypesDict[DIETARY_SELENIUM] = HKSampleType.quantityType(forIdentifier: .dietarySelenium)!
            
            dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(
                forIdentifier: .electrodermalActivity)!
            dataTypesDict[FORCED_EXPIRATORY_VOLUME] = HKSampleType.quantityType(
                forIdentifier: .forcedExpiratoryVolume1)!
            dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
            dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(
                forIdentifier: .heartRateVariabilitySDNN)!
            dataTypesDict[HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
            dataTypesDict[INSULIN_DELIVERY] = HKSampleType.quantityType(forIdentifier: .insulinDelivery)!
            dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(
                forIdentifier: .restingHeartRate)!
            dataTypesDict[STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
            dataTypesDict[WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(
                forIdentifier: .waistCircumference)!
            dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(
                forIdentifier: .walkingHeartRateAverage)!
            dataTypesDict[WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(
                forIdentifier: .distanceWalkingRunning)!
            dataTypesDict[DISTANCE_SWIMMING] = HKSampleType.quantityType(forIdentifier: .distanceSwimming)!
            dataTypesDict[DISTANCE_CYCLING] = HKSampleType.quantityType(forIdentifier: .distanceCycling)!
            dataTypesDict[FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
            dataTypesDict[MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
            dataTypesDict[SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_DEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_LIGHT] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_REM] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[MENSTRUATION_FLOW] = HKSampleType.categoryType(forIdentifier: .menstrualFlow)!
            
            
            dataTypesDict[EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
            dataTypesDict[WORKOUT] = HKSampleType.workoutType()
            dataTypesDict[NUTRITION] = HKSampleType.correlationType(
                forIdentifier: .food)!
            
            healthDataTypes = Array(dataTypesDict.values)
            
            characteristicsTypesDict[BIRTH_DATE] = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
            characteristicsTypesDict[GENDER] = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
            characteristicsTypesDict[BLOOD_TYPE] = HKObjectType.characteristicType(forIdentifier: .bloodType)!
            characteristicsDataTypes = Array(characteristicsTypesDict.values)
        }
        
        // Set up iOS 11 specific types (ordinary health data quantity types)
        if #available(iOS 11.0, *) {
            dataQuantityTypesDict[ACTIVE_ENERGY_BURNED] = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            dataQuantityTypesDict[BASAL_ENERGY_BURNED] = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
            dataQuantityTypesDict[BLOOD_GLUCOSE] = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
            dataQuantityTypesDict[BLOOD_OXYGEN] = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
            dataQuantityTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            dataQuantityTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
            dataQuantityTypesDict[BODY_FAT_PERCENTAGE] = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
            dataQuantityTypesDict[LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
            dataQuantityTypesDict[BODY_MASS_INDEX] = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
            dataQuantityTypesDict[BODY_TEMPERATURE] = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
            
            // Nutrition
            dataQuantityTypesDict[DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            dataQuantityTypesDict[DIETARY_CAFFEINE] = HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
            dataQuantityTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            dataQuantityTypesDict[DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
            dataQuantityTypesDict[DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
            dataQuantityTypesDict[DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
            dataQuantityTypesDict[DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
            dataQuantityTypesDict[DIETARY_FAT_MONOUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)!
            dataQuantityTypesDict[DIETARY_FAT_POLYUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)!
            dataQuantityTypesDict[DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
            dataQuantityTypesDict[DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
            dataQuantityTypesDict[DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
            dataQuantityTypesDict[DIETARY_THIAMIN] = HKSampleType.quantityType(forIdentifier: .dietaryThiamin)!
            dataQuantityTypesDict[DIETARY_RIBOFLAVIN] = HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)!
            dataQuantityTypesDict[DIETARY_NIACIN] = HKSampleType.quantityType(forIdentifier: .dietaryNiacin)!
            dataQuantityTypesDict[DIETARY_PANTOTHENIC_ACID] = HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)!
            dataQuantityTypesDict[DIETARY_VITAMIN_B6] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)!
            dataQuantityTypesDict[DIETARY_BIOTIN] = HKSampleType.quantityType(forIdentifier: .dietaryBiotin)!
            dataQuantityTypesDict[DIETARY_VITAMIN_B12] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)!
            dataQuantityTypesDict[DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
            dataQuantityTypesDict[DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
            dataQuantityTypesDict[DIETARY_VITAMIN_E] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)!
            dataQuantityTypesDict[DIETARY_VITAMIN_K] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)!
            dataQuantityTypesDict[DIETARY_FOLATE] = HKSampleType.quantityType(forIdentifier: .dietaryFolate)!
            dataQuantityTypesDict[DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
            dataQuantityTypesDict[DIETARY_CHLORIDE] = HKSampleType.quantityType(forIdentifier: .dietaryChloride)!
            dataQuantityTypesDict[DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
            dataQuantityTypesDict[DIETARY_MAGNESIUM] = HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)!
            dataQuantityTypesDict[DIETARY_PHOSPHORUS] = HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)!
            dataQuantityTypesDict[DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
            dataQuantityTypesDict[DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
            dataQuantityTypesDict[DIETARY_ZINC] = HKSampleType.quantityType(forIdentifier: .dietaryZinc)!
            dataQuantityTypesDict[DIETARY_WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataQuantityTypesDict[DIETARY_CHROMIUM] = HKSampleType.quantityType(forIdentifier: .dietaryChromium)!
            dataQuantityTypesDict[DIETARY_COPPER] = HKSampleType.quantityType(forIdentifier: .dietaryCopper)!
            dataQuantityTypesDict[DIETARY_IODINE] = HKSampleType.quantityType(forIdentifier: .dietaryIodine)!
            dataQuantityTypesDict[DIETARY_MANGANESE] = HKSampleType.quantityType(forIdentifier: .dietaryManganese)!
            dataQuantityTypesDict[DIETARY_MOLYBDENUM] = HKSampleType.quantityType(forIdentifier: .dietaryMolybdenum)!
            dataQuantityTypesDict[DIETARY_SELENIUM] = HKSampleType.quantityType(forIdentifier: .dietarySelenium)!
            
            dataQuantityTypesDict[ELECTRODERMAL_ACTIVITY] = HKQuantityType.quantityType(forIdentifier: .electrodermalActivity)!
            dataQuantityTypesDict[FORCED_EXPIRATORY_VOLUME] = HKQuantityType.quantityType(forIdentifier: .forcedExpiratoryVolume1)!
            dataQuantityTypesDict[HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            dataQuantityTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
            dataQuantityTypesDict[HEIGHT] = HKQuantityType.quantityType(forIdentifier: .height)!
            dataQuantityTypesDict[RESTING_HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
            dataQuantityTypesDict[STEPS] = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            dataQuantityTypesDict[WAIST_CIRCUMFERENCE] = HKQuantityType.quantityType(forIdentifier: .waistCircumference)!
            dataQuantityTypesDict[WALKING_HEART_RATE] = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            dataQuantityTypesDict[WEIGHT] = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
            dataQuantityTypesDict[DISTANCE_WALKING_RUNNING] = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            dataQuantityTypesDict[DISTANCE_SWIMMING] = HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
            dataQuantityTypesDict[DISTANCE_CYCLING] = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
            dataQuantityTypesDict[FLIGHTS_CLIMBED] = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
            
            healthDataQuantityTypes = Array(dataQuantityTypesDict.values)
        }
        
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *) {
            dataTypesDict[HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(
                forIdentifier: .highHeartRateEvent)!
            dataTypesDict[LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(
                forIdentifier: .lowHeartRateEvent)!
            dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(
                forIdentifier: .irregularHeartRhythmEvent)!
            
            heartRateEventTypes = Set([
                HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
            ])
        }
        
        if #available(iOS 13.6, *) {
            dataTypesDict[HEADACHE_UNSPECIFIED] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_NOT_PRESENT] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_MILD] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_MODERATE] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_SEVERE] = HKSampleType.categoryType(forIdentifier: .headache)!
            
            headacheType = Set([
                HKSampleType.categoryType(forIdentifier: .headache)!
            ])
        }
        
        if #available(iOS 14.0, *) {
            dataTypesDict[ELECTROCARDIOGRAM] = HKSampleType.electrocardiogramType()
            dataTypesDict[WALKING_SPEED] = HKSampleType.quantityType(forIdentifier: .walkingSpeed)
            
            unitDict[VOLT] = HKUnit.volt()
            unitDict[INCHES_OF_MERCURY] = HKUnit.inchesOfMercury()
            
            workoutActivityTypeMap["CARDIO_DANCE"] = HKWorkoutActivityType.cardioDance
            workoutActivityTypeMap["SOCIAL_DANCE"] = HKWorkoutActivityType.socialDance
            workoutActivityTypeMap["PICKLEBALL"] = HKWorkoutActivityType.pickleball
            workoutActivityTypeMap["COOLDOWN"] = HKWorkoutActivityType.cooldown
        }

        if #available(iOS 16.0, *) {
            dataTypesDict[ATRIAL_FIBRILLATION_BURDEN] = HKQuantityType.quantityType(forIdentifier: .atrialFibrillationBurden)!

            dataTypesDict[WATER_TEMPERATURE] = HKQuantityType.quantityType(forIdentifier: .waterTemperature)!
            dataTypesDict[UNDERWATER_DEPTH] = HKQuantityType.quantityType(forIdentifier: .underwaterDepth)!

            dataTypesDict[UV_INDEX] = HKSampleType.quantityType(forIdentifier: .uvExposure)!
            dataQuantityTypesDict[UV_INDEX] = HKQuantityType.quantityType(forIdentifier: .uvExposure)!

        } 
        
        // Concatenate heart events, headache and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
        allDataTypes = allDataTypes.union(headacheType)
    }
    
    func getWorkoutType(type: HKWorkoutActivityType) -> String {
        switch type {
        case .americanFootball:
            return "americanFootball"
        case .archery:
            return "archery"
        case .australianFootball:
            return "australianFootball"
        case .badminton:
            return "badminton"
        case .baseball:
            return "baseball"
        case .basketball:
            return "basketball"
        case .bowling:
            return "bowling"
        case .boxing:
            return "boxing"
        case .climbing:
            return "climbing"
        case .cricket:
            return "cricket"
        case .crossTraining:
            return "crossTraining"
        case .curling:
            return "curling"
        case .cycling:
            return "cycling"
        case .dance:
            return "dance"
        case .danceInspiredTraining:
            return "danceInspiredTraining"
        case .elliptical:
            return "elliptical"
        case .equestrianSports:
            return "equestrianSports"
        case .fencing:
            return "fencing"
        case .fishing:
            return "fishing"
        case .functionalStrengthTraining:
            return "functionalStrengthTraining"
        case .golf:
            return "golf"
        case .gymnastics:
            return "gymnastics"
        case .handball:
            return "handball"
        case .hiking:
            return "hiking"
        case .hockey:
            return "hockey"
        case .hunting:
            return "hunting"
        case .lacrosse:
            return "lacrosse"
        case .martialArts:
            return "martialArts"
        case .mindAndBody:
            return "mindAndBody"
        case .mixedMetabolicCardioTraining:
            return "mixedMetabolicCardioTraining"
        case .paddleSports:
            return "paddleSports"
        case .play:
            return "play"
        case .preparationAndRecovery:
            return "preparationAndRecovery"
        case .racquetball:
            return "racquetball"
        case .rowing:
            return "rowing"
        case .rugby:
            return "rugby"
        case .running:
            return "running"
        case .sailing:
            return "sailing"
        case .skatingSports:
            return "skatingSports"
        case .snowSports:
            return "snowSports"
        case .soccer:
            return "soccer"
        case .softball:
            return "softball"
        case .squash:
            return "squash"
        case .stairClimbing:
            return "stairClimbing"
        case .surfingSports:
            return "surfingSports"
        case .swimming:
            return "swimming"
        case .tableTennis:
            return "tableTennis"
        case .tennis:
            return "tennis"
        case .trackAndField:
            return "trackAndField"
        case .traditionalStrengthTraining:
            return "traditionalStrengthTraining"
        case .volleyball:
            return "volleyball"
        case .walking:
            return "walking"
        case .waterFitness:
            return "waterFitness"
        case .waterPolo:
            return "waterPolo"
        case .waterSports:
            return "waterSports"
        case .wrestling:
            return "wrestling"
        case .yoga:
            return "yoga"
        case .barre:
            return "barre"
        case .coreTraining:
            return "coreTraining"
        case .crossCountrySkiing:
            return "crossCountrySkiing"
        case .downhillSkiing:
            return "downhillSkiing"
        case .flexibility:
            return "flexibility"
        case .highIntensityIntervalTraining:
            return "highIntensityIntervalTraining"
        case .jumpRope:
            return "jumpRope"
        case .kickboxing:
            return "kickboxing"
        case .pilates:
            return "pilates"
        case .snowboarding:
            return "snowboarding"
        case .stairs:
            return "stairs"
        case .stepTraining:
            return "stepTraining"
        case .wheelchairWalkPace:
            return "wheelchairWalkPace"
        case .wheelchairRunPace:
            return "wheelchairRunPace"
        case .taiChi:
            return "taiChi"
        case .mixedCardio:
            return "mixedCardio"
        case .handCycling:
            return "handCycling"
        case .underwaterDiving:
            return "underwaterDiving"
        default:
            return "other"
        }
   }
}
