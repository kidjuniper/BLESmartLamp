//
//  MainViewController+ChangingButtonAppearanceNFunctionality.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    // MARK: - onOffButton
    // обновляем вид и функционал кнопки вкл/выкл
    func changeFuncs() {
        if onOffButton.titleLabel?.text == " Выключить" {
            setOnOffButtonToOn()
        }
        else {
            setOnOffButtonToOff()
        }
    }
    
    // устанавливаем вид и функционал кнопки вкл/выкл в зависимости от состояния
    func setOnOffButtonTitle() {
        if state == 0 {
            setOnOffButtonToOn()
        }
        else {
            setOnOffButtonToOff()
        }
    }
    
    private func setOnOffButtonToOn() {
        onOffButton.removeTarget(self,
                                      action: #selector(turnOff),
                                      for: .touchUpInside)
        onOffButton.addTarget(self,
                              action: #selector(onButtonFunc),
                              for: .touchUpInside)
        onOffButton.setAttributedTitle(NSAttributedString(string: " Включить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!,
                                                                  .foregroundColor : UIColor.systemRed]),
                                       for: .normal)
    }
    
    private func setOnOffButtonToOff() {
        onOffButton.removeTarget(self,
                                      action: #selector(onButtonFunc),
                                      for: .touchUpInside)
        onOffButton.addTarget(self,
                              action: #selector(turnOff),
                              for: .touchUpInside)
        onOffButton.setAttributedTitle(NSAttributedString(string: " Выключить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!,
                                                                  .foregroundColor : UIColor.systemRed]),
                                       for: .normal)
    }
    // MARK: - timerButton
    
    func setTimerButtonToStartMode() {
        startTimerButton.removeTarget(self,
                                      action: #selector(resumeLamp),
                                      for: .touchUpInside)
        startTimerButton.addTarget(self,
                                   action: #selector(startButtonTapped),
                                   for: .touchUpInside)
        startTimerButton.setAttributedTitle(NSAttributedString(string: "Таймер",
                                                               attributes: [.font : UIFont(name: "Futura Bold",
                                                                                           size: 15)!]),
                                            for: .normal)
    }

    func setTimerButtonToPauseOffMode() {
        self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пауза",
                                                                    attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                size: 15)!]),
                                                 for: .normal)
        startTimerButton.tintColor = .white
        startTimerButton.removeTarget(self,
                                      action: #selector(self.resumeLamp),
                                      for: .touchUpInside)
        startTimerButton.removeTarget(self,
                                      action: #selector(self.startButtonTapped),
                                      for: .touchUpInside)
        startTimerButton.addTarget(self,
                                   action: #selector(self.pauseLamp),
                                   for: .touchUpInside)
    }
    
    func setTimerButtonToContinueMode() {
        startTimerButton.setAttributedTitle(NSAttributedString(string: "Пуск",
                                                               attributes: [.font : UIFont(name: "Futura Bold",
                                                                                           size: 15)!]),
                                            for: .normal)
        startTimerButton.removeTarget(self,
                                      action: #selector(self.startButtonTapped),
                                      for: .touchUpInside)
        startTimerButton.addTarget(self,
                                   action: #selector(resumeLamp),
                                   for: .touchUpInside)
    }
    
    @objc func startButtonTapped() {
        let mainScreen = TimerPopUpViewController()
        mainScreen.device = device
        mainScreen.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(mainScreen,
                         animated: false)
        }
    }
}

