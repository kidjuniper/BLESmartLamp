//
//  MainViewController+StateHandlerFuncs.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    @objc func check() {
        BLE.sharedInstance.checkState(device!)
    }
    
    @objc func stillOff() {
        state = 0
        timer.invalidate()

        // some appearance moments
        setTimerButtonToStartMode()
        shapeLayer.removeFromSuperlayer()
        setOnOffButtonTitle()
        centralLabel.text = "Устройство готово"
        timerLabelAnimation()
    }
    
    @objc func justOn() {
        state = 1
        firstOpen = true
        setTimerButtonToStartMode()

        // some appearance moments
        centralLabel.text = "Устройство включено"
        centralLabel.layer.opacity = 1
        setOnOffButtonTitle()
    }
    
    @objc func preheatTimer() {
        if state == 2 {
            isResumed = true
        }
        state = 2

        // update timer for animations & central label info
        let data = UserDefaults.standard.dictionary(forKey: "prehetLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimer = data[deviceName] ?? 0
        
        // shape layer animations
        basicAnimationPreheat()
        animationCircularPreheat()
        timerFuncPreheat()
        
        timer.invalidate() // if we've already start timer
        timer = Timer.scheduledTimer (timeInterval: 1,
                                      target: self,
                                      selector: #selector (self.timerFuncPreheat),
                                      userInfo: nil,
                                      repeats: true)
        
        // some appearance moments
        setOnOffButtonTitle()
        setConstraintsActiveDevice()
    }
    
    @objc func startTimer() {
        setConstraintsActiveDevice()
        startTimerButton.removeTarget(self,
                                      action: #selector(startButtonTapped),
                                      for: .touchUpInside)
        timer.invalidate() // if we've already start timer
        if durationTimer == 0 {
            isResumed = false
        }
        if state == 3 {
            isResumed = true
        }
        state = 3
        let data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        
        // update timer for animations & central label info
        durationTimer = data[deviceName] ?? 0
        if !isResumed {
            animationCircular()
            self.basicAnimation()
        }
        timerFunc()
        isResumed = false
        timer = Timer.scheduledTimer (timeInterval: 1,
                                      target: self,
                                      selector: #selector (self.timerFunc),
                                      userInfo: nil,
                                      repeats: true)
        
        // some appearance moments
        startTimerButton.isHidden = false
        setTimerButtonToPauseOffMode()
        setOnOffButtonTitle()
    }
    
    @objc func pause() {
        state = 4
        setConstraintsActiveDevice()
        isResumed = true
        if firstOpen {
            let deviceName = "\(device!.identifier)"
            let data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
            durationTimer = data[deviceName] ?? 0
            updateCentralLabelTextWithCurrectTimeLefted()
        }
        timer.invalidate()
        shapeLayer.pauseAnimation()
        
        // some appearance moments
        setOnOffButtonTitle()
        setTimerButtonToContinueMode()
    }
    
    // MARK: -  helpers functions:

    // основная функция для таймера
    @objc func timerFunc() {
        updateCentralLabelTextWithCurrectTimeLefted()
        if durationTimer > 0 {
            durationTimer -= 1
        }
        else {
            isResumed = false
            timer.invalidate()
            shapeView.layer.sublayers?.first?.removeFromSuperlayer()
        }
    }
    // функция для таймера при прогреве
    @objc func timerFuncPreheat() {
        centralLabel.text = """
Идет прогрев устройства
Осталось \(Int(durationTimer/60)) : \(durationTimer%60 > 9 ? "\(durationTimer%60)" : "0\(durationTimer%60)")
"""
        if durationTimer > 0 {
            durationTimer -= 1
        }
        else {
            timer.invalidate()
            shapeView.layer.sublayers?.first?.removeFromSuperlayer()
        }
        startTimerButton.isHidden = true
    }
}
