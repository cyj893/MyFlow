//
//  SceneDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let logger = MyLogger(category: String(describing: SceneDelegate.self))
    

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity else { return }
        
        if configure(window: self.window, with: userActivity) {
            scene.userActivity = userActivity
        } else {
            logger.log("Failed to restore from \(userActivity)", .info)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        MainViewModel.shared.savePointsInfos()
        
        if let mainVC = window!.rootViewController?.presentedViewController as? MainViewController {
            logger.log("sceneWillResignActive: Set scene's userActivity")
            scene.userActivity = mainVC.mainViewUserActivity
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
        MainViewModel.shared.savePointsInfos()
    }


}

extension SceneDelegate {
    
    static var MainSceneActivityType: String {
        let activityTypes = Bundle.main.infoDictionary?["NSUserActivityTypes"] as? [String]
        return activityTypes![0]
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        logStateRestorationActivity(scene.userActivity)
        return scene.userActivity
    }
    
    private func logStateRestorationActivity(_ activity: NSUserActivity?) {
        guard let activity = activity else {
            logger.log("Fail to get userActivity", .info)
            return
        }
        
        guard let urls = activity.userInfo?["urls"] as? [URL?],
              let xOffsets = activity.userInfo?["xOffsets"] as? [CGFloat],
              let yOffsets = activity.userInfo?["yOffsets"] as? [CGFloat],
              let scaleFactors = activity.userInfo?["scaleFactors"] as? [CGFloat],
              let nowIndex = activity.userInfo?["nowIndex"] as? Int else {
            logger.log("Fail to get userActivity's userInfo", .info)
            return
        }
        
        logger.log("stateRestorationActivity: urls - \(urls.map { $0!.lastPathComponent }), xOffsets - \(xOffsets), yOffsets - \(yOffsets), scaleFactors - \(scaleFactors), nowIndex - \(nowIndex)")
    }
    
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController {
            let mainVC = MainViewController()
            mainVC.modalPresentationStyle = .fullScreen
            documentBrowserViewController.present(mainVC, animated: false)
            mainVC.restoreUserActivityState(activity)
            return true
        }
        return false
    }
}
