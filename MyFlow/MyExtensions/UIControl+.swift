//
//  UIControlExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping ()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
