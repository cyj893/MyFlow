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
        case playModeAutoScale = "PlayModeAutoScale"
    }
    
    @UserDefault(key: Keys.moveStrategy.rawValue, defaultValue: MoveStrategyType.useScrollView.rawValue)
    static var moveStrategy: Int
    
    
    @UserDefault(key: Keys.playModeAutoScale.rawValue, defaultValue: false)
    static var playModeAutoScale: Bool
}
