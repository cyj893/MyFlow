//
//  MainViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//


protocol MainViewDelegate {
    func dismiss()
    func playModeStart()
    
    func updateDocumentView(with vc: DocumentViewController, index: Int)
    func removeDocumentView(with vc: DocumentViewController)
}
