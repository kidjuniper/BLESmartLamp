//
//  DefaultsManager.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 30.03.2024.
//

import Foundation

final class UserDefaultsManager {
    private let defaultsStandart = UserDefaults.standard
}

extension UserDefaultsManager: DefaultsManagerable {
    func deleteObject<T>(type: T.Type,
                         for key: DefaultsKeys) {
        defaultsStandart.removeObject(forKey: key.rawValue)
    }
    
    public func saveObject(value: Any,
                           for key: DefaultsKeys) {
        defaultsStandart.set(value,
            forKey: key.rawValue)
    }
    public func fetchObject<T>(type: T.Type,
                               for key: DefaultsKeys) ->T? {
        return defaultsStandart.object(forKey: key.rawValue) as? T
    }
}

protocol DefaultsManagerable {
    func saveObject(value: Any,
                    for key: DefaultsKeys)
    
    func fetchObject<T>(type: T.Type,
                        for key: DefaultsKeys) -> T?
    
    func deleteObject<T>(type: T.Type,
                         for key: DefaultsKeys)
}

enum DefaultsKeys: String {
    case names
}
