//
//  UserDefaultsHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit


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
        case playModeTapAreaAxis = "PlayModeTapAreaAxis"
        case playModeTapAreaLength = "PlayModeTapAreaLength"
        case useTrueDepth = "useTrueDepth"
        case trueDepthThreshold = "trueDepthThreshold"
    }
    
    @UserDefault(key: Keys.moveStrategy.rawValue, defaultValue: MoveStrategyType.useScrollView.rawValue)
    static var moveStrategy: Int
    
    
    @UserDefault(key: Keys.playModeAutoScale.rawValue, defaultValue: false)
    static var playModeAutoScale: Bool
    
    @UserDefault(key: Keys.playModeTapAreaAxis.rawValue, defaultValue: PlayModeState.TapAreaAxis.horizontal.rawValue)
    static var playModeTapAreaAxis: Int
    
    @UserDefault(key: Keys.playModeTapAreaLength.rawValue, defaultValue: UIScreen.main.bounds.width / 2)
    static var playModeTapAreaLength: Double
    
    @UserDefault(key: Keys.useTrueDepth.rawValue, defaultValue: false)
    static var useTrueDepth: Bool
    
    @UserDefault(key: Keys.trueDepthThreshold.rawValue, defaultValue: 80.0)
    static var trueDepthThreshold: Float
    
}
