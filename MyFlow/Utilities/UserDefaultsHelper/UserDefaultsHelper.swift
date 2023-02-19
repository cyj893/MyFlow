//
//  UserDefaultsHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import Foundation


@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var container: UserDefaults = .standard

    var wrappedValue: T {
        get {
            return container.object(forKey: key) as? T ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    enum Keys: String {
        case moveStrategy = "MoveStrategy"
    }
    
    @UserDefault(key: Keys.moveStrategy.rawValue, defaultValue: MoveStrategyType.useScrollView.rawValue)
    static var moveStrategy: Int
}
