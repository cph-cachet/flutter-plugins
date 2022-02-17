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
    
    let DIETARY_FAT_SATURATED = "DIETARY_FAT_SATURATED"
    let DIETARY_FAT_POLYUNSATURATED = "DIETARY_FAT_POLYUNSATURATED"
    let DIETARY_FAT_MONOUNSATURATED = "DIETARY_FAT_MONOUNSATURATED"
    let DIETARY_CHOLESTEROL = "DIETARY_CHOLESTEROL"
    let DIETARY_SODIUM = "DIETARY_SODIUM"
    let DIETARY_POTASSIUM = "DIETARY_POTASSIUM"
    let DIETARY_FIBER = "DIETARY_FIBER"
    let DIETARY_SUGAR = "DIETARY_SUGAR"
    let DIETARY_VITAMIN_A = "DIETARY_VITAMIN_A"
    let DIETARY_THIAMIN = "DIETARY_THIAMIN"
    let DIETARY_RIBOFLAVIN = "DIETARY_RIBOFLAVIN"
    let DIETARY_NIACIN = "DIETARY_NIACIN"
    let DIETARY_PANTOTHENIC_ACID = "DIETARY_PANTOTHENIC_ACID"
    let DIETARY_VITAMIN_B6 = "DIETARY_VITAMIN_B6"
    let DIETARY_VITAMIN_B12 = "DIETARY_VITAMIN_B12"
    let DIETARY_VITAMIN_C = "DIETARY_VITAMIN_C"
    let DIETARY_VITAMIN_D = "DIETARY_VITAMIN_D"
    let DIETARY_VITAMIN_E = "DIETARY_VITAMIN_E"
    let DIETARY_VITAMIN_K = "DIETARY_VITAMIN_K"
    let DIETARY_FOLATE = "DIETARY_FOLATE"
    let DIETARY_CALCIUM = "DIETARY_CALCIUM"
    let DIETARY_IRON = "DIETARY_IRON"
    let DIETARY_MAGNESIUM = "DIETARY_MAGNESIUM"
    let DIETARY_PHOSPHORUS = "DIETARY_PHOSPHORUS"
    let DIETARY_ZINC = "DIETARY_ZINC"
    let DIETARY_WATER = "DIETARY_WATER"
    let DIETARY_CAFFEINE = "DIETARY_CAFFEINE"
    let DIETARY_COPPER = "DIETARY_COPPER"
    let DIETARY_MANGANESE = "DIETARY_MANGANESE"
    let DIETARY_SELENIUM = "DIETARY_SELENIUM"

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
        
        /// Handle deleteData
        else if (call.method.elementsEqual("deleteData")){
            try! deleteData(call: call, result: result)
        }
        
        /// Handle deleteFoodData
        else if (call.method.elementsEqual("deleteFoodData")){
            try! deleteFoodData(call: call, result: result)
        }
        
        /// Handle writeFoodData
        else if (call.method.elementsEqual("writeFoodData")){
            try! writeFoodData(call: call, result: result)
        }

        /// Handle getTotalStepsInInterval
        else if (call.method.elementsEqual("getTotalStepsInInterval")){
            getTotalStepsInInterval(call: call, result: result)
        }

        /// Handle writeData
        else if (call.method.elementsEqual("writeData")){
            try! writeData(call: call, result: result)
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
    
    func writeFoodData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
            let foodList = arguments["foodList"] as? Array<Dictionary<String, Any>>,
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber),
            let overwrite = (arguments["overwrite"] as? Bool)
            else {
                throw PluginError(message: "Invalid Arguments")
            }
        
        NSLog("Successfully called writeFoodData")
        
        let nutrientsToWrite: Array<String> = [DIETARY_ENERGY_CONSUMED,
                                               DIETARY_PROTEIN_CONSUMED,
                                               DIETARY_FATS_CONSUMED,
                                               DIETARY_CARBS_CONSUMED,
                                               DIETARY_FAT_SATURATED,
                                               DIETARY_FAT_POLYUNSATURATED,
                                               DIETARY_FAT_MONOUNSATURATED,
                                               DIETARY_CHOLESTEROL,
                                               DIETARY_SODIUM,
                                               DIETARY_POTASSIUM,
                                               DIETARY_FIBER,
                                               DIETARY_SUGAR,
                                               DIETARY_VITAMIN_A,
                                               DIETARY_THIAMIN,
                                               DIETARY_RIBOFLAVIN,
                                               DIETARY_NIACIN,
                                               DIETARY_PANTOTHENIC_ACID,
                                               DIETARY_VITAMIN_B6,
                                               DIETARY_VITAMIN_B12,
                                               DIETARY_VITAMIN_C,
                                               DIETARY_VITAMIN_D,
                                               DIETARY_VITAMIN_E,
                                               DIETARY_VITAMIN_K,
                                               DIETARY_FOLATE,
                                               DIETARY_CALCIUM,
                                               DIETARY_IRON,
                                               DIETARY_MAGNESIUM,
                                               DIETARY_PHOSPHORUS,
                                               DIETARY_ZINC,
                                               DIETARY_WATER,
                                               DIETARY_CAFFEINE,
                                               DIETARY_COPPER,
                                               DIETARY_MANGANESE,
                                               DIETARY_SELENIUM]
        
        var nutrientAccess: [String: Bool?] = [:]
        
        for nutrient in nutrientsToWrite {
            let type = dataTypeLookUp(key: nutrient)
            let permission = hasPermission(type: type, access: 1)
            nutrientAccess[nutrient] = permission
        }
    
        let healthKitStore = HKHealthStore()
        
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
                
        let query = HKCorrelationQuery(type: HKCorrelationType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!, predicate: HKCorrelationQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []), samplePredicates: nil)
        {
            query, results, error in
            
            if let correlations = results {
                var samplesToDelete: Array<HKSample> = []
                for correlation in correlations {
                    for sample in correlation.objects {
                        samplesToDelete.append(sample)
                    }
                }
                
                if (overwrite == true) {
                    if (!samplesToDelete.isEmpty) {
                        healthKitStore.delete(samplesToDelete, withCompletion: { (success, error) in
                            if let err = error {
                                NSLog("Error Deleting, Sample: \(err.localizedDescription)")
                            }
                        })
                    }
                }
                
                var consumedFoods: Array<HKCorrelation> = []
                
                for food in foodList {
                    var iterationFood = food
                    
                    var consumedSamples: Set<HKSample> = []
                    
                    let timestamp = iterationFood.removeValue(forKey: "timestamp") as! NSNumber
                    let date = Date(timeIntervalSince1970: timestamp.doubleValue / 1000)
                    
                    for (key, value) in iterationFood {
                        if let access = nutrientAccess[key] {
                            if (access == true) {
                                let sample = HKQuantitySample(
                                    type: self.dataTypeLookUp(key: key) as! HKQuantityType,
                                    quantity: HKQuantity(unit: self.unitLookUp(key: key), doubleValue: value as! Double),
                                    start: date,
                                    end: date)
                                
                                consumedSamples.insert(sample)
                            }
                        } else {
                          NSLog("Unknown nutrient or nutrient access")
                        }
                    }
                    
                    if (!consumedSamples.isEmpty) {
                        let foodType: HKCorrelationType = HKCorrelationType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!

                        let foodCorrelation: HKCorrelation = HKCorrelation(type: foodType, start: date, end: date, objects: consumedSamples)
                        
                        consumedFoods.append(foodCorrelation)
                    }
                }
                
                if (!consumedFoods.isEmpty) {
                    healthKitStore.save(consumedFoods, withCompletion: { (success, error) in
                        if let err = error {
                            NSLog("Error Saving, Sample: \(err.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            result(success)
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        result(true)
                    }
                }
            }
            else {
                if let err = error {
                    NSLog("Error Querying For Samples to Delete, Sample: \(err.localizedDescription)")
                }
            }
        }
        healthKitStore.execute(query)
    }
    
    func deleteFoodData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber)
            else {
                throw PluginError(message: "Invalid Arguments")
            }
        
        NSLog("Successfully called deleteFoodData")
    
        let healthKitStore = HKHealthStore()
        
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
                
        let query = HKCorrelationQuery(type: HKCorrelationType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!, predicate: HKCorrelationQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []), samplePredicates: nil)
        {
            query, results, error in
            
            if let correlations = results {
                var samplesToDelete: Array<HKSample> = []
                for correlation in correlations {
                    for sample in correlation.objects {
                        samplesToDelete.append(sample)
                    }
                }
                
                if (!samplesToDelete.isEmpty) {
                    healthKitStore.delete(samplesToDelete, withCompletion: { (success, error) in
                        if let err = error {
                            NSLog("Error Deleting, Sample: \(err.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            result(success)
                        }
                    })
                }
            }
            else {
                if let err = error {
                    NSLog("Error Querying For Samples to Delete, Sample: \(err.localizedDescription)")
                }
            }
        }
        healthKitStore.execute(query)
    }
    
    func writeData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
            let value = (arguments["value"] as? Double),
            let type = (arguments["dataTypeKey"] as? String),
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber),
            let overwrite = (arguments["overwrite"] as? Bool)
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
        
        let healthKitStore = HKHealthStore()
        
        if (overwrite == true) {
            healthKitStore.deleteObjects(of: dataTypeLookUp(key: type), predicate: HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []), withCompletion: { (success, _, error) in
                if let err = error {
                    print("Error Deleting \(type) Sample: \(err.localizedDescription)")
                }
                DispatchQueue.main.async {
                    result(success)
                }
            })
        }
        
        healthKitStore.save(sample, withCompletion: { (success, error) in
            if let err = error {
                print("Error Saving \(type) Sample: \(err.localizedDescription)")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
    
    func deleteData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
            let type = (arguments["dataTypeKey"] as? String),
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber)
            else {
                throw PluginError(message: "Invalid Arguments")
            }
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
        
        print("Successfully called deleteData with type of \(type)")
        
        HKHealthStore().deleteObjects(of: dataTypeLookUp(key: type), predicate: HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []), withCompletion: { (success, _, error) in
                if let err = error {
                    print("Error Deleting \(type) Sample: \(err.localizedDescription)")
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
        unitDict[DIETARY_FAT_SATURATED] = HKUnit.gram()
        unitDict[DIETARY_FAT_POLYUNSATURATED] = HKUnit.gram()
        unitDict[DIETARY_FAT_MONOUNSATURATED] = HKUnit.gram()
        unitDict[DIETARY_CHOLESTEROL] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_SODIUM] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_POTASSIUM] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_FIBER] = HKUnit.gram()
        unitDict[DIETARY_SUGAR] = HKUnit.gram()
        unitDict[DIETARY_VITAMIN_A] = HKUnit.gramUnit(with: .micro)
        unitDict[DIETARY_THIAMIN] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_RIBOFLAVIN] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_NIACIN] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_PANTOTHENIC_ACID] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_VITAMIN_B6] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_VITAMIN_B12] = HKUnit.gramUnit(with: .micro)
        unitDict[DIETARY_VITAMIN_C] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_VITAMIN_D] = HKUnit.gramUnit(with: .micro)
        unitDict[DIETARY_VITAMIN_E] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_VITAMIN_K] = HKUnit.gramUnit(with: .micro)
        unitDict[DIETARY_FOLATE] = HKUnit.gramUnit(with: .micro)
        unitDict[DIETARY_CALCIUM] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_IRON] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_MAGNESIUM] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_PHOSPHORUS] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_ZINC] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_WATER] = HKUnit.gram()
        unitDict[DIETARY_CAFFEINE] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_COPPER] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_MANGANESE] = HKUnit.gramUnit(with: .milli)
        unitDict[DIETARY_SELENIUM] = HKUnit.gramUnit(with: .milli)
        

        // Set up iOS 11 specific types (ordinary health data types)
        if #available(iOS 11.0, *) {
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
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
            dataTypesDict[DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
            dataTypesDict[DIETARY_FAT_POLYUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)!
            dataTypesDict[DIETARY_FAT_MONOUNSATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)!
            dataTypesDict[DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
            dataTypesDict[DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
            dataTypesDict[DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
            dataTypesDict[DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
            dataTypesDict[DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
            dataTypesDict[DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
            dataTypesDict[DIETARY_THIAMIN] = HKSampleType.quantityType(forIdentifier: .dietaryThiamin)!
            dataTypesDict[DIETARY_RIBOFLAVIN] = HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)!
            dataTypesDict[DIETARY_NIACIN] = HKSampleType.quantityType(forIdentifier: .dietaryNiacin)!
            dataTypesDict[DIETARY_PANTOTHENIC_ACID] = HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)!
            dataTypesDict[DIETARY_VITAMIN_B6] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)!
            dataTypesDict[DIETARY_VITAMIN_B12] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)!
            dataTypesDict[DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
            dataTypesDict[DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
            dataTypesDict[DIETARY_VITAMIN_E] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)!
            dataTypesDict[DIETARY_VITAMIN_K] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)!
            dataTypesDict[DIETARY_FOLATE] = HKSampleType.quantityType(forIdentifier: .dietaryFolate)!
            dataTypesDict[DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
            dataTypesDict[DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
            dataTypesDict[DIETARY_MAGNESIUM] = HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)!
            dataTypesDict[DIETARY_PHOSPHORUS] = HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)!
            dataTypesDict[DIETARY_ZINC] = HKSampleType.quantityType(forIdentifier: .dietaryZinc)!
            dataTypesDict[DIETARY_WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataTypesDict[DIETARY_CAFFEINE] = HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
            dataTypesDict[DIETARY_COPPER] = HKSampleType.quantityType(forIdentifier: .dietaryCopper)!
            dataTypesDict[DIETARY_MANGANESE] = HKSampleType.quantityType(forIdentifier: .dietaryManganese)!
            dataTypesDict[DIETARY_SELENIUM] = HKSampleType.quantityType(forIdentifier: .dietarySelenium)!
            

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




