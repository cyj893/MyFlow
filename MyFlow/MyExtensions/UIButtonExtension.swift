//
//  UIButtonExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/14.
//

import UIKit

extension UIButton {
    
    func setIconStyle(systemName: String, tintColor: UIColor = .white, forState: UIControl.State = .normal) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 0, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        self.setImage(largeBoldDoc, for: forState)
    }
    
    func toggleIconWithTransition(transitionOptions: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(
            with: self,
            duration: AnimateDuration.fast,
            options: transitionOptions,
            animations: {
                self.isSelected = !self.isSelected
            },
            completion: nil
        )
    }
}
