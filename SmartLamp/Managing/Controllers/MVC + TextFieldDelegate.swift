//
//  MVC + TextFieldDelegate.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 30.03.2024.
//

import Foundation
import UIKit

extension ManagingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
