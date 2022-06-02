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

enum PdfError: Error {
    case cannotFindDocument
    case cannotFindScrollView
    case cannotFindPage
    case cannotGetScaleFactor
}
