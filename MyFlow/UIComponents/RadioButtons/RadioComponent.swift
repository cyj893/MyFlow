//
//  RadioComponent.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import UIKit


protocol RadioComponent: UIView {
    var delegate: RadioButtonDelegate? { get set }
    var id: Int { get }
    var isSelected: Bool { get set }
    
    func select()
    func deselect()
}
