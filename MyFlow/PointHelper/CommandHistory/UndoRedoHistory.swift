//
//  UndoRedoHistory.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//


class UndoRedoHistory {
    
    let logger = MyLogger(category: String(describing: UndoRedoHistory.self))
    
    private var undoHistory = PointCommandHistory()
    private var redoHistory = PointCommandHistory()
    
    func getUndoCount() -> Int { return undoHistory.count }
    func getRedoCount() -> Int { return redoHistory.count }
    
    func executeCommand(_ command: PointCommand) {
        command.execute()
        undoHistory.push(command)
        redoHistory.clear()
        logger.log("executeCommand \(command). Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func push(_ command: PointCommand) {
        undoHistory.push(command)
        logger.log("push \(command). Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func undoCommand() {
        guard let command = undoHistory.pop() else {
            return
        }
        command.undo()
        redoHistory.push(command)
        logger.log("undoCommand \(command). Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func redoCommand() {
        guard let command = redoHistory.pop() else {
            return
        }
        command.execute()
        undoHistory.push(command)
        logger.log("redoCommand \(command). Undo: \(getUndoCount()) Redo: \(getRedoCount())")
    }
    
    func clear() {
        undoHistory.clear()
        redoHistory.clear()
    }
}
