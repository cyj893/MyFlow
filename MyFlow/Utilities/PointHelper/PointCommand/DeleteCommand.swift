//
//  DeleteCommand.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/21.
//

import PDFKit

class DeleteCommand: PointCommand {
    private(set) var pointHelper: PointHelper
    var backup: PointInstanceMemento
    
    init(pointHelper: PointHelper, backup: PointInstanceMemento) {
        self.pointHelper = pointHelper
        self.backup = backup
    }
    
    func execute() {
        guard let number = Int(backup.change[0].widgetStringValue ?? "") else {
            return
        }
        pointHelper.points.remove(at: number-1)
        pointHelper.linesDict[number] = []
        guard let page = backup.change[0].page else {
            return
        }
        backup.change.forEach {
            page.removeAnnotation($0)
        }
        
        for i in number-1..<pointHelper.points.count {
            pointHelper.points[i].widgetStringValue = String(i+1)
            pointHelper.linesDict[i+1] = []
            let lines = pointHelper.linesDict[i+2] ?? []
            pointHelper.linesDict[i+1]?.append(contentsOf: lines)
        }
    }
    
    func undo() {
        guard let number = Int(backup.change[0].widgetStringValue ?? "") else {
            return
        }
        for i in stride(from: pointHelper.points.count-1, through: number-1, by: -1) {
            pointHelper.points[i].widgetStringValue = String(i+2)
            pointHelper.linesDict[i+2] = []
            let lines = pointHelper.linesDict[i+1] ?? []
            pointHelper.linesDict[i+2]?.append(contentsOf: lines)
        }
        
        pointHelper.linesDict[number] = []
        pointHelper.linesDict[number]!.append(contentsOf: backup.change[1...])
        pointHelper.points.insert(backup.change[0], at: number-1)
        guard let page = backup.change[0].page else {
            return
        }
        backup.change.forEach {
            page.addAnnotation($0)
        }
    }
}
