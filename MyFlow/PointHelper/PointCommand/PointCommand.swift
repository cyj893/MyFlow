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
    var change: [PDFAnnotation] { get }
    
    func execute()
    func undo()
}
