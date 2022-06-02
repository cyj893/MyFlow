//
//  PointCommandHistory.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

class PointCommandHistory {
    private static var stackSize = 15
    private var history: [PointCommand] = [] {
        didSet {
            count = history.count
        }
    }
    var count: Int = 0
    
    func push(_ command: PointCommand) {
        history.append(command)
        if history.count > PointCommandHistory.stackSize {
            history.removeFirst()
        }
    }
    
    func pop() -> PointCommand? {
        return history.popLast()
    }
    
    func clear() {
        history.removeAll()
    }
}
