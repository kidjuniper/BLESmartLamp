//
//  MainViewController+Appearance.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    func setStartedAppearance() {
        setConstraints()
        timerLabelAnimation()
        view.backgroundColor = .systemBackground
        let itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                               for: .names) ?? [:]
        
        if let a = itemsAliasDict[device?.identifier.uuidString ?? "sdfsdfsdf"] {
            deviceNameLabel.text = a
        }
        else {
            deviceNameLabel.text = device?.name
        }
        
    }
    
    func setConstraintsActiveDevice() {
        [startTimerButton, onOffButton].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            startTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startTimerButton.topAnchor.constraint(equalTo: shapeView.bottomAnchor,
                                                  constant: 80),
            startTimerButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: 0.85),
            startTimerButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                     multiplier: 0.15),
            
            onOffButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onOffButton.topAnchor.constraint(equalTo: startTimerButton.bottomAnchor,
                                             constant: 10),
            onOffButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                               multiplier: 0.8),
            onOffButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                multiplier: 0.15)
        ])
    }
    func setConstraints() {
        let de = UILabel()
        de.backgroundColor = .black
        de.layer.cornerRadius = 4
        de.clipsToBounds = true
        
        [deviceNameLabel, centralLabel, shapeView, de].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            de.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            de.widthAnchor.constraint(equalTo: view.widthAnchor,
                                      multiplier: 0.2),
            de.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            de.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.02),
            
            shapeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shapeView.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                               constant: -50),
            shapeView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                             multiplier: 0.8),
            shapeView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.8),
            
            centralLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centralLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                constant: -50),
            centralLabel.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.6),
            
            deviceNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceNameLabel.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: 0.15),
            deviceNameLabel.topAnchor.constraint(equalTo: de.bottomAnchor,
                                                 constant: 20)
        ])
        
        setConstraintsActiveDevice()
    }
    
    func updateCentralLabelTextWithCurrectTimeLefted() {
        let data = UserDefaults.standard.dictionary(forKey: "cyclesSet") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        let cycles = Double(data[deviceName] ?? 0)
        let data2 = UserDefaults.standard.dictionary(forKey: "currentCycle") as! [String : Int]
        let currentCycle = Double(data2[deviceName] ?? 0)
        centralLabel.text = """
        Процедура \(Int(currentCycle))/\(Int(cycles))
        Осталось \(Int(durationTimer/60)) : \(durationTimer%60 > 9 ? "\(durationTimer%60)" : "0\(durationTimer%60)")
        """
    }
}
