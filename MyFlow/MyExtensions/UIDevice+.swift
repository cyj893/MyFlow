//
//  UIDeviceExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/26.
//

import UIKit

extension UIDevice {
    public var isiPhone: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }
        return false
    }
    public var isiPad: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
}
