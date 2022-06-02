//
//  PointHelperMemento.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/02.
//

import PDFKit

class PointHelperMemento {
    private(set) var points: [PDFAnnotation]
    private(set) var linesDict: [Int:[PDFAnnotation]]
    
    init(points: [PDFAnnotation], linesDict: [Int:[PDFAnnotation]]) {
        self.points = points
        self.linesDict = linesDict
    }
}
