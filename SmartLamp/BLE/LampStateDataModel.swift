//
//  LampStateDataModel.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 05.11.2023.
//

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let state: Int
    let timer: TimerL
    let preheat: Preheat
}

// MARK: - Preheat
struct Preheat: Codable {
    let timeLeft: Int?

    enum CodingKeys: String, CodingKey {
        case timeLeft = "time_left"
    }
}

// MARK: - Timer
struct TimerL: Codable {
    let timeLeft, cycles, cycleTime: Int?

    enum CodingKeys: String, CodingKey {
        case timeLeft = "time_left"
        case cycles
        case cycleTime = "cycle_time"
    }
}
