//
//  UndoRedoHistory.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//


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
