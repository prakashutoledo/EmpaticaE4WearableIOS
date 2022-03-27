//
//  EmpaticaE4Service.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 6/3/21.
//

import Disruptor
import Combine
import Kronos

typealias ElasticsearchDisruptor =  Disruptor<ElasticsearchEvent>

class EmpaticaE4Service: NSObject, ObservableObject {
    public static var currentView: String = ""
    public static var subjectId: String = ""
    public static var storeSession: Bool = false
    public static var showChart: Bool = false
    public static var serialNumber: String = ""
    
    @Published
    public var availableDevices: [EmpaticaDeviceManager] =  []
    
    @Published
    public var connectedDevice: EmpaticaDeviceManager? = nil
    
    @Published
    public var gsrData: [Double] = []
    
    @Published
    public var ibiData: [Double] = []
    
    @Published
    public var bvpData: [Double] = []
    
    @Published
    public var temperatureData: [Double] = []
    
    @Published
    public var accXData: [Double] = []
    
    @Published
    public var currentAccX: Float = 0.0
    
    @Published
    public var deviceWristStatus: String = "---"
    
    @Published
    public var batteryStatus: Int32 = 0
    
    @Published
    public var currentBVP: Float = 0.0
    
    @Published
    public var currentIBI: Float = 0.0
    
    @Published
    public var currentGSR: Float = 0.0
    
    @Published
    public var currentTemp: Float = 0.0
    
    private let elasticsearchDisruptor: ElasticsearchDisruptor
    private var graphTimer: Timer?
    private let disruptorAccessQueue: DispatchQueue
    private var startSession: Bool
    private var startElasticsearchDisruptor: Bool
    
    private override init() {
        self.elasticsearchDisruptor = ElasticsearchDisruptor(
            eventFactory: ElasticsearchFactory(),
            ringBufferSize: NasaTLXGlobals.disruptorRingBufferEventSize,
            producerType: .multi
        )
        self.graphTimer = nil
        
        self.disruptorAccessQueue = DispatchQueue(
            label: "disruptorConcurrent",
            attributes: .concurrent
        )
        self.startSession = false
        self.startElasticsearchDisruptor = false
        
        super.init()
        
        self.initialize()
        self.authenticate()
    }
}

extension EmpaticaE4Service {
    public static let singleton: EmpaticaE4Service = EmpaticaE4Service()
}

extension EmpaticaE4Service {
    public func startDeviceSession() -> Void {
        self.startSession = true
        print("start")
    }
    
    public func stopDeviceSession() -> Void {
        self.startSession = false
        print("stopped")
    }
}

extension EmpaticaE4Service {
    func prepareForResume() -> Void {
        EmpaticaAPI.prepareForResume()
    }
    
    func prepareForBackground() -> Void {
        EmpaticaAPI.prepareForBackground()
    }
    
    private func authenticate() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            EmpaticaAPI.authenticate(
                withAPIKey: NasaTLXGlobals.empaticaClientAPIKey,
                andCompletionHandler: self.authenticationCompletionHandler
            )
        }
    }
    
    private func initialize() -> Void {
        EmpaticaAPI.initialize()
    }
    
    func connectToDevice(device: EmpaticaDeviceManager) -> Void {
        device.connect(with: self)
        self.connectedDevice = device
        self.availableDevices = []
        self.initDisruptor()
    }
    
    public func disconnectDevice() -> Void {
        if self.connectedDevice?.deviceStatus == kDeviceStatusConnecting {
            self.connectedDevice?.cancelConnection()
        }
        
        if self.connectedDevice?.deviceStatus == kDeviceStatusConnected {
            self.connectedDevice?.disconnect()
            self.connectedDevice = nil
            self.elasticsearchDisruptor.halt()
            return
        }
    }
    
    private func isDeviceDisconnected() -> Bool {
        if let device = self.connectedDevice {
            return device.deviceStatus == kDeviceStatusDisconnected
        }
        return true
    }
    
    private func authenticationCompletionHandler(authenticationStatus: Bool, message: String?) -> Void {
        if authenticationStatus {
            print("Succesfully authenticated to Empatica client")
        }
        else {
            print("\(message!)")
        }
    }
    
    public func discoverDevices() -> Void {
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    private func restartDeviceDiscovery() -> Void {
        guard EmpaticaAPI.status() == kBLEStatusScanning else {
            return
        }
        if self.isDeviceDisconnected() {
            self.discoverDevices()
        }
    }
}

