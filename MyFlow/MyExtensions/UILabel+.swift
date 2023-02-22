//
//  UILabel+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit

extension UILabel {
    
    func setHeaderStyle() {
        font = .systemFont(ofSize: 20, weight: .bold)
        textColor = MyColor.icon
        numberOfLines = 0
        textAlignment = .left
    }
    
    func setSeconderyHeaderStyle() {
        font = .systemFont(ofSize: 18, weight: .semibold)
        textColor = MyColor.icon
        numberOfLines = 0
        textAlignment = .left
    }
    
    func setBodyStyle() {
        font = .systemFont(ofSize: 16, weight: .medium)
        textColor = MyColor.icon
        numberOfLines = 0
        textAlignment = .left
    }
}
