//
//  AnotationHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit
import PDFKit

/// Manages point annotations.
///
/// Do add and move operations for points from `PDFView`.
/// Returns the point annotation in now order.
class PointHelper {
    
    // MARK: Properties
    
    var commandHistory = UndoRedoHistory()
    
    /// Added points to pdf.
    var points:[PDFAnnotation] = []
    /// (number: line annotations) dictionary  to find easily based on point number.
    var linesDict:[Int:[PDFAnnotation]] = [:]
    /// Currently located point's index.
    private var idx:Int = 0
    
    /// Current point number annotation selected by user.
    var nowSelectedPoint:PDFAnnotation?
    /// Current point line annotations selected by user.
    var nowSelectedPointLines:[PDFAnnotation] = []
    
    /// The object that actually builds the point annotaion groups when user add it.
    let pointBuilder = PointBuilder()
    
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    func getNowSelectedPoint() -> PDFAnnotation? { nowSelectedPoint }
        
    func createMemento() -> PointMemento {
        return PointMemento(points: points, linesDict: linesDict)
    }
    
    func undo() {
        commandHistory.undoCommand()
    }
    
    func redo() {
        commandHistory.redoCommand()
    }
    
}


// MARK: Move to Point

extension PointHelper {
    
    /// Move to previous point and return the point number annotation.
    ///
    /// - Returns:Previous point number annotation from now.
    func moveToPrev() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    /// Move to next point and return the point number annotation.
    ///
    /// - Returns:Next point number annotation from now.
    func moveToNext() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
    /// Move to point at index and return the point number annotation.
    ///
    /// - Returns:Point number annotation at index.
    func moveToPoint(at index: Int) throws -> PDFAnnotation {
        print(points.count)
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        guard 0 <= index && index < points.count else {
            throw PointError.indexOutOfRange
        }
        idx = index
        return points[idx]
    }
    
}


// MARK: Select and Move Point

extension PointHelper {
    
    /// Changes the color of gradient line annotations of the point number the user pressed.
    ///
    /// If the user's selection already exists, the previously selected one is replaced with a new one.
    ///
    /// - Parameter annotation: point number annotation the user pressed.
    func selectPoint(_ annotation: PDFAnnotation) {
        if nowSelectedPoint != nil {
            if nowSelectedPoint == annotation {
                clearSelectedPoint()
                return
            }
            clearSelectedPoint()
        }
        
        nowSelectedPoint = annotation
        guard let str:String = annotation.widgetStringValue else { return }
        let number = Int(str)!
        print(number)
        
        nowSelectedPointLines = linesDict[number]!
        for i in 0...3 {
            nowSelectedPointLines[i].color = GradientColor.selected[i]
        }
    }
    
    /// Moves point annnotaions to new location.
    ///
    /// - Parameters:
    ///   - height: Height position to move to at PDFPage.
    ///   - page: A PDFPage to move point annotations to. It may or may not be the same as before.
    func movePoint(_ height: Int, _ page: PDFPage) {
        guard let nowSelectedPoint = nowSelectedPoint else { return }
        
        if height < 0 {
            return
        }
        // set height bound
        if page.pageRef?.pageNumber == 1 {
            let pageSize = page.bounds(for: PDFDisplayBox.mediaBox).size
            print(pageSize.height)
            if height > Int(pageSize.height) {
                return
            }
        }
        
        checkAndMoveToNewPage(nowSelectedPoint, page)
        
        nowSelectedPoint.bounds = CGRect(
            origin: CGPoint(x: 10, y: height - Int(MyFont.sizePointNum.height)),
            size: nowSelectedPoint.bounds.size)
        for i in 0...3 {
            nowSelectedPointLines[i].bounds = CGRect(
                origin: CGPoint(x: 0, y: height - i),
                size: nowSelectedPointLines[i].bounds.size)
        }
    }
    
    /// If user moves point annnotaions to another page, delete them from before page and add them to new page.
    ///
    /// - Parameters:
    ///   - nowSelectedPoint: point number annotation the user pressed.
    ///   - page: A new PDFPage to move point annotations to.
    fileprivate func checkAndMoveToNewPage(_ nowSelectedPoint: PDFAnnotation, _ page: PDFPage) {
        if let beforePage = nowSelectedPoint.page, beforePage != page {
            beforePage.removeAnnotation(nowSelectedPoint)
            nowSelectedPoint.page = page
            page.addAnnotation(nowSelectedPoint)
            for i in 0...3 {
                beforePage.removeAnnotation(nowSelectedPointLines[i])
                nowSelectedPointLines[i].page = page
                page.addAnnotation(nowSelectedPointLines[i])
            }
        }
    }
    
    /// Clear `nowSelectedPoint` and `nowSelectedPointLines` if there is the selected point before.
    func clearSelectedPoint() {
        if nowSelectedPoint == nil { return }
        for i in 0...3 {
            nowSelectedPointLines[i].color = GradientColor.normal[i]
        }
        nowSelectedPoint = nil
        nowSelectedPointLines = []
    }
    
}


// MARK: Add Point

extension PointHelper {
    
    /// Adds point annotaion at specific height and page.
    ///
    /// - Parameters:
    ///     - height: Height position at PDFPage.
    ///     - page: PDFPage to make point annotation.
    func addPoint(_ height: Int, _ page: PDFPage) {
        let number:Int = getPointsCount() + 1
        let pageWidth = page.bounds(for: PDFDisplayBox.mediaBox).size.width
        
        var change: [PDFAnnotation] = []
        change.append(pointBuilder.getPointNumber(number: number, height: height))
        change.append(contentsOf: pointBuilder.getPointLineGradient(pageWidth: Int(pageWidth), height: height))
        
        let command = AddCommand(pointHelper: self,
                                 page: page,
                                 backup: createMemento(),
                                 change: change)
        
        commandHistory.executeCommand(command)
    }
    
}
