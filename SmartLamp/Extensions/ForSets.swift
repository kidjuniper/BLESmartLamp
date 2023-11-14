//
//  ForSets.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit

extension Set {
    func createArray() -> [Any] {
        var array: [Any] = []
        for i in self {
            array.append(i)
        }
        return array
    }
}
