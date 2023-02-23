//
//  UIApplication+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/23.
//

import UIKit


extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    class func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let naviController = baseVC as? UINavigationController {
            return getTopViewController(base: naviController.visibleViewController)
        } else if let tabBarController = baseVC as? UITabBarController,
                  let selected = tabBarController.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = baseVC?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return baseVC
    }
}
