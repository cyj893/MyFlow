//
//  MyError.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/19.
//

import Foundation

enum PointError: Error {
    case emptyPoints
}

enum PdfError: Error {
    case emptyDocument
    case cannotFindScrollView
}
