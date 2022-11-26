//
//  DocumentViewModelInterface.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

protocol DocumentViewModelInterface {
    func changeState(to state: DocumentViewState)
    
    func moveToPrevPoint()
    func moveToNextPoint()
    
    func deletePoint()
    func selectPoint(_ annotation: PDFAnnotation)
    func addPoint(_ height: Int, _ page: PDFPage)
    func clearSelectedPoint()
    
    func undo()
    func redo()
    
    func playButtonAction()
    
    func showAddPointsModalView()
    func dismiss()
}
