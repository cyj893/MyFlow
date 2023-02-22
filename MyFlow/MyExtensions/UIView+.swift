//
//  UIViewExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit

extension UIView {
    func addShadow(opacity: Float = 0.5, radius: CGFloat = 5.0) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    func addInnerShadow(opacity: Float = 0.5, radius: CGFloat = 1.0) {
        if layer.sublayers?.contains(where: { $0.name == "innerShadow" }) ?? true {
            return
        }
        
        let innerShadow = CALayer()
        innerShadow.name = "innerShadow"
        innerShadow.frame = bounds
        
        let shadowPath = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: radius, dy: radius), cornerRadius: layer.cornerRadius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: layer.cornerRadius).reversing()
        
        shadowPath.append(cutout)
        innerShadow.shadowPath = shadowPath.cgPath
        
        innerShadow.masksToBounds = true
        
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 0)
        innerShadow.shadowOpacity = opacity
        innerShadow.shadowRadius = radius
        innerShadow.cornerRadius = layer.cornerRadius
        layer.addSublayer(innerShadow)
    }
}
