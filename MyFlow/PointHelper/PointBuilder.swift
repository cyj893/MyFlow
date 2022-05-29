//
//  PointBuilder.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/19.
//

import UIKit
import PDFKit

class PointBuilder {
    
    private var border = PDFBorder()
    private var pointNumberHeight = Int(MyFont.sizePointNum.height)
    
    init() {
        border.lineWidth = 1.0
    }
    
    
    // MARK: Build Point Line, Number
    
    func getPointLineGradient(pageWidth: Int, height: Int) -> [PDFAnnotation] {
        var lines:[PDFAnnotation] = []
        for i in 0...3 {
            let line = buildPointLine(pageWidth: pageWidth, height: height - i, color: GradientColor.normal[i])
            lines.append(line)
        }
        return lines
    }
    
    fileprivate func buildPointLine(pageWidth: Int, height: Int, color: UIColor = .blue) -> PDFAnnotation {
        let bounds = CGRect(
            origin: CGPoint(x: 0, y: height - 1),
            size: CGSize(width: pageWidth, height: 1))
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: pageWidth, y: height))
        path.close()
        path.moveCenter(to: bounds.center)
        
        let lineAnnotation = PDFAnnotation(
            bounds: bounds,
            forType: .ink,
            withProperties: ["isPointLine": true])
        lineAnnotation.add(path)
        lineAnnotation.border = border
        lineAnnotation.color = color
        
        return lineAnnotation
    }
    
    func getPointNumber(number: Int, height: Int) -> PDFAnnotation {
        let str = String(number)
        
        let bounds = CGRect(
            origin: CGPoint(x: 10, y: height - pointNumberHeight),
            size: CGSize(width: 50, height: pointNumberHeight))
        let pointNumText = PDFAnnotation(
            bounds: bounds,
            forType: .widget,
            withProperties: ["isPoint": true])
        
        pointNumText.widgetStringValue = str
        pointNumText.widgetFieldType = .text
        
        // pointNumText.alignment = .center
        pointNumText.font = MyFont.pointNum
        pointNumText.fontColor = .systemPink
        pointNumText.color = .clear
        pointNumText.backgroundColor = .clear
                
        return pointNumText
    }
    
}
