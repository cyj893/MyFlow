//
//  DocumentViewStateInterface.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

enum DocumentViewState {
    case normal
    case hideNavi
    case handlePoints
    case addPoints
    case playMode
}

protocol DocumentViewStateInterface {
    func tapProcess(location: CGPoint, pdfView: PDFView)
}