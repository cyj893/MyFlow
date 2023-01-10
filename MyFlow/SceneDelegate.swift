//
//  SceneDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity else { return }
        
        if configure(window: self.window, with: userActivity) {
            scene.userActivity = userActivity
        } else {
            print("Failed to restore DetailViewController from \(userActivity)")
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
        if let mainVC = window!.rootViewController?.presentedViewController as? MainViewController {
            print("Set scene's userActivity")
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
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

extension SceneDelegate {
    
    static var MainSceneActivityType: String {
        let activityTypes = Bundle.main.infoDictionary?["NSUserActivityTypes"] as? [String]
        return activityTypes![0]
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        guard let urls = scene.userActivity?.userInfo?["urls"] as? [URL?],
              let nowIndex = scene.userActivity?.userInfo?["nowIndex"] as? Int else {
            return scene.userActivity
        }
        print("stateRestorationActivity: \(urls.map { $0!.lastPathComponent }), \(nowIndex)")
        return scene.userActivity
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
