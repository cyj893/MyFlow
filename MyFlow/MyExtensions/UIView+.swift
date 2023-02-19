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
    
    /// Creates a shadow inside the border of the view. The view appears to be under the superView.
    ///
    /// Be sure to call it from `layoutSubviews()`. It fits the shadow layer to the view's bounds, so it should be called after the view's bounds are set.
    ///
    /// - Parameters:
    ///   - opacity: The opacity of the shadow.
    ///   - radius: The thickness of the shadow.
    func addInnerShadow(opacity: Float = 0.5, radius: CGFloat = 1.0) {
        if layer.sublayers?.contains(where: { $0.name == "innerShadow" }) ?? true {
            return
        }
        
        if bounds.width == 0 || bounds.height == 0 { return }
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
    
    static func divider(_ axis: UIAxis) -> UIView {
        let divider = UIView()
        divider.snp.makeConstraints { make in
            if axis == .horizontal {
                make.height.equalTo(1.0)
            } else {
                make.width.equalTo(1.0)
            }
        }
        divider.backgroundColor = MyColor.separator
        return divider
    }
}
