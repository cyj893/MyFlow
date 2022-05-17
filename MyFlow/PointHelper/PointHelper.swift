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
    
    private let gradientColors:[UIColor] = [
        UIColor(rgb: 0x769FCD, alpha: 0.5),
        UIColor(rgb: 0xB9D7EA, alpha: 0.5),
        UIColor(rgb: 0xD6E6F2, alpha: 0.5),
        UIColor(rgb: 0xF7FBFC, alpha: 0.5)
    ]
    
    private let selectedGradientColors:[UIColor] = [
        UIColor(rgb: 0xc9184a, alpha: 0.5),
        UIColor(rgb: 0xff758f, alpha: 0.5),
        UIColor(rgb: 0xffb3c1, alpha: 0.5),
        UIColor(rgb: 0xffccd5, alpha: 0.5)
    ]
    
    private let border:PDFBorder = {
        let border = PDFBorder()
        border.lineWidth = 1.0
        return border
    }()
    
    let font = UIFont.Fonarto(size: 20)
    var pointNumberHeight: Int = 0
    
    
    init() {
        pointNumberHeight = Int("012345678".sizeOfString(font: font!).height)
    }
    
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    func getNowSelectedPoint() -> PDFAnnotation? { nowSelectedPoint }
    
    
    // MARK: Moving Point
    
    func movePrev() -> PDFAnnotation {
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    func moveNext() -> PDFAnnotation {
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
    
    // MARK: Select Point
    
    var nowSelectedPoint:PDFAnnotation?
    var nowSelectedPointLines:[PDFAnnotation] = []
    
    func selectPoint(_ annotation: PDFAnnotation) {
        if nowSelectedPoint != nil {
            if nowSelectedPoint == annotation {
                endMovePoint()
                return
            }
            else {
                endMovePoint()
            }
        }
        nowSelectedPoint = annotation
        guard let str:String = annotation.widgetStringValue else { return }
        let number = Int(str)!
        print(number)
        
        nowSelectedPointLines = linesDict[number]!
        for i in 0...3 {
            nowSelectedPointLines[i].color = selectedGradientColors[i]
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
        
        nowSelectedPoint.bounds = CGRect(origin: CGPoint(x: 10, y: height - pointNumberHeight), size: nowSelectedPoint.bounds.size)
        for i in 0...3 {
            nowSelectedPointLines[i].bounds = CGRect(origin: CGPoint(x: 0, y: height - i), size: nowSelectedPointLines[i].bounds.size)
        }
    }
    
    func endMovePoint() {
        for i in 0...3 {
            nowSelectedPointLines[i].color = gradientColors[i]
        }
        nowSelectedPoint = nil
        nowSelectedPointLines = []
    }
    
    
    // MARK: Adding Point
    
    func addPoint(_ height: Int, _ page: PDFPage) {
        let number:Int = getPointsCount() + 1
        addPointLineGradient(height, page, number)
        let pointNum = addPointNumber(height, page, number)
        points.append(pointNum)
    }
    
    fileprivate func addPointLineGradient(_ height: Int, _ page: PDFPage, _ number: Int) {
        linesDict[number] = []
        for i in 0...3 {
            let lineAnnotation = addPointLine(height - i, page, color: gradientColors[i])
            linesDict[number]?.append(lineAnnotation)
        }
    }
    
    fileprivate func addPointLine(_ height: Int, _ page: PDFPage, color: UIColor = .blue) -> PDFAnnotation {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        let pageSize = page.bounds(for: PDFDisplayBox.mediaBox).size
        path.addLine(to: CGPoint(x: Int(pageSize.width), y: height))
        path.close()
        
        let bounds = CGRect(origin: CGPoint(x: 0, y: height - 1), size: CGSize(width: pageSize.width, height: 1.0))
        path.moveCenter(to: bounds.center)
        
        let inkAnnotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: ["isPointLine": true])
        inkAnnotation.add(path)
        inkAnnotation.border = border
        inkAnnotation.color = color
        page.addAnnotation(inkAnnotation)
        return inkAnnotation
    }
    
    fileprivate func addPointNumber(_ height: Int, _ page: PDFPage, _ number: Int) -> PDFAnnotation {
        let str = String(number)
        let pointNumText = PDFAnnotation(bounds: CGRect(origin: CGPoint(x: 10, y: height - pointNumberHeight), size: CGSize(width: 50, height: pointNumberHeight)), forType: .widget, withProperties: ["isPoint": true])
        
        pointNumText.widgetStringValue = str
        pointNumText.widgetFieldType = .text
        
        // pointNumText.alignment = .center
        pointNumText.font = font
        pointNumText.fontColor = .systemPink
        pointNumText.color = .clear
        pointNumText.backgroundColor = .clear
        
        page.addAnnotation(pointNumText)
        
        return pointNumText
    }
    
}
