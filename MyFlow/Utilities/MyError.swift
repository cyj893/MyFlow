//
//  MyError.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/19.
//

import Foundation

enum PointError: Error {
    case emptyPoints
    case indexOutOfRange
}

extension PointError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyPoints:
            return NSLocalizedString("Points array is empty", comment: "")
        case .indexOutOfRange:
            return NSLocalizedString("Points array's index is out of range.", comment: "")
        }
    }
}


enum PdfError: Error {
    case cannotFindDocument
    case cannotFindScrollView
    case cannotFindPage
}

extension PdfError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cannotFindDocument:
            return NSLocalizedString("Cannot find document from PDFView.", comment: "")
        case .cannotFindScrollView:
            return NSLocalizedString("Cannot find scrollView from PDFView.", comment: "")
        case .cannotFindPage:
            return NSLocalizedString("Cannot find page from PDFView.", comment: "")
        }
    }
}
