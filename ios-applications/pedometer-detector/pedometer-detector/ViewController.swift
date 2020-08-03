import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let stepCounter = StepCounter()
    let stepDetector = StepDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepCounter.onListen()
        stepDetector.onListen()
    }
}

class StepDetector {
    private let pedometer = CMPedometer()
    private var running = false
    private let available = CMPedometer.isStepCountingAvailable()
    
    func onListen() {
        if (!CMPedometer.isPedometerEventTrackingAvailable()) {
            print("Step Detection is not available")
        }
        else if (!running) {
            running = true
            pedometer.startEventUpdates() {
                pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                
                DispatchQueue.main.async {
                    self.handleEvent(status: pedometerData.type.rawValue)
                }
            }
        }
    }
    
    func handleEvent(status: Int) {
        let pedestrianStatus = status == 0 ? "STOPPED" : "WALKING"
        print("Pedestrian Status: \(pedestrianStatus)")
    }
    
    
    func onCancel() {
        if (running) {
            pedometer.stopUpdates()
            running = false
        }
    }
}

class StepCounter {
    private let pedometer = CMPedometer()
    private var running = false
    private let available = CMPedometer.isStepCountingAvailable()
    
    func onListen() {
        if (!CMPedometer.isStepCountingAvailable()) {
            print("Step count is not available")
        }
        else if (!running) {
            let systemUptime = ProcessInfo.processInfo.systemUptime;
            let timeNow = Date().timeIntervalSince1970
            let dateOfLastReboot = Date(timeIntervalSince1970: timeNow - systemUptime)
            running = true
            pedometer.startUpdates(from: dateOfLastReboot) {
                pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                
                DispatchQueue.main.async {
                    self.handleEvent(count: pedometerData.numberOfSteps.intValue)
                }
            }
        }
    }
    
    func handleEvent(count: Int) {
        print("Step Count: \(count)")
    }
    
    func onCancel() {
        if (running) {
            pedometer.stopUpdates()
            running = false
        }
    }
}

