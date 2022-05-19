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
    
    func moveToPrev() -> PDFAnnotation {
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    func moveToNext() -> PDFAnnotation {
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
                endSelectPoint()
                return
            }
            else {
                endSelectPoint()
            }
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
        
        nowSelectedPoint.bounds = CGRect(origin: CGPoint(x: 10, y: height - pointBuilder.getPointNumberHeight()), size: nowSelectedPoint.bounds.size)
        for i in 0...3 {
            nowSelectedPointLines[i].bounds = CGRect(origin: CGPoint(x: 0, y: height - i), size: nowSelectedPointLines[i].bounds.size)
        }
    }
    
    func endSelectPoint() {
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
        
        let pageWidth = page.bounds(for: PDFDisplayBox.mediaBox).size.width
        let lines = pointBuilder.getPointLineGradient(pageWidth: Int(pageWidth), height: height)
        linesDict[number]!.append(contentsOf: lines)
        lines.forEach {
            page.addAnnotation($0)
        }
        
        let pointNumber = pointBuilder.getPointNumber(number: number, height: height)
        points.append(pointNumber)
        page.addAnnotation(pointNumber)
    }
    
}
