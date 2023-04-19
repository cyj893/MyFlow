//
//  DrawingTool.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//


enum DrawingTool {
    case pen
    case highlighter
    case eraser
    
    var icon: String {
        switch self {
        case .pen:
            return "pencil.line"
        case .highlighter:
            return "highlighter"
        case .eraser:
            return "eraser.line.dashed"
        }
    }
}
