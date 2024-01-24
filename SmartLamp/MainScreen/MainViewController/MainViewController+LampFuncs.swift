//
//  MainViewController+LampFuncs.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    // MARK: - основные функции управления лампой
    @objc func resumeLamp() {
        BLE.sharedInstance.resumeLamp(peripheral: device!) { succes in
            if succes {
                self.shapeLayer.resumeAnimation()
                if self.durationTimer != 0 { //
                    self.animationCircular()
                    self.basicAnimation()
                }
                self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пауза",
                                                                            attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                        size: 15)!]),
                                                         for: .normal)
                self.startTimerButton.removeTarget(self,
                                                   action: #selector(self.resumeLamp),
                                                   for: .touchUpInside)
                self.startTimerButton.addTarget(self,
                                                action: #selector(self.pauseLamp),
                                                for: .touchUpInside)
            }
        }
    }
    
    @objc func pauseLamp() {
        BLE.sharedInstance.pauseLamp(peripheral: device!) { succes in
            if succes {
                self.shapeLayer.pauseAnimation()
                self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пуск",
                                                                            attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                        size: 15)!]),
                                                         for: .normal)
                self.startTimerButton.removeTarget(self,
                                                   action: #selector(self.pauseLamp),
                                                   for: .touchUpInside)
                self.startTimerButton.addTarget(self,
                                                action: #selector(self.resumeLamp),
                                                for: .touchUpInside)
            }
        }
    }
    @objc func turnOff() {
        if state != 2 {
            let alert = UIAlertController(title: "Отключить лампу?",
                                          message: "",
                                          preferredStyle: .alert)
            
            let offAction = UIAlertAction(title: "Да",
                                          style: .destructive) { _ in
                self.off()
                self.dismiss(animated: true)
            }
            let okAction = UIAlertAction(title: "Отмена",
                                         style: .default)
            alert.addAction(offAction)
            alert.addAction(okAction)
            self.present(alert,
                         animated: true)
        }
        else {
            let alert = UIAlertController(title: "Предупреждение",
                                          message: "В настоящий момент происходит нагрев и стабилизация лампы. Её отключение в течение этого периода может привести к нарушению работы устройства",
                                          preferredStyle: .alert)
            let offAction = UIAlertAction(title: "Все равно отключить",
                                          style: .destructive) { _ in
                self.off()
            }
            let okAction = UIAlertAction(title: "Отмена",
                                         style: .default)
            alert.addAction(offAction)
            alert.addAction(okAction)
            self.present(alert,
                         animated: true)
        }
    }
    
    @objc func onButtonFunc() {
        BLE.sharedInstance.setOnLamp(peripheral: device!,
                                     complition: { _ in
            self.centralLabel.layer.opacity = 1
            self.setConstraintsActiveDevice()
            self.changeFuncs()
        })
    }
    
    // MARK: - вспомогательные функции управления лампой / обработка ошибок
    func off() {
        if !BLE.sharedInstance.setOffLamp(peripheral: device!) {
            let alert1 = UIAlertController(title: "Ошибка",
                                           message: "Не удалось выключить устройство, проверьте соединение",
                                           preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alert1.addAction(okAction)
            self.present(alert1,
                         animated: true)
        }
    }
    
    @objc func lost() {
        let alert = UIAlertController(title: "Соединение потеряно",
                                      message: "Проверьте устройство и попробуйте переподключиться",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ок",
                                   style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert,
                     animated: true)
    }
}
