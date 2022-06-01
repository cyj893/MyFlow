//
//  PointMemento.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import UIKit
import PDFKit

protocol Memento {
    var points: [PDFAnnotation] { get }
    var linesDict:[Int:[PDFAnnotation]] { get }
}

class PointMemento: Memento {
    private(set) var points: [PDFAnnotation]
    private(set) var linesDict: [Int:[PDFAnnotation]]
    
    init(points: [PDFAnnotation], linesDict: [Int:[PDFAnnotation]]) {
        self.points = points
        self.linesDict = linesDict
    }
}