extension EmpaticaE4Service {
    private func initDisruptor() -> Void {
        if (!self.startElasticsearchDisruptor) {
            self.elasticsearchDisruptor.handleEventsWith(eventHandlers: [ElasticsearchEventHandler()])
            _ = self.elasticsearchDisruptor.start()
        }
    }
}

extension EmpaticaE4Service {
    public func getElasticsearchDisruptor() ->  ElasticsearchDisruptor? {
        var disruptor: ElasticsearchDisruptor?
        disruptorAccessQueue.sync {
            disruptor = self.elasticsearchDisruptor
        }
        return disruptor
    }
    
    public func writeToElasticsearch(jsonEvent: String, indexName: String) -> Void {
        let elasticsearchEvent: ElasticsearchEvent =  ElasticsearchEvent()
        elasticsearchEvent.jsonEvent = jsonEvent
        elasticsearchEvent.indexName = indexName
        self.writeToElasticsearch(elasticsearchEvent: elasticsearchEvent)
    }
    
    public func writeToElasticsearch(elasticsearchEvent: ElasticsearchEvent) -> Void {
        self.disruptorAccessQueue.async {
            self.elasticsearchDisruptor.publishEvent(ElasticsearchEventTranslator(), input: elasticsearchEvent)
        }
    }
    
    public func writeToElasticsearch<Event>(baseEvent: Event, indexName: String) -> Void where Event: BaseEvent {
        let elasticsearchEvent: ElasticsearchEvent = ElasticsearchEvent()
        elasticsearchEvent.jsonEvent = baseEvent.toJson()
        elasticsearchEvent.indexName = indexName
        self.writeToElasticsearch(elasticsearchEvent: elasticsearchEvent)
    }
}

extension EmpaticaE4Service {
    public func startGraphTimer() {
        self.graphTimer = Timer(timeInterval: 60.0, target: self, selector: #selector(clearStoredData), userInfo: "E4 Service Context", repeats: true)
        RunLoop.current.add(graphTimer!, forMode: .common)
        print("Graph timer started")
    }
    
    @objc
    public func clearStoredData() -> Void {
        print("Clear stored data from timer")
        var oldGsr = self.gsrData
        var oldAccX = self.accXData
        var oldBVP = self.bvpData
        var oldIBI = self.ibiData
        var oldTemperature = self.temperatureData
        
        self.gsrData = []
        self.accXData = []
        self.bvpData = []
        self.ibiData = []
        self.temperatureData = []
        
        oldGsr.removeAll()
        oldAccX.removeAll()
        oldBVP.removeAll()
        oldIBI.removeAll()
        oldTemperature.removeAll()
    }
    
    func endGraphTimer() -> Void {
        if let timer = self.graphTimer {
            timer.invalidate()
            print("Graph timer invaldated")
            self.clearStoredData()
        }
        self.graphTimer = nil
    }
    
    func printGraphDataInfo() -> Void {
        print("ACCX \(self.accXData.count)")
        print("IBI \(self.ibiData.count)")
        print("BVP \(self.bvpData.count)")
        print("Temmp \(self.temperatureData.count)")
        print("GSR \(self.gsrData.count)")
    }
}

extension EmpaticaE4Service {
    func insertAssesmentRating(assesmentRating: AssesmentRating) -> Void {
        self.writeToElasticsearch(jsonEvent: assesmentRating.toJson(), indexName: "rating")
    }
}

extension EmpaticaE4Service: EmpaticaDelegate {
    func didUpdate(_ status: BLEStatus) {
        switch status {
        case kBLEStatusReady:
            print("Bluetooth low energy status ready");
            break
        case kBLEStatusScanning:
            print("Bluetooth low energy status scanning for devices");
            break
        case kBLEStatusNotAvailable:
            print("Bluetooth low energy is not available");
            break
        default:
            print("Status \(status.rawValue)");
        }
    }
    
    func didDiscoverDevices(_ devices: [Any]!) {
        print("Discovered devices")
        DispatchQueue.main.async {
            self.availableDevices = devices as! [EmpaticaDeviceManager]
        }
    }
}

extension EmpaticaE4Service: EmpaticaDeviceDelegate {
    func didReceiveTag(atTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("\(device.serialNumber!) TAG received: {\(timestamp)}")
    }
    
