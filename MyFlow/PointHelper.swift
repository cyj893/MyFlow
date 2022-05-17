//
//  AnotationHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit
import PDFKit

class PointHelper {
    
    private var points:[(PDFPage, CGFloat)] = []
    
    private var idx:Int = 0
    
    private let gradientColors:[UIColor] = [
        UIColor(rgb: 0x769FCD, alpha: 0.5),
        UIColor(rgb: 0xB9D7EA, alpha: 0.5),
        UIColor(rgb: 0xD6E6F2, alpha: 0.5),
        UIColor(rgb: 0xF7FBFC, alpha: 0.5)
    ]
    
    private let border:PDFBorder = {
        let border = PDFBorder()
        border.lineWidth = 1.0
        return border
    }()
    
    
    init() {
        
    }
    
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    
    
    // MARK: Moving Point
    
    func movePrev() -> (PDFPage, CGFloat) {
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    func moveNext() -> (PDFPage, CGFloat) {
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
    
    // MARK: Adding Point
    
    func addPoint(_ height: CGFloat, _ page: PDFPage) {
        points.append((page, height))
        addAnnotation(height, page, 1)
    }
    
    fileprivate func addAnnotation(_ height: CGFloat, _ page: PDFPage, _ number: Int) {
        addPointLineGradient(height, page)
        addNumber(height, page, number)
    }
    
    fileprivate func addPointLineGradient(_ height: CGFloat, _ page: PDFPage) {
        for i in 0...3 {
            addPointLine(height - CGFloat(i), page, color: gradientColors[i])
        }
    }
    
    fileprivate func addPointLine(_ height: CGFloat, _ page: PDFPage, color: UIColor = .blue) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: height))
        let pageSize = page.bounds(for: PDFDisplayBox.mediaBox).size
        path.addLine(to: CGPoint(x: pageSize.width, y: height))
        path.close()
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                        width: path.bounds.size.width + 10,
                       height: path.bounds.size.height + 10)
        path.moveCenter(to: bounds.center)
        
        let inkAnnotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: ["isPoint": false, "isPointLine": true])
        inkAnnotation.add(path)
        inkAnnotation.border = border
        inkAnnotation.color = color
        page.addAnnotation(inkAnnotation)
    }
    
    fileprivate func addNumber(_ height: CGFloat, _ page: PDFPage, _ number: Int) {
        let str = String(number)
        let font = UIFont.Fonarto(size: 20)
        let size = str.sizeOfString(font: font!)
        let pointNumText = PDFAnnotation(bounds: CGRect(origin: CGPoint(x: 10.0, y: height - size.height), size: size), forType: .widget, withProperties: nil)
        
        pointNumText.widgetStringValue = str
        pointNumText.widgetFieldType = .text
        
        pointNumText.alignment = .center
        pointNumText.font = font
        pointNumText.fontColor = .systemPink
        pointNumText.color = .clear
        pointNumText.backgroundColor = .clear
        
        page.addAnnotation(pointNumText)
    }
    
}
