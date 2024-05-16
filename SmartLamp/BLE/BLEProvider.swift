//
//  BLEProvider.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit
import CoreBluetooth

class BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public var manager: CBCentralManager!
    public let notificationCenter = NotificationCenter.default
    public var list: Set<CBPeripheral> = [] // all devices at the scanning moment
    private var checkList: Set<PossibleDevice> = [] // here we store all devices we have ever connected with
    public var connectedDevices: Set<CBPeripheral> = []
    public var connectedDevicesArray: [CBPeripheral] = [] // same but array
    private var doNotConnect: Set<CBPeripheral> = []
    private var statusCBUUID: CBUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8") // status characterisctic id (insert your one)
    private var serviceCDUUID: CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b") // main service id (insert your one)
    private var versionInfoCBUUID: CBUUID = CBUUID(string: "b3103938-3c4c-4330-8f56-e58c77f4b0bd")
    
    // the main characteristic in my project (you may have more)
    private var mainCharacteristic: [UUID : CBCharacteristic] = [:]
    private var infoCharacteristic: [UUID : CBCharacteristic] = [:]
    
    // shared instance for simple access from all controllers
    static let sharedInstance = BLE()
    
    required override init() {
        super.init()
        manager = CBCentralManager.init(delegate: self,
                                        queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var consoleLog = ""
        switch central.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
            manager.scanForPeripherals(withServices: .none) // you should stop scanning later
        case .resetting:
            consoleLog = "BLE is resetting"
        case .unauthorized:
            consoleLog = "BLE is unauthorized"
        case .unknown:
            consoleLog = "BLE is unknown"
        case .unsupported:
            consoleLog = "BLE is unsupported"
        default:
            consoleLog = "default"
        }
        print(consoleLog)
    }
    
    // MARK: GENERAL MANAGER's FUNCS
    
    // connection + adding to checklist
    func addToDeviceList(_ item: CBPeripheral) {
        if !(item.name?.isEmpty ?? true) && !checkList.contains(PossibleDevice(name: item.name ?? "",
                                                                               id: item.identifier)) {
            list.insert(item)
            for i in UserDefaults.standard.array(forKey: "devices") as! [String] {
                if i == "\(item.identifier)" && !doNotConnect.contains(item) {
                    if item.state != .connected {
                        connect(item: item)
                    }
                }
            }
            
            // небольшие костыли для отображения названий с индексами
            var itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                                   for: .names) ?? [:]
            print(itemsAliasDict)
            var add = true
            var counter = 0
            for i in itemsAliasDict {
                if i.value == item.name && i.key != item.identifier.uuidString {
                    counter += 1
                }
                if i.key != item.identifier.uuidString {
                    add = false
                }
            }
            
            if counter > 0 {
                
                itemsAliasDict.updateValue("\(String(describing: item.name!)) (\(counter - 1))",
                                           forKey: item.identifier.uuidString)
                UserDefaultsManager().saveObject(value: itemsAliasDict,
                                                 for: .names)
            }
            
            else if add {
                itemsAliasDict.updateValue(item.name ?? "",
                                           forKey: item.identifier.uuidString)
                UserDefaultsManager().saveObject(value: itemsAliasDict,
                                                 for: .names)
            }
            
            checkList.insert(PossibleDevice(name: item.name ?? "",
                                            id: item.identifier))
        }
    }
    
    func updateConnected(completion: @escaping ([CBPeripheral]) -> Void) {
        completion(self.connectedDevicesArray)
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        // here we check manufacturer
        // this allows you to connect only "Solnyshko" devices
        let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey]
        if let data = manufacturer  as? Data {
            let dataStr = String(data: data, encoding: .utf8)
            if dataStr != nil {
                if (dataStr!.hasPrefix("SN")) {
                    addToDeviceList(peripheral)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        checkList.remove(PossibleDevice(name: peripheral.name ?? "",
                                        id: peripheral.identifier))
        connectedDevices.remove(peripheral)
        connectedDevicesArray = connectedDevices.createArray() as! [CBPeripheral]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "lost\(peripheral.identifier)"),
                                        object: nil)
        list.remove(peripheral)
        print("lose")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                        object: nil)
    }
    
    //didConnect
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        if !connectedDevices.contains(peripheral) {
            connectedDevices.insert(peripheral)
            connectedDevicesArray = connectedDevices.createArray() as! [CBPeripheral]
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                        object: nil)
    }
    
    //didDisconnect
    private func centralManager(central: CBCentralManager!,
                                didDisconnect peripheral: CBPeripheral!,
                                error: NSError!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                        object: nil)
        print("disconnect")
    }
    internal func centralManager(_ central: CBCentralManager,
                                 didFailToConnect peripheral: CBPeripheral,
                                 error: Error?) {
        print("failToConnect")
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if characteristic != mainCharacteristic[peripheral.identifier] {
            if characteristic == infoCharacteristic[peripheral.identifier] {
                let welcome = try? JSONDecoder().decode(LampVersion.self,
                                                        from: infoCharacteristic[peripheral.identifier]?.value ?? Data())
                let peripheralName = "\(peripheral.identifier)"
                var data = UserDefaults.standard.dictionary(forKey: "versions") as! [String : String]
                data.updateValue(welcome?.version ?? "н/д",
                                 forKey: "\(peripheralName)")
            }
            else {
                peripheral.readValue(for: mainCharacteristic[peripheral.identifier]!)
            }
        }
        else {
            // here we decoding the data from lamp and save it to userDefaults
            let welcome = try? JSONDecoder().decode(Welcome.self,
                                                    from: mainCharacteristic[peripheral.identifier]?.value ?? Data())
            let peripheralName = "\(peripheral.identifier)"
            var data = UserDefaults.standard.dictionary(forKey: "timeSet") as! [String : Int]
            data.updateValue(Int((welcome?.timer.cycleTime)! / 1000), 
                             forKey: "\(peripheralName)")
            UserDefaults.standard.set(data, forKey: "timeSet")
            var data2 = UserDefaults.standard.dictionary(forKey: "cyclesSet") as! [String : Int]
            data2.updateValue(Int((welcome?.timer.cycles)!), 
                              forKey: "\(peripheralName)")
            UserDefaults.standard.set(data2, 
                                      forKey: "cyclesSet")
            if Int(welcome!.timer.cycleTime!) > 0 {
                var data3 = UserDefaults.standard.dictionary(forKey: "currentCycle") as! [String : Int]
                let cc = Int(welcome!.timer.cycles!) - Int(welcome!.timer.timeLeft!) / Int(welcome!.timer.cycleTime!)
                data3.updateValue(cc,
                                  forKey: "\(peripheralName)")
                UserDefaults.standard.set(data3,
                                          forKey: "currentCycle")
            }
            switch welcome?.state {
            case 0: notificationCenter.post(name: NSNotification.Name(rawValue: "settedOff\(peripheralName)"),
                                            object: nil)
            case 1: notificationCenter.post(name: NSNotification.Name(rawValue: "justOn\(peripheralName)"), 
                                            object: nil)
            case 2:
                var data = UserDefaults.standard.dictionary(forKey: "prehetLeft") as! [String : Int]
                data.updateValue(Int((welcome?.preheat.timeLeft ?? 0) / 1000), 
                                 forKey: "\(peripheralName)")
                UserDefaults.standard.set(data, forKey: "prehetLeft")
                notificationCenter.post(name: NSNotification.Name(rawValue: "preheat\(peripheralName)"), 
                                        object: nil)
            case 3:
                var data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
                data.updateValue(Int((welcome?.timer.timeLeft)! % (welcome?.timer.cycleTime)! / 1000), 
                                 forKey: "\(peripheralName)")
                UserDefaults.standard.set(data, forKey: "timeLeft")
                notificationCenter.post(name: NSNotification.Name(rawValue: "active\(peripheralName)"), 
                                        object: nil)
            case 4:
                var data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
                data.updateValue(Int((welcome?.timer.timeLeft)! % (welcome?.timer.cycleTime)! / 1000),
                                 forKey: "\(peripheralName)")
                UserDefaults.standard.set(data, forKey: "timeLeft")
                notificationCenter.post(name: NSNotification.Name(rawValue: "pause\(peripheralName)"),
                                        object: nil)
            case .none:
                return
            case .some(_):
                return
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == serviceCDUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "1fd32b0a-aa51-4e49-92b2-9a8be97473c9") {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == statusCBUUID {
                    mainCharacteristic[peripheral.identifier] = characteristic
                }
                if characteristic.uuid == versionInfoCBUUID {
                    infoCharacteristic[peripheral.identifier] = characteristic
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    // MARK: OTHER MANAGER's FUNCS
    func scanCompleted(completion: @escaping ([CBPeripheral]) -> Void) {
        if manager.state == .poweredOn {
            manager.stopScan() // in case we've already start scaning
            manager.scanForPeripherals(withServices: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.manager.state == .poweredOn {
                    self.manager.stopScan()
                }
                completion(self.list.createArray() as! [CBPeripheral])
            }
        }
        else {
            completion([])
        }
    }
    
    // function to start connection
    func connect(item: CBPeripheral) {
        print("connecting")
        doNotConnect.remove(item)
        var check = true
        for i in UserDefaults.standard.array(forKey: "devices") as! [String] {
            if i == "\(item.identifier)" {
                check = false
                break
            }
        }
        if check {
            var newDevicesArray = UserDefaults.standard.array(forKey: "devices") as! [String]
            newDevicesArray.append("\(item.identifier)")
            print(newDevicesArray)
            UserDefaults.standard.set(newDevicesArray,
                                      forKey: "devices")
        }
        item.delegate = self
        if item.state != .connected {
            self.manager.connect(item,
                                 options: nil)
        }
    }
    
    // forget function, useless in this project, but you can implement some functional using it
    func forget(item: CBPeripheral) {
        self.manager.cancelPeripheralConnection(item)
        var itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                               for: .names) ?? [:]
        itemsAliasDict.removeValue(forKey: item.identifier.uuidString)
        UserDefaultsManager().saveObject(value: itemsAliasDict,
                                         for: .names)
        var newDevicesArray = UserDefaults.standard.array(forKey: "devices") as! [String]
        for i in 0..<(UserDefaults.standard.array(forKey: "devices")?.count ?? 1) {
            if newDevicesArray[i] == "\(item.identifier)" {
                newDevicesArray.remove(at: i)
                UserDefaults.standard.set(newDevicesArray,
                                          forKey: "devices")
                break
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                        object: nil)
    }
    func disconnect(item: CBPeripheral) {
        self.manager.cancelPeripheralConnection(item)
        doNotConnect.insert(item)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                        object: nil)
    }
    
    // MARK: THE LAMP FUNCS
    func setOnLamp(peripheral: CBPeripheral,
                   complition: @escaping (Bool) -> Void) {
        if ((mainCharacteristic[peripheral.identifier]?.isNotifying) != nil) {
            let dataString = String("{\"relay\": 1}")
            guard let valueString = dataString.data(using: String.Encoding.utf8) else {
                complition(false)
                print("truoble")
                return
            }
            peripheral.writeValue(valueString, for: mainCharacteristic[peripheral.identifier]! , type:
                                    CBCharacteristicWriteType.withResponse)
            print("Value String===>\(valueString.debugDescription)")
            complition(true)
        }
        else {
            print("truoble")
            complition(false)
        }
    }
    // turn off the lamp
    func setOffLamp(peripheral: CBPeripheral) -> Bool {
        if ((mainCharacteristic[peripheral.identifier]?.isNotifying) != nil) {
            let dataString = String("{\"relay\": 0}")
            guard let valueString = dataString.data(using: String.Encoding.utf8) else {
                return false
            }
            peripheral.writeValue(valueString, for: mainCharacteristic[peripheral.identifier]! , type:
                                    CBCharacteristicWriteType.withResponse)
            return true
        }
        return false
    }
    func startLamp(peripheral: CBPeripheral,
                   time: Int,
                   cycles: Int,
                   complition: @escaping (Bool) -> Void) {
        if ((mainCharacteristic[peripheral.identifier]?.isNotifying) != nil) {
            let dataString = String(" {\"timer\": { \"action\" : \"set\", \"time\" : \(time), \"cycles\" : \(cycles)}}")
            guard let valueString = dataString.data(using: String.Encoding.utf8) else {
                complition(false)
                return
            }
            peripheral.writeValue(valueString, for: mainCharacteristic[peripheral.identifier]! , type:
                                    CBCharacteristicWriteType.withResponse)
            complition(true)
        }
        else {
            complition(false)
        }
    }
    func resumeLamp(peripheral: CBPeripheral,
                    complition: @escaping (Bool) -> Void) {
        if ((mainCharacteristic[peripheral.identifier]?.isNotifying) != nil) {
            let dataString = String("{\"timer\": { \"action\" : \"resume\" }}")
            guard let valueString = dataString.data(using: String.Encoding.utf8) else {
                complition(false)
                return
            }
            peripheral.writeValue(valueString, for: mainCharacteristic[peripheral.identifier]! , type:
                                    CBCharacteristicWriteType.withResponse)
            complition(true)
        }
        else {
            complition(false)
        }
    }
    func pauseLamp(peripheral: CBPeripheral,
                    complition: @escaping (Bool) -> Void) {
        if ((mainCharacteristic[peripheral.identifier]?.isNotifying) != nil) {
            let dataString = String("{\"timer\": { \"action\" : \"pause\" }}")
            guard let valueString = dataString.data(using: String.Encoding.utf8) else {
                complition(false)
                return
            }
            peripheral.writeValue(valueString, for: mainCharacteristic[peripheral.identifier]! , type:
                                    CBCharacteristicWriteType.withResponse)
            complition(true)
        }
        else {
            complition(false)
        }
    }
    func checkState(_ peripheral: CBPeripheral) {
        if mainCharacteristic[peripheral.identifier] != nil {
            peripheral.readValue(for: mainCharacteristic[peripheral.identifier]!)
        }
    }
}
