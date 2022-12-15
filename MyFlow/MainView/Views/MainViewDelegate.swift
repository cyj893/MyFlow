//
//  MainViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import Foundation


protocol MainViewDelegate: NSObject {
    func dismiss()
    func playModeStart()
    
    func updateDocumentView(with vc: DocumentViewController)
    func removeDocumentView(with vc: DocumentViewController)
}
