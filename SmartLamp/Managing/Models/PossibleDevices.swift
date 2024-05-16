//
//  PossibleDevices.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit

struct PossibleDevice: Hashable {
    let name: String
    let id: UUID
    var version: String? = "н/д"
}
