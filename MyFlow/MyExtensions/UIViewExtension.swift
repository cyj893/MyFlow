//
//  UIViewExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit

extension UIView {
    func addShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.shadowPath = nil
    }
}
