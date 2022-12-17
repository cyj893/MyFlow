//
//  DocumentViewStateInterface.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

enum DocumentViewState {
    case normal
    case handlePoints
    case addPoints
    case playMode
}

protocol DocumentViewStateInterface {
    var state: DocumentViewState { get }
    func tapProcess(location: CGPoint, pdfView: PDFView)
    func completion(next: DocumentViewState)
}
