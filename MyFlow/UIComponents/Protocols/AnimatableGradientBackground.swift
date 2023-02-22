//
//  AnimatableGradientBackground.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit


protocol AnimatableGradientBackground {
    var gradientLayer: CAGradientLayer { get }
    
    func setGradientLayer(colors: [CGColor])
    func animateGradient(toColors: [CGColor])
}

extension AnimatableGradientBackground {
    func setGradientLayer(colors: [CGColor] = [UIColor(rgb: 0x787FF6).cgColor,
                                               UIColor(rgb: 0x4ADEDE).cgColor]) {
        gradientLayer.colors = colors
        gradientLayer.opacity = 0.3
    }
    
    func animateGradient(toColors: [CGColor] = [UIColor(rgb: 0x1CA7EC).cgColor,
                                                UIColor(rgb: 0xFF9190).cgColor]) {
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.toValue = toColors
        colorAnimation.duration = 5
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        gradientLayer.add(colorAnimation, forKey: "colors")
    }
}
