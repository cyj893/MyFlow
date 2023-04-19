//
//  CALayer+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import UIKit


extension CALayer {
    func offsetBorder(frame: CGRect? = nil, borderOffset: CGFloat = 5.0, borderColor: UIColor = MyColor.border, borderWidth: CGFloat = 2.0, cornerRadius: CGFloat = 0.0) {
        let frame = frame ?? self.frame
        let offsetBorder = CALayer()
        offsetBorder.frame = CGRect(x: -borderOffset, y: -borderOffset, width: frame.size.width + 2 * borderOffset, height: frame.size.height + 2 * borderOffset)
        offsetBorder.cornerRadius = cornerRadius
        offsetBorder.borderColor = borderColor.cgColor
        offsetBorder.borderWidth = borderWidth
        offsetBorder.name = "offsetBorder"
        insertSublayer(offsetBorder, at: 0)
    }
}
