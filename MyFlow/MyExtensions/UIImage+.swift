//
//  UIImage+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit

extension UIImage {
    static func withIconStyle(systemName: String, tintColor: UIColor = MyColor.icon, weight: UIImage.SymbolWeight = .bold, scale: UIImage.SymbolScale = .large) -> UIImage? {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 0, weight: weight, scale: scale)
        return UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
    }
}
