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


enum TrueDepthError: Error {
    case cannotFindVideoDevice
    case cannotCreateVideoInput(Error)
    case cannotAddVideoInputToSession
    case cannotAddDepthDataOutputToSession
    case cannotLockDeviceForConfiguration(Error)
}

extension TrueDepthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cannotFindVideoDevice:
            return NSLocalizedString("Cannot find video device.", comment: "")
        case .cannotCreateVideoInput(let error):
            return NSLocalizedString("Cannot create video input: \(error.localizedDescription)", comment: "")
        case .cannotAddVideoInputToSession:
            return NSLocalizedString("Cannot add video input to the session.", comment: "")
        case .cannotAddDepthDataOutputToSession:
            return NSLocalizedString("Cannot add depth data output to the session.", comment: "")
        case .cannotLockDeviceForConfiguration(let error):
            return NSLocalizedString("Cannot lock device for configuration: \(error.localizedDescription)", comment: "")
        }
    }
}
