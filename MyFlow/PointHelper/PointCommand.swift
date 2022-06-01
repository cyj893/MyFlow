//
//  PointMemento.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import UIKit
import PDFKit

protocol PointCommand {
    var pointHelper: PointHelper { get }
    var page: PDFPage { get }
    var backup: Memento { get }
    var change: [PDFAnnotation] { get }
    
    func execute()
    func undo()
}

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

class PointCommandHistory {
    private var history: [PointCommand] = [] {
        didSet {
            count = history.count
        }
    }
    var count: Int = 0
    
    func push(_ command: PointCommand) {
        history.append(command)
    }
    
    func pop() -> PointCommand? {
        return history.popLast()
    }
}

class UndoRedoHistory {
    private var undoHistory = PointCommandHistory()
    private var redoHistory = PointCommandHistory()
    
    func getUndoCount() -> Int { return undoHistory.count }
    func getRedoCount() -> Int { return redoHistory.count }
    
    func executeCommand(_ command: PointCommand) {
        command.execute()
        undoHistory.push(command)
        print("executeCommand Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func undoCommand() {
        guard let command = undoHistory.pop() else {
            return
        }
        command.undo()
        redoHistory.push(command)
        print("undoCommand Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func redoCommand() {
        guard let command = redoHistory.pop() else {
            return
        }
        command.execute()
        undoHistory.push(command)
        print("redoCommand Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
}
