//
//  AlertMaker.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/22.
//

import UIKit


final class AlertMaker {
    static func showAlert(_ alertController: UIAlertController) {
        UIApplication.getTopViewController()?.present(alertController, animated: true)
    }
    
    static func trueDepthAlert() -> UIAlertController {
        let message = "MyFlow doesn't have permission to use the camera.\nPlease change privacy settings and retry it."
        let alertController = UIAlertController(title: "Camera Permission", message: message, preferredStyle: .alert)
        alertController
            .addAction(UIAlertAction(title: "Cancel",
                                     style: .cancel,
                                     handler: nil))
        alertController
            .addAction(UIAlertAction(title: "Settings",
                                     style: .default,
                                     handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
        }))
        return alertController
    }
    
    static func trueDepthConfigurationFailAlert() -> UIAlertController {
        let message = "Failed to configure TrueDepth camera."
        let alertController = UIAlertController(title: "Cannot move to next point with head bowing", message: message, preferredStyle: .alert)
        alertController
            .addAction(UIAlertAction(title: "Ok",
                                     style: .cancel,
                                     handler: nil))
        return alertController
    }
}
