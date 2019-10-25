import Flutter
import UIKit
import HealthKit

public class SwiftFlutterHealthPlugin: NSObject, FlutterPlugin {
    
    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_health", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterHealthPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    /// CHECK IF HEALTHDATA AVAILABLE METHOD CALL
    if(call.method.elementsEqual("checkIfHealthDataAvailable")){
        result(HKHealthStore.isHealthDataAvailable())
    } 
    ///REQUEST AUTH METHOD CALL
    else if(call.method.elementsEqual("requestAuthorization")){
        var heartRateEventTypes = Set<HKSampleType>()
        if #available(iOS 12.2, *){
            heartRateEventTypes =  Set([
                HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
               ])
        }
        if #available(iOS 11.0, *) {
            let allDataTypes = Set(heartRateEventTypes + healthDataTypes)
            healthStore.requestAuthorization(toShare: nil, read: allDataTypes) { (success, error) in
                result(success)
            }
        } 
        else {
            result(false)// Handle the error here.
        }
    } 
    /// GET DATA METHOD CALL
    else if(call.method.elementsEqual("getData")){
        let arguments = call.arguments as? NSDictionary
        let index = (arguments?["index"] as? Int) ?? -1
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
        
        
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
        
        if #available(iOS 11.0, *) {
            healthDataTypes = [
                HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!,
                HKSampleType.quantityType(forIdentifier: .height)!,
                HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!,
                HKSampleType.quantityType(forIdentifier: .waistCircumference)!,
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!,
                HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.quantityType(forIdentifier: .bodyTemperature)!,
                HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                HKSampleType.quantityType(forIdentifier: .restingHeartRate)!,
                HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKSampleType.quantityType(forIdentifier: .bloodGlucose)!,
                HKSampleType.quantityType(forIdentifier: .electrodermalActivity)!,
                ]
            print("INDEX IS " , index)
            print("COUNT IS " , healthDataTypes.count)
            if(index >= 0 && index < healthDataTypes.count){
                let dataType = healthDataTypes[index]
                print("DATA TYPE IS ", dataType)
                let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
                print("PREDICATE ", predicate)
                if (self.healthStore.authorizationStatus(for: dataType) == .sharingAuthorized) {
                }

                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

                
                let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
                    x, samplesOrNil, error in
                    
                    guard let samples = samplesOrNil as? [HKQuantitySample] else {
                        result(FlutterError(code: "FlutterHealth", message: "Results are null", details: error))
                        return
                    }

                    if(samples != nil){
                    result(samples.map { sample -> NSDictionary in
                        let unit = self.unitFromDartType(type: index)
                        return [
                            "value": sample.quantity.doubleValue(for: unit),
                            "unit": unit.unitString,
                            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                            "data_type_index": index,
                        ]
                    })
                    } else {
                        print("Either there are no values or the user did not allow getting this value")
                        result("Either there are no values or the user did not allow getting this value")
                    }
                    return
                }
                HKHealthStore().execute(query)
            } else{
                print("Something wrong with request")
                result("Unsupported version or data type")
            }
        } else {
            print("Unsupported version 1")
            result("Unsupported version or data type")
        }
        print("Unsupported version")
    }
    
  }
    
    public func unitFromDartType(type: Int) -> HKUnit {
        guard let unit: HKUnit = {
            switch (type) {
            case 0:
                return HKUnit.percent()
            case 1:
                return HKUnit.meter()
            case 2:
                return HKUnit.init(from: "")
            case 3:
                return HKUnit.meter()
            case 4:
                return HKUnit.count()
            case 5,6:
                return HKUnit.kilocalorie()
            case 7, 11, 12:
                return HKUnit.init(from: "count/min")
            case 8:
                return HKUnit.degreeCelsius()
            case 9,10:
                return HKUnit.millimeterOfMercury()
            case 13:
                return HKUnit.percent()
            case 14:
                return HKUnit.init(from: "mg/dl")
            case 15:
                return HKUnit.siemen()
            default:
                return HKUnit.count()
            }
            }() else {
                return HKUnit.count()
        }
        return unit
    }
}




