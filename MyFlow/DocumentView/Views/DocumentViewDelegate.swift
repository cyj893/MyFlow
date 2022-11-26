//
//  DocumentViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

protocol DocumentViewDelegate {
    func setDocument(with pdfDocument: PDFDocument)
    func hideNavi()
    func showNavi()
    func hideEndPlayModeButton()
    func showEndPlayModeButton()
    func showAddPointsModalView(_ viewController: UIViewController)
    func dismiss()
}
