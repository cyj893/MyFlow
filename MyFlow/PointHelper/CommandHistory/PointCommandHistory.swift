//
//  PointCommandHistory.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

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
