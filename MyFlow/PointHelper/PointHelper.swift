//
//  AnotationHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit
import PDFKit

class PointHelper {
    
    private var points:[PDFAnnotation] = []
    private var linesDict:[Int:[PDFAnnotation]] = [:]
    
    private var idx:Int = 0
    
    var nowSelectedPoint:PDFAnnotation?
    var nowSelectedPointLines:[PDFAnnotation] = []
    
    let pointBuilder = PointBuilder()
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    func getNowSelectedPoint() -> PDFAnnotation? { nowSelectedPoint }
    
}


// MARK: Move to Point

extension PointHelper {
    
    func moveToPrev() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    func moveToNext() throws -> PDFAnnotation {
        guard getPointsCount() > 0 else {
            throw PointError.emptyPoints
        }
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
}


// MARK: Select and Move Point

extension PointHelper {
    
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
    
    fileprivate func extractedFunc(_ nowSelectedPoint: PDFAnnotation, _ page: PDFPage) {
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
        
        extractedFunc(nowSelectedPoint, page)
        
        nowSelectedPoint.bounds = CGRect(
            origin: CGPoint(x: 10, y: height - Int(MyFont.sizePointNum.height)),
            size: nowSelectedPoint.bounds.size)
        for i in 0...3 {
            nowSelectedPointLines[i].bounds = CGRect(
                origin: CGPoint(x: 0, y: height - i),
                size: nowSelectedPointLines[i].bounds.size)
        }
    }
    
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
    
    func addPoint(_ height: Int, _ page: PDFPage) {
        let number:Int = getPointsCount() + 1
        linesDict[number] = []
        
        addPointLine(page, height, number)
        addPointNumber(number, height, page)
    }
    
    fileprivate func addPointLine(_ page: PDFPage, _ height: Int, _ number: Int) {
        let pageWidth = page.bounds(for: PDFDisplayBox.mediaBox).size.width
        let lines = pointBuilder.getPointLineGradient(pageWidth: Int(pageWidth), height: height)
        linesDict[number]!.append(contentsOf: lines)
        lines.forEach {
            page.addAnnotation($0)
        }
    }
    
    fileprivate func addPointNumber(_ number: Int, _ height: Int, _ page: PDFPage) {
        let pointNumber = pointBuilder.getPointNumber(number: number, height: height)
        points.append(pointNumber)
        page.addAnnotation(pointNumber)
    }
    
}
