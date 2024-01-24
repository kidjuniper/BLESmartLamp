//
//  MainViewController+Animations.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 24.01.2024.
//

import Foundation
import UIKit

extension MainViewController {
    
    func timerLabelAnimation() {
        if !animationTimer.isValid {
            timerLabelAnimate()
            animationTimer = Timer.scheduledTimer(timeInterval: 0.7,
                                                  target: self,
                                                  selector: #selector(self.timerLabelAnimate),
                                                  userInfo: nil,
                                                  repeats: true)
            animationTimer.fire()
        }
        
    }
    @objc func timerLabelAnimate() {
        UILabel.animate(withDuration: 0.7) {
            self.centralLabel.layer.opacity = self.centralLabel.layer.opacity == 1.0 ? 0.2 : 1.0
        }
    }
    
    
    // MARK: - layer animations
    
    func animationCircularPreheat() {
        let center = CGPoint(x: shapeView.frame.width / 2,
                             y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        
        let data = UserDefaults.standard.dictionary(forKey: "prehetLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimerAnimation = Double(data[deviceName] ?? 0)
        
        shapeLayer.removeFromSuperlayer()
        
        let startAngle = 2 * CGFloat.pi * CGFloat(1 - durationTimerAnimation/60) + endAngle
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: (shapeView.frame.width - shapeView.frame.width * 0.101) / 2,
                                        startAngle: endAngle,
                                        endAngle: startAngle,
                                        clockwise: false)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = shapeView.frame.width * 0.101
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = UIColor.systemRed.cgColor
        shapeView.layer.addSublayer(shapeLayer)
    }
    
    func animationCircular() {
        let center = CGPoint(x: shapeView.frame.width / 2,
                             y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        
        let data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimerAnimation = Double(data[deviceName] ?? 0)
        
        let data2 = UserDefaults.standard.dictionary(forKey: "timeSet") as! [String : Int]
        let circleTime = Double(data2[deviceName] ?? 0)
        if durationTimerAnimation != 0 {
            let startAngle = 2 * CGFloat.pi * CGFloat(1 - (1 / circleTime + 1) - (durationTimerAnimation)/circleTime) + endAngle
            let circularPath = UIBezierPath(arcCenter: center,
                                            radius: (shapeView.frame.width - shapeView.frame.width * 0.101) / 2,
                                            startAngle: endAngle,
                                            endAngle: startAngle,
                                            clockwise: false)
            shapeLayer.path = circularPath.cgPath
            shapeLayer.lineWidth = shapeView.frame.width * 0.101
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeEnd = 1
            shapeLayer.lineCap = CAShapeLayerLineCap.round
            shapeLayer.strokeColor = UIColor.link.cgColor
            shapeView.layer.addSublayer(shapeLayer)
        }
    }
    func basicAnimation() {
        if durationTimerAnimation >= 1 {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 0
            basicAnimation.duration = CFTimeInterval(durationTimer)
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            shapeLayer.add(basicAnimation, forKey: "basicAnimation")
        }
    }
    func basicAnimationPreheat() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(durationTimer)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
}
