//
//  DynamicUserDefaults.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import Foundation


struct DynamicUserDefaults {
    enum Keys: String {
        case toolColorSetting = "toolColorSetting"
        case toolColorSelectedIndexSetting = "toolColorSelectedIndexSetting"
        case toolColorwellSetting = "toolColorwellSetting"
        case toolWidthSetting = "toolWidthSetting"
        case toolOpacitySetting = "toolOpacitySetting"
    }
    
    static var toolColorSetting = DynamicUserDefault<Int>(key: Keys.toolColorSetting.rawValue, defaultValue: 0)
    static var toolColorSelectedIndexSetting = DynamicUserDefault<Int>(key: Keys.toolColorSelectedIndexSetting.rawValue, defaultValue: 0)
    static var toolColorwellSetting = DynamicUserDefault<Int>(key: Keys.toolColorwellSetting.rawValue, defaultValue: 0)
    
    static var toolWidthSetting = DynamicUserDefault<Int>(key: Keys.toolWidthSetting.rawValue, defaultValue: 8)
    
    static var toolOpacitySetting = DynamicUserDefault<Double>(key: Keys.toolOpacitySetting.rawValue, defaultValue: 0.3)
    
}

struct DynamicUserDefault<T> {
    let key: String
    let defaultValue: T
    
    var container: UserDefaults = .standard

    func get(_ id: Int) -> T {
        return container.object(forKey: "\(key)_\(id)") as? T ?? defaultValue
    }
    
    func set(_ id: Int, _ newValue: T) {
        container.set(newValue, forKey: "\(key)_\(id)")
    }
}
