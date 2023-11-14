//
//  CALayerAnimation.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 07.11.2023.
//

import Foundation
import UIKit    

extension CALayer
   {
       func pauseAnimation() {
           if isPaused() == false {
               let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
               speed = 0.0
               timeOffset = pausedTime
           }
       }

       func resumeAnimation() {
           if isPaused() {
               let pausedTime = timeOffset
               speed = 1.0
               timeOffset = 0.0
               beginTime = 0.0
               let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
               beginTime = timeSincePause
           }
       }

       func isPaused() -> Bool {
           return speed == 0
       }
   }


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
