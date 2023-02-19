//
//  MainViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import Foundation


protocol MainViewDelegate: NSObject {
    /// Dismiss `MainView`.
    func dismiss()
    
    /// Shows `SettingsView`.
    func showSettings()
    
    /// Starts play mode. NavigationView is hidden.
    func playModeStart()
    
    
    /// Replace the document view with the document view received as a parameter.
    ///
    /// - Parameters:
    ///   - with vc: The VC that should be shown on the screen.
    ///   - info: Tab information to update state.
    func updateDocumentView(with vc: DocumentViewController, info: DocumentTabInfo)
    
    /// Remove the document view received as a parameter if it is shown on the screen.
    func removeDocumentView(with vc: DocumentViewController)
    
#if DEBUG
    /// Display `nowIndex` in view for debugging purposes.
    func setNowIndex(with index: Int)
#endif
}
