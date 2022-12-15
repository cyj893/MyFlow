//
//  DocumentViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

protocol DocumentViewDelegate: NSObject {
    func setDocument(with pdfDocument: PDFDocument)
    func showAddPointsModalView(_ viewController: UIViewController)
}
