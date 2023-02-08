//
//  AddCommand.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import PDFKit

class AddCommand: PointCommand {
    private(set) var pointHelper: PointHelper
    var change: [PDFAnnotation]
    
    private(set) var page: PDFPage
    var backup: PointHelperMemento
    
    init(pointHelper: PointHelper, change: [PDFAnnotation], page: PDFPage, backup: PointHelperMemento) {
        self.pointHelper = pointHelper
        self.change = change
        self.page = page
        self.backup = backup
    }
    
    // TODO: Should be able to process multiple points at once - AddpointsModalViewController
    func concreteExecute() {
        guard let number = Int(change[0].widgetStringValue ?? "") else {
            return
        }
        pointHelper.linesDict[number] = []
        pointHelper.linesDict[number]!.append(contentsOf: change[1...])
        pointHelper.points.append(change[0])
        change.forEach {
            page.addAnnotation($0)
        }
    }
    
    func concreteUndo() {
        pointHelper.points = backup.points
        pointHelper.linesDict = backup.linesDict
        change.forEach {
            page.removeAnnotation($0)
        }
    }
}
