//
//  PresentPopUp.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 30.03.2024.
//

import Foundation
import UIKit

extension UIView {
    func presentPopUp(popUp: PopUp) {
        if let popUp = viewWithTag(1) {
            popUp.removeFromSuperview()
        }
        popUp.tag = 1
        
        self.addSubview(popUp)
        popUp.clipsToBounds = true
        popUp.centerConstraint = popUp.centerXAnchor.constraint(equalTo: self.centerXAnchor,
                                                                constant: -(self.bounds.width + popUp.bounds.width) / 2)
        popUp.centerConstraint?.isActive = true
        popUp.centerYAnchor.constraint(equalTo: self.centerYAnchor,
                                       constant: -50).isActive = true
        popUp.translatesAutoresizingMaskIntoConstraints = false
        popUp.widthAnchor.constraint(equalTo: self.widthAnchor,
                                     multiplier: 0.9).isActive = true

        popUp.heightAnchor.constraint(equalTo: self.widthAnchor,
                                          multiplier: 0.5).isActive = true
        self.layoutIfNeeded()
        
        popUp.layer.masksToBounds = false
        popUp.layer.shadowColor = UIColor.black.cgColor
        popUp.layer.shadowRadius = 10
        popUp.layer.shadowOpacity = 0.5
        
        UIView.animate(withDuration: 0.15) {
            popUp.centerConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    @objc func removePopUP() {
        guard let popUp = viewWithTag(1) as? PopUp else {
            return
        }
        removePopUp(popUp: popUp)
    }
    
    func removePopUp(popUp: PopUp) {
        UIView.animate(withDuration: 0.35, animations: {
            popUp.centerConstraint?.constant =  -(self.bounds.width + popUp.bounds.width) / 2
            self.layoutIfNeeded()
        }) { _ in
            popUp.removeFromSuperview()
        }
    }
}
