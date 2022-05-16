//
//  UIFontExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit

extension UIFont {
    class func Fonarto(size: CGFloat) -> UIFont! {
        guard let font = UIFont(name: "Fonarto", size: size) else {
            return nil
        }
        return font
    }
    class func FonartoXT(size: CGFloat) -> UIFont! {
        guard let font = UIFont(name: "FonartoXT", size: size) else {
            return nil
        }
        return font
    }
    class func ComicAndy(size: CGFloat) -> UIFont! {
        guard let font = UIFont(name: "comicandy", size: size) else {
            return nil
        }
        return font
    }
}
