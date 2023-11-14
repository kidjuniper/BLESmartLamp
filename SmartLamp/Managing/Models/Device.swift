//
//  Device.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit
import CoreBluetooth

class Device {
    // MARK: Properties
    var peripheral: CBPeripheral
    var deviceAddress: UUID
    var deviceName: String
    
    // MARK: Initialization
    init(peripheral: CBPeripheral,
         deviceAddress: UUID,
         deviceName: String?) {
        self.peripheral = peripheral
        self.deviceAddress = deviceAddress
        
        if let dn = deviceName {
            self.deviceName = dn
        } else {
            self.deviceName = "no name"
        }
    }
}
