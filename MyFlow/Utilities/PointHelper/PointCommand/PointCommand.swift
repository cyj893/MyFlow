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
    
    func execute()
    func undo()
    
    func concreteExecute()
    func concreteUndo()
}

extension PointCommand {
    func execute() {
        concreteExecute()
        
        pointHelper.isEdited = true
    }
    
    func undo() {
        concreteUndo()
        
        pointHelper.isEdited = true
    }
}
