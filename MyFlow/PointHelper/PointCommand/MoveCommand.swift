//
//  MoveCommand.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import PDFKit

class MoveCommand: PointCommand {
    private(set) var pointHelper: PointHelper
    var change: [PDFAnnotation]
    
    var backup: PointMemento
    var after: PointMemento
    
    init(pointHelper: PointHelper, change: [PDFAnnotation], backup: PointMemento, after: PointMemento) {
        self.pointHelper = pointHelper
        self.change = change
        self.backup = backup
        self.after = after
    }
    
    func execute() {
        movePoint(from: backup, to: after)
    }
    
    func undo() {
        movePoint(from: after, to: backup)
    }
    
    func movePoint(from: PointMemento, to: PointMemento) {
        if from.page != to.page {
            from.page.removeAnnotation(change[0])
            change[0].page = to.page
            to.page.addAnnotation(change[0])
            for i in 1...4 {
                from.page.removeAnnotation(change[i])
                change[i].page = to.page
                to.page.addAnnotation(change[i])
            }
        }
        
        change[0].bounds = CGRect(
            origin: CGPoint(x: 10, y: to.height - Int(MyFont.sizePointNum.height)),
            size: change[0].bounds.size)
        for i in 1...4 {
            change[i].bounds = CGRect(
                origin: CGPoint(x: 0, y: to.height - i),
                size: change[i].bounds.size)
        }
    }
}
