//
//  lastProtocol.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 27.09.2023.
//

import Foundation
import UIKit
import CoreBluetooth

protocol Forget {
    func forget(item: CBPeripheral)
}
protocol Connecttions {
    func disconnect(item: CBPeripheral)
    func connect(item: CBPeripheral)
    func reload() // for table view
}
