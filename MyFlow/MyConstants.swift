//
//  MyConstants.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/14.
//

import UIKit

struct MyOffset {
    static let betweenIconGroup:Double = 30.0
    static let betweenIcon:Double = 15.0
    
    static let navigationViewHeight: CGFloat = 100.0
    
    static var topPadding: CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return window?.safeAreaInsets.top ?? 0
    }
}

struct AnimateDuration {
    static let fast:TimeInterval = 0.2
    static let normal:TimeInterval = 0.4
}

struct GradientColor {
    static let normal:[UIColor] = [
        UIColor(rgb: 0x769FCD, alpha: 0.5),
        UIColor(rgb: 0xB9D7EA, alpha: 0.5),
        UIColor(rgb: 0xD6E6F2, alpha: 0.5),
        UIColor(rgb: 0xF7FBFC, alpha: 0.5)
    ]

    static let selected:[UIColor] = [
        UIColor(rgb: 0xc9184a, alpha: 0.5),
        UIColor(rgb: 0xff758f, alpha: 0.5),
        UIColor(rgb: 0xffb3c1, alpha: 0.5),
        UIColor(rgb: 0xffccd5, alpha: 0.5)
    ]
}

struct MyColor {
    static let navigationBackground = UIColor(named: "navigationBackgroundColor")!
    static let secondaryNavigationBackground = UIColor(named: "secondaryNavigationBackgroundColor")!
    static let pdfBackground = UIColor(named: "pdfViewBackgroundColor")!
    static let icon = UIColor(named: "iconColor")!
    static let border = UIColor(named: "borderColor")!
    static let pageSheetBackground = UIColor(named: "pageSheetBackgroundColor")!
    static let thumbnailViewBackground = UIColor(named: "thumbnailViewBackgroundColor")!
    static let tabCell = UIColor(named: "tabCellColor")!
    static let tabCellSelected = UIColor(named: "tabCellSelectedColor")!
    static let separator = UIColor(named: "separatorColor")!
}

struct MyFont {
    static let middle = UIFont.Fonarto(size: 25)
    static let pointNum = UIFont.Fonarto(size: 20)
    
    static let sizeMiddle = "00".sizeOfString(font: middle!)
    static let sizePointNum = "012345678".sizeOfString(font: MyFont.pointNum!)
}

