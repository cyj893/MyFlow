//
//  AddCommand.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import PDFKit

class AddCommand: PointCommand {
    private(set) var pointHelper: PointHelper
    private(set) var page: PDFPage
    var backup: Memento
    var change: [PDFAnnotation]
    
    init(pointHelper: PointHelper, page: PDFPage, backup: Memento, change: [PDFAnnotation]) {
        self.pointHelper = pointHelper
        self.page = page
        self.backup = backup
        self.change = change
    }
    
    // TODO: Should be able to process multiple points at once - AddpointsModalViewController
    func execute() {
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
    
    func undo() {
        pointHelper.points = backup.points
        pointHelper.linesDict = backup.linesDict
        change.forEach {
            page.removeAnnotation($0)
        }
    }
}