    func didReceiveAccelerationX(_ x: CChar, y: CChar, z: CChar, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.startSession {
            let accelerationEvent = AccelerationEvent()
            accelerationEvent.accelerationX = Int(x)
            accelerationEvent.accelerationY = Int(y)
            accelerationEvent.accelerationZ = Int(z)
            accelerationEvent.acquiredTime = Clock.now
            accelerationEvent.actualTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            accelerationEvent.fromView = EmpaticaE4Service.currentView
            accelerationEvent.subjectId = EmpaticaE4Service.subjectId
            self.writeToElasticsearch(baseEvent: accelerationEvent, indexName: "accelerometer")
        }

        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.currentAccX = Float(x)
                if self.accXData.count > 100 {
                    self.accXData.removeFirst()
                }
                self.accXData.append(Double(x))
            }
        }
    }
    
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.startSession {
            let temperatureEvent: TemperatureEvent =  TemperatureEvent()
            temperatureEvent.temperature = temp
            temperatureEvent.acquiredTime = Clock.now
            temperatureEvent.actualTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            temperatureEvent.fromView = EmpaticaE4Service.currentView
            temperatureEvent.subjectId = EmpaticaE4Service.subjectId
            
            self.writeToElasticsearch(baseEvent: temperatureEvent, indexName: "temperature")
        }
        
        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.currentTemp = temp
                self.temperatureData.append(Double(temp))
            }
        }
    }
    
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.startSession {
            let gsrEvent: GSREvent = GSREvent()
            gsrEvent.gsr = gsr
            gsrEvent.acquiredTime = Clock.now
            gsrEvent.actualTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            gsrEvent.fromView = EmpaticaE4Service.currentView
            gsrEvent.subjectId = EmpaticaE4Service.subjectId
            self.writeToElasticsearch(baseEvent: gsrEvent, indexName: "gsr")
        }

        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.currentGSR = gsr
                self.gsrData.append(Double(gsr))
            }
        }
    }
    
    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.startSession {
            let bvpEvent: BVPEvent = BVPEvent()
            bvpEvent.bvp = bvp
            bvpEvent.acquiredTime = Clock.now
            bvpEvent.actualTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            bvpEvent.fromView = EmpaticaE4Service.currentView
            bvpEvent.subjectId = EmpaticaE4Service.subjectId
            self.writeToElasticsearch(baseEvent: bvpEvent, indexName: "bvp")
        }
        
        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.currentBVP = bvp
                if self.bvpData.count > 400 {
                    self.bvpData.removeFirst()
                }
                self.bvpData.append(Double(bvp))
            }
        }
    }
    
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.startSession {
            let ibiEvent: IBIEvent =  IBIEvent()
            ibiEvent.ibi = ibi
            ibiEvent.acquiredTime = Date()
            ibiEvent.acquiredTime = Clock.now
            ibiEvent.actualTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
            ibiEvent.fromView = EmpaticaE4Service.currentView
            ibiEvent.subjectId = EmpaticaE4Service.subjectId
            
            self.writeToElasticsearch(baseEvent: ibiEvent, indexName: "ibi")
        }
        
        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.currentIBI = ibi
                self.ibiData.append(Double(ibi))
            }
        }
    }
    
    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if EmpaticaE4Service.showChart {
            DispatchQueue.main.async {
                self.batteryStatus = Int32(level * 100)
            }
        }
    }
    
    func didUpdate(onWristStatus: SensorStatus, forDevice device: EmpaticaDeviceManager!) {
        DispatchQueue.main.async {
            switch onWristStatus {
                case kE2SensorStatusNotOnWrist:
                    self.deviceWristStatus = "Not On Wrist"
                    break
                case kE2SensorStatusOnWrist:
                    self.deviceWristStatus = "On Wrist"
                    break
                case kE2SensorStatusDead:
                    self.deviceWristStatus = "Dead"
                    break
                default:
                    print("Not a valid onWristStatus")
            
            }
        }
    }
    
    func didUpdate(_ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        switch status {
            case kDeviceStatusConnected:
                print("Succesfully connected to device: \(device.serialNumber!)")
                break
            case kDeviceStatusConnecting:
                print("Connecting to device: \(device.serialNumber!)")
                break
            case kDeviceStatusDisconnected:
                print("Disconnected from device: \(device.serialNumber!)")
                self.connectedDevice = nil
                self.restartDeviceDiscovery()
                break
            case kDeviceStatusDisconnecting:
                print("Disconnecting from device: \(device.serialNumber!)")
                break
            case kDeviceStatusFailedToConnect:
                print("Failed to connect to device: \(device.serialNumber!)")
                self.connectedDevice = nil
                self.restartDeviceDiscovery()
            default:
                print("Not a valid device update status")
        }
    }
}
