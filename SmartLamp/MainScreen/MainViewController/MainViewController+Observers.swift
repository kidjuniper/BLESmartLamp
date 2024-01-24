//
//  MainViewController+Observers.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    func addObservers() {
        let deviceName = "\(device!.identifier)"
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(preheatTimer),
                                                          name: NSNotification.Name(rawValue: "preheat\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(startTimer),
                                                          name: NSNotification.Name(rawValue: "active\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(pause),
                                                          name: NSNotification.Name(rawValue: "pause\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(stillOff),
                                                          name: NSNotification.Name(rawValue: "settedOff\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(justOn),
                                                          name: NSNotification.Name(rawValue: "justOn\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(lost),
                                                          name: NSNotification.Name(rawValue: "lost\(deviceName)"),
                                                          object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(check),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
}
