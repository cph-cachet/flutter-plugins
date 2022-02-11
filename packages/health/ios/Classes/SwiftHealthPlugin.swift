import Flutter
import UIKit
import HealthKit

public class SwiftHealthPlugin: NSObject, FlutterPlugin {

    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()
    var heartRateEventTypes = Set<HKSampleType>()
    var allDataTypes = Set<HKSampleType>()
    var dataTypesDict: [String: HKSampleType] = [:]
    var unitDict: [String: HKUnit] = [:]

    // Health Data Type Keys
    let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    let AUDIOGRAM = "AUDIOGRAM"
    let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
    let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    let BLOOD_OXYGEN = "BLOOD_OXYGEN"
    let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    let BODY_MASS_INDEX = "BODY_MASS_INDEX"
    let BODY_TEMPERATURE = "BODY_TEMPERATURE"
    let DIETARY_CARBS_CONSUMED = "DIETARY_CARBS_CONSUMED"
    let DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
    let DIETARY_FATS_CONSUMED = "DIETARY_FATS_CONSUMED"
    let DIETARY_PROTEIN_CONSUMED = "DIETARY_PROTEIN_CONSUMED"
    let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
    let FORCED_EXPIRATORY_VOLUME = "FORCED_EXPIRATORY_VOLUME"
    let HEART_RATE = "HEART_RATE"
    let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
    let HEIGHT = "HEIGHT"
    let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
    let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
    let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
    let RESTING_HEART_RATE = "RESTING_HEART_RATE"
    let STEPS = "STEPS"
    let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
    let WALKING_HEART_RATE = "WALKING_HEART_RATE"
    let WEIGHT = "WEIGHT"
    let DISTANCE_WALKING_RUNNING = "DISTANCE_WALKING_RUNNING"
    let FLIGHTS_CLIMBED = "FLIGHTS_CLIMBED"
    let WATER = "WATER"
    let MINDFULNESS = "MINDFULNESS"
    let SLEEP_IN_BED = "SLEEP_IN_BED"
    let SLEEP_ASLEEP = "SLEEP_ASLEEP"
    let SLEEP_AWAKE = "SLEEP_AWAKE"
    let EXERCISE_TIME = "EXERCISE_TIME"
    let WORKOUT = "WORKOUT"

    struct PluginError: Error {
        let message: String
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_health", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Set up all data types
        initializeTypes()

        /// Handle checkIfHealthDataAvailable
        if (call.method.elementsEqual("checkIfHealthDataAvailable")){
            checkIfHealthDataAvailable(call: call, result: result)
        }
        /// Handle requestAuthorization
        else if (call.method.elementsEqual("requestAuthorization")){
            try! requestAuthorization(call: call, result: result)
        }

        /// Handle getData
        else if (call.method.elementsEqual("getData")){
            getData(call: call, result: result)
        }

        /// Handle getTotalStepsInInterval
        else if (call.method.elementsEqual("getTotalStepsInInterval")){
            getTotalStepsInInterval(call: call, result: result)
        }
        
        /// Handle getTotalStepsInInterval
        else if (call.method.elementsEqual("getAudiogramsIds")){
            getAudiogramsIds(call: call, result: result)
        }

        /// Handle writeData
        else if (call.method.elementsEqual("writeData")){
            try! writeData(call: call, result: result)
        }

        /// Handle writeAudiogram
        else if (call.method.elementsEqual("writeAudiogram")){
            try! writeAudiogram(call: call, result: result)
        }
        /// Handle hasPermission
        else if (call.method.elementsEqual("hasPermissions")){
            try! hasPermissions(call: call, result: result)
        }
    }

