//
//  MainViewModelInterface.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/12/15.
//


protocol MainViewModelInterface {
    func openDocument(_ vc: DocumentViewController)
    func getNowDocumentViewController() -> DocumentViewController?
    func changeCurrentDocumentState(to state: DocumentViewState)
}
