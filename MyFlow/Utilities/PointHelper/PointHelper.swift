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
    
    let logger = MyLogger(category: String(describing: PointHelper.self))
    
    // MARK: Properties
    
    var commandHistory = UndoRedoHistory()
    
    /// Added points to pdf.
    var points:[PDFAnnotation] = []
    /// (number: line annotations) dictionary  to find easily based on point number.
    var linesDict:[Int:[PDFAnnotation]] = [:]
    /// Currently located point's index.
    var idx:Int = 0
    
    var moveBackup: PointMemento?
    /// Current point number annotation selected by user.
    var nowSelectedPoint:PDFAnnotation?
    /// Current point line annotations selected by user.
    var nowSelectedPointLines:[PDFAnnotation] = []
    
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    func getNowSelectedPoint() -> PDFAnnotation? { nowSelectedPoint }
    
    func getPointsInfo() -> [(Int, PDFPage)] {
        points.compactMap { annotaion in
            (Int(annotaion.bounds.origin.y) + PointBuilder.pointNumberHeight, annotaion.page) as? (Int, PDFPage)
        }
    }
    
    func createMemento() -> PointHelperMemento {
        return PointHelperMemento(points: points, linesDict: linesDict)
    }
    
    func createMemento2(_ annotation: PDFAnnotation, _ idx: Int) -> PointInstanceMemento {
    var change:[PDFAnnotation] = []
    change.append(annotation)
    change.append(contentsOf: nowSelectedPointLines)
    return PointInstanceMemento(change: change, idx: idx)
}

    func undo() {
        commandHistory.undoCommand()
    }
    
    func redo() {
        commandHistory.redoCommand()
    }
    
    func clear() {
        commandHistory.clear()
    }
    
    #if DEBUG
    deinit {
        logger.log("PointHelper deinit")
    }
    #endif
}


// MARK: Move to Point

extension PointHelper {
    
    /// Return the previous point number annotation.
    ///
    /// - Returns:Previous point number annotation from now.
    func getPrevPoint() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    /// Return the next point number annotation.
    ///
    /// - Returns:Next point number annotation from now.
    func getNextPoint() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
    /// Return the point number annotation at index.
    ///
    /// - Returns:Point number annotation at index.
    func getPoint(at index: Int) throws -> PDFAnnotation {
        guard points.count > 0 else {
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
        guard let str: String = annotation.widgetStringValue,
              let number = Int(str) else { return }
        logger.log("selectPoint: \(number)")
        
        nowSelectedPointLines = linesDict[number]!
        for i in 0...3 {
            nowSelectedPointLines[i].color = GradientColor.selected[i]
        }
        
        moveBackup = PointMemento(page: annotation.page!,
                                   height: Int(annotation.bounds.origin.y)
                                            + Int(MyFont.sizePointNum.height))
    }
    
    /// Moves point annnotaions to new location.
    ///
    /// - Parameters:
    ///   - height: Height position to move to at PDFPage.
    ///   - page: A PDFPage to move point annotations to. It may or may not be the same as before.
    func movePoint(_ height: Int, _ page: PDFPage) {
        guard let nowSelectedPoint = nowSelectedPoint else {
            logger.log("movePoint: nowSelectedPoint is nil, No point to move.", .info)
            return
        }
        
        if height < 0 {
            logger.log("movePoint: Height \(height) is less than 0.", .info)
            return
        }
        // set height bound
        if page.pageRef?.pageNumber == 1 {
            let pageSize = page.bounds(for: PDFDisplayBox.mediaBox).size
            if height > Int(pageSize.height) {
                logger.log("movePoint: Height \(height) is over the page's height \(pageSize.height).", .info)
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
    
    func endMove() {
        var change: [PDFAnnotation] = []
        change.append(nowSelectedPoint!)
        change.append(contentsOf: nowSelectedPointLines)
        
        let afterMove = PointMemento(page: nowSelectedPoint!.page!,
                                     height: Int(nowSelectedPoint!.bounds.origin.y)
                                            + Int(MyFont.sizePointNum.height))
        let command = MoveCommand(pointHelper: self,
                                  change: change,
                                  backup: moveBackup!,
                                  after: afterMove)
        commandHistory.push(command)
        
        clearSelectedPoint()
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
        change.append(PointBuilder.getPointNumber(number: number, height: height))
        change.append(contentsOf: PointBuilder.getPointLineGradient(pageWidth: Int(pageWidth), height: height))
        
        let command = AddCommand(pointHelper: self,
                                 change: change,
                                 page: page,
                                 backup: createMemento())
        
        commandHistory.executeCommand(command)
    }
    
}


// MARK: Delete Point

extension PointHelper {
    
    /// Deletes point annotaion at specific height and page.
    ///
    /// - Parameter annotation: PDFAnnotation to delete.
    func deletePoint() {
        guard let annotation = nowSelectedPoint else {
            logger.log("deletePoint: nowSelectedPoint is nil, No point to delete.", .info)
            return
        }
        guard let number = Int(annotation.widgetStringValue ?? "") else {
            logger.log("deletePoint: Cannot convert point to index. value: \(annotation.widgetStringValue ?? "nil")", .info)
            return
        }
        var change: [PDFAnnotation] = []
        change.append(annotation)
        change.append(contentsOf: nowSelectedPointLines)
        
        let command = DeleteCommand(pointHelper: self,
                                 backup: createMemento2(annotation, number))
        
        commandHistory.executeCommand(command)
        
        clearSelectedPoint()
    }
    
}
