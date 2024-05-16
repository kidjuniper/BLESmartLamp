//
//  BottomSheetLogic.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 15.05.2024.
//

import Foundation
import UIKit

extension ManagingViewController {
    public func setupPanGesture(for view: UIView?) {
        guard let view = view else { return }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panRecognizer)
        
    }
    
    @objc
    public func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .ended:
            processPanGestureEnded(panGesture)
        default:
            break
        }
    }
    
    public func processPanGestureEnded(_ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: bottomSheetView)
        let translation = panGesture.translation(in: bottomSheetView)
        endInteractiveTransition(verticalVelocity: velocity.y,
                                 verticalTranslation: translation.y)
    }
    
    public func endInteractiveTransition(verticalVelocity: CGFloat, verticalTranslation: CGFloat) {
        let deceleration = 800.0 * (verticalVelocity > 0 ? 1.0 : -1.0)
        let finalProgress = -(verticalTranslation - 0.5 * verticalVelocity * verticalVelocity / CGFloat(deceleration))
        / bottomSheetView.bounds.height
        
        endInteractiveTransition(finalProgress: finalProgress)
    }
    
    public func endInteractiveTransition(finalProgress: Double) {
        if finalProgress > 0 {
            UIView.animate(withDuration: 0.15) {
                self.centerYConstraint!.constant = 360
                self.view.layoutIfNeeded()
            }
        }
        else {
            UIView.animate(withDuration: 0.15) {
                self.centerYConstraint!.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