    func checkIfHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HKHealthStore.isHealthDataAvailable())
    }
    
    func hasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let arguments = call.arguments as? NSDictionary
        guard let types = arguments?["types"] as? Array<String>,
              let permissions = arguments?["permissions"] as? Array<Int>,
              types.count == permissions.count
        else {
            throw PluginError(message: "Invalid Arguments!")
        }
        
        for (index, type) in types.enumerated() {
            let sampleType = dataTypeLookUp(key: type)
            let success = hasPermission(type: sampleType, access: permissions[index])
            if (success == nil || success == false) {
                result(success)
                return
            }
        }

        result(true)
    }

    
    func hasPermission(type: HKSampleType, access: Int) -> Bool? {
        
        if #available(iOS 11.0, *) {
            let status = healthStore.authorizationStatus(for: type)
            switch access {
            case 0: // READ
                return nil
            case 1: // WRITE
                return  (status == HKAuthorizationStatus.sharingAuthorized)
            default: // READ_WRITE
                return nil
            }
        }
        else {
           return nil
        }
    }

    func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        
        guard let arguments = call.arguments as? NSDictionary,
              let types = arguments["types"] as? Array<String>,
              let permissions = arguments["permissions"] as? Array<Int>,
              permissions.count == types.count
        else {
           throw PluginError(message: "Invalid Arguments!")
        }
        
        
        var typesToRead = Set<HKSampleType>()
        var typesToWrite = Set<HKSampleType>()
        for (index, key) in types.enumerated() {
            let dataType = dataTypeLookUp(key: key)
            let access = permissions[index]
            switch access {
            case 0:
                typesToRead.insert(dataType)
            case 1:
                typesToWrite.insert(dataType)
            default:
                typesToRead.insert(dataType)
                typesToWrite.insert(dataType)
            }
        }

        if #available(iOS 11.0, *) {
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
                DispatchQueue.main.async {
                    result(success)
                }
            }
        }
        else {
            result(false)// Handle the error here.
        }
    }
    
    func writeData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
            let value = (arguments["value"] as? Double),
            let type = (arguments["dataTypeKey"] as? String),
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber)
            else {
                throw PluginError(message: "Invalid Arguments")
            }
        
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
        
        print("Successfully called writeData with value of \(value) and type of \(type)")
        
        let sample: HKObject
      
        if (unitLookUp(key: type) == HKUnit.init(from: "")) {
          sample = HKCategorySample(type: dataTypeLookUp(key: type) as! HKCategoryType, value: Int(value), start: dateFrom, end: dateTo)
        } else {
          let quantity = HKQuantity(unit: unitLookUp(key: type), doubleValue: value)
          
          sample = HKQuantitySample(type: dataTypeLookUp(key: type) as! HKQuantityType, quantity: quantity, start: dateFrom, end: dateTo)
        }
        
        HKHealthStore().save(sample, withCompletion: { (success, error) in
            if let err = error {
                print("Error Saving \(type) Sample: \(err.localizedDescription)")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
    
    func writeAudiogram(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
         guard let arguments = call.arguments as? NSDictionary,
             let frequencies = (arguments["frequencies"] as? Array<Double>),
             let leftEarSensitivities = (arguments["leftEarSensitivities"] as? Array<Double>),
             let rightEarSensitivities = (arguments["rightEarSensitivities"] as? Array<Double>),
             let startDate = (arguments["startTime"] as? NSNumber),
             let endDate = (arguments["endTime"] as? NSNumber),
             let metadataReceived = (arguments["metadata"] as? [String: Any]?)
             else {
                 throw PluginError(message: "Invalid Arguments")
             }
        
         let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
         let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
              
         var sensitivityPoints = [HKAudiogramSensitivityPoint]()
        
         for index in 0...frequencies.count-1 {
            let frequency = HKQuantity(unit: HKUnit.hertz(), doubleValue: frequencies[index])
            let dbUnit = HKUnit.decibelHearingLevel()
            let left = HKQuantity(unit: dbUnit, doubleValue: leftEarSensitivities[index])
            let right = HKQuantity(unit: dbUnit, doubleValue: rightEarSensitivities[index])
            let sensitivityPoint = try HKAudiogramSensitivityPoint(frequency: frequency,  leftEarSensitivity: left, rightEarSensitivity: right)
            sensitivityPoints.append(sensitivityPoint)
         }
        
        let audiogram: HKAudiogramSample;
                
        if((metadataReceived!["HKMetadataKeyDeviceName"] != nil) && (metadataReceived!["HKMetadataKeyExternalUUID"] != nil)) {
            audiogram = HKAudiogramSample(sensitivityPoints:sensitivityPoints, start: dateFrom, end: dateTo, metadata: [HKMetadataKeyDeviceName: metadataReceived!["HKMetadataKeyDeviceName"] as! String, HKMetadataKeyExternalUUID: metadataReceived!["HKMetadataKeyExternalUUID"] as! String])
        } else {
            audiogram = HKAudiogramSample(sensitivityPoints:sensitivityPoints, start: dateFrom, end: dateTo, metadata: nil)
        }

         HKHealthStore().save(audiogram, withCompletion: { (success, error) in
             if let err = error {
                 print("Error Saving Audiogram. Sample: \(err.localizedDescription)")
             }
             DispatchQueue.main.async {
                 result(success)
             }
         })
     }

    func getData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
        let limit = (arguments?["limit"] as? Int) ?? HKObjectQueryNoLimit

        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

        let dataType = dataTypeLookUp(key: dataTypeKey)
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query =  HKSampleQuery(sampleType: dataType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) {
            x, samplesOrNil, error in

            switch samplesOrNil {
            case let (samples as [HKQuantitySample]) as Any:
                
                let dictionaries = samples.map { sample -> NSDictionary in
                    let unit = self.unitLookUp(key: dataTypeKey)
                    return [
                        "uuid": "\(sample.uuid)",
                        "value": sample.quantity.doubleValue(for: unit),
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name
                    ]
                }
                DispatchQueue.main.async {
                    result(dictionaries)
                }
                
            case var (samplesCategory as [HKCategorySample]) as Any:
                if (dataTypeKey == self.SLEEP_IN_BED) {
                    samplesCategory = samplesCategory.filter { $0.value == 0 }
                }
                if (dataTypeKey == self.SLEEP_AWAKE) {
                    samplesCategory = samplesCategory.filter { $0.value == 2 }
                }
                if (dataTypeKey == self.SLEEP_ASLEEP) {
                    samplesCategory = samplesCategory.filter { $0.value == 1 }
                }
                let categories = samplesCategory.map { sample -> NSDictionary in
                    return [
                        "uuid": "\(sample.uuid)",
                        "value": sample.value,
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name
                    ]
                }
                DispatchQueue.main.async {
                    result(categories)
                }
                
            case let (samplesWorkout as [HKWorkout]) as Any:
                
                let dictionaries = samplesWorkout.map { sample -> NSDictionary in
                    return [
                        "uuid": "\(sample.uuid)",
                        "value": Int(sample.duration),
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name
                    ]
                }
                
                DispatchQueue.main.async {
                    result(dictionaries)
                }
                
            default:
                DispatchQueue.main.async {
                    result(nil)
                }
            }
        }

        HKHealthStore().execute(query)
    }

     func getTotalStepsInInterval(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0

        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

        let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: sampleType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum) { query, queryResult, error in

            guard let queryResult = queryResult else {
                let error = error! as NSError
                print("Error getting total steps in interval \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }

            var steps = 0.0

            if let quantity = queryResult.sumQuantity() {
                let unit = HKUnit.count()
                steps = quantity.doubleValue(for: unit)
            }

            let totalSteps = Int(steps)
            DispatchQueue.main.async {
                result(totalSteps)
            }
        }

        HKHealthStore().execute(query)
    }
    
    func getAudiogramsIds(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let query = HKSampleQuery.init(sampleType: HKSampleType.audiogramSampleType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, queryResult, error) in
            
            guard let queryResult : [HKSample] = queryResult else {
                let error = error! as NSError
                print("Error getting total steps in interval \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            var ids: Array<String> = [];
            for result in queryResult {
                guard let dataItem:HKAudiogramSample = result as? HKAudiogramSample else { return }
                guard let id: String = dataItem.metadata?["HKMetadataKeyExternalUUID"] as? String else { continue }
                ids.append(id)
            }
            print(ids)

            if(ids.isEmpty) {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            } else {
                DispatchQueue.main.async {
                    result(ids)
                }
                return
            }
       }
        
       HKHealthStore().execute(query)
    }

    func unitLookUp(key: String) -> HKUnit {
        guard let unit = unitDict[key] else {
            return HKUnit.count()
        }
        return unit
    }

    func dataTypeLookUp(key: String) -> HKSampleType {
        guard let dataType_ = dataTypesDict[key] else {
            return HKSampleType.quantityType(forIdentifier: .bodyMass)!
        }
        return dataType_
    }

    func initializeTypes() {
        unitDict[ACTIVE_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[AUDIOGRAM] = HKUnit.decibelHearingLevel()
        unitDict[BASAL_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[BLOOD_GLUCOSE] = HKUnit.init(from: "mg/dl")
        unitDict[BLOOD_OXYGEN] = HKUnit.percent()
        unitDict[BLOOD_PRESSURE_DIASTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[BLOOD_PRESSURE_SYSTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[BODY_FAT_PERCENTAGE] = HKUnit.percent()
        unitDict[BODY_MASS_INDEX] = HKUnit.init(from: "")
        unitDict[BODY_TEMPERATURE] = HKUnit.degreeCelsius()
        unitDict[DIETARY_CARBS_CONSUMED] = HKUnit.gram()
        unitDict[DIETARY_ENERGY_CONSUMED] = HKUnit.kilocalorie()
        unitDict[DIETARY_FATS_CONSUMED] = HKUnit.gram()
        unitDict[DIETARY_PROTEIN_CONSUMED] = HKUnit.gram()
        unitDict[ELECTRODERMAL_ACTIVITY] = HKUnit.siemen()
        unitDict[FORCED_EXPIRATORY_VOLUME] = HKUnit.liter()
        unitDict[HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[HEART_RATE_VARIABILITY_SDNN] = HKUnit.secondUnit(with: .milli)
        unitDict[HEIGHT] = HKUnit.meter()
        unitDict[RESTING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[STEPS] = HKUnit.count()
        unitDict[WAIST_CIRCUMFERENCE] = HKUnit.meter()
        unitDict[WALKING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[WEIGHT] = HKUnit.gramUnit(with: .kilo)
        unitDict[DISTANCE_WALKING_RUNNING] = HKUnit.meter()
        unitDict[FLIGHTS_CLIMBED] = HKUnit.count()
        unitDict[WATER] = HKUnit.liter()
        unitDict[MINDFULNESS] = HKUnit.init(from: "")
        unitDict[SLEEP_IN_BED] = HKUnit.init(from: "")
        unitDict[SLEEP_ASLEEP] = HKUnit.init(from: "")
        unitDict[SLEEP_AWAKE] = HKUnit.init(from: "")
        unitDict[EXERCISE_TIME] =  HKUnit.minute()
        unitDict[WORKOUT] = HKUnit.init(from: "")

        // Set up iOS 11 specific types (ordinary health data types)
        if #available(iOS 11.0, *) {
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
            dataTypesDict[AUDIOGRAM] = HKSampleType.audiogramSampleType()
            dataTypesDict[BASAL_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!
            dataTypesDict[BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
            dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
            dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!
            dataTypesDict[BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!
            dataTypesDict[BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
            dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
            dataTypesDict[DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            dataTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            dataTypesDict[DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
            dataTypesDict[DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
            dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(forIdentifier: .electrodermalActivity)!
            dataTypesDict[FORCED_EXPIRATORY_VOLUME] = HKSampleType.quantityType(forIdentifier: .forcedExpiratoryVolume1)!
            dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
            dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
            dataTypesDict[HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
            dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .restingHeartRate)!
            dataTypesDict[STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
            dataTypesDict[WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(forIdentifier: .waistCircumference)!
            dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            dataTypesDict[WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
            dataTypesDict[FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
            dataTypesDict[WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataTypesDict[MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
            dataTypesDict[SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
            dataTypesDict[WORKOUT] = HKSampleType.workoutType()

            healthDataTypes = Array(dataTypesDict.values)
        }
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *){
            dataTypesDict[HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!
            dataTypesDict[LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!
            dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!

            heartRateEventTypes =  Set([
                HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
                ])
        }

        // Concatenate heart events and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
    }
}




