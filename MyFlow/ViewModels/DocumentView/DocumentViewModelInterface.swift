//
//  DocumentViewModelInterface.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

protocol DocumentViewModelInterface: NSObject {
    /// Changes the state.
    ///
    /// - Parameter to state: the state to move to.
    func changeState(to state: DocumentViewState)
    
    /// Moves to the previous point from the present.
    func moveToPrevPoint()
    
    /// Moves to the next point from the present.
    func moveToNextPoint()
    
    /// Returns the number of the current point.
    func getNowPointNum() -> Int
    
    
    /// Delete the point currently selected due to selectPoint().
    func deletePoint()
    
    /// Make the point selected.
    ///
    /// - Parameter annotation: the point to select.
    func selectPoint(_ annotation: PDFAnnotation)
    
    /// Create a new point on the page. New points are numbered in ascending order.
    ///
    /// - Parameters:
    ///   - height: Height position to add to at PDFPage.
    ///   - page: A PDFPage to add point annotations to.
    func addPoint(_ height: Int, _ page: PDFPage)
    
    /// Deselect the currently selected point.
    func clearSelectedPoint()
    
    /// Undo adding, moving, or deleting points performed before.
    ///
    /// That stack has a size limit, so nothing may happen when you undo.
    ///
    func undo()
    
    /// Redo adding, moving, or deleting points that were canceled.
    ///
    /// That stack has a size limit, so nothing may happen when you redo.
    func redo()
    
    
    /// After moving to the first point, switch the current state to `PlayModeState`.
    func playButtonAction()
    /// Opens a modal view that can be added on a per-point page basis.
    func showAddPointsModalView()
}
