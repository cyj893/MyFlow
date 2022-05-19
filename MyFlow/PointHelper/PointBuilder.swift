//
//  PointBuilder.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/19.
//

import UIKit
import PDFKit

class PointBuilder {
    
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
    
    func getPointNumberHeight() -> Int { return pointNumberHeight }
    
    func getPointLineGradient(pageWidth: Int, height: Int) -> [PDFAnnotation] {
        return GradientColor.normal.map {
            buildPointLine(pageWidth: pageWidth, height: height, color: $0)
        }
    }
    
    fileprivate func buildPointLine(pageWidth: Int, height: Int, color: UIColor = .blue) -> PDFAnnotation {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: pageWidth, y: height))
        path.close()
        
        let bounds = CGRect(origin: CGPoint(x: 0, y: height - 1), size: CGSize(width: pageWidth, height: 1))
        path.moveCenter(to: bounds.center)
        
        let lineAnnotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: ["isPointLine": true])
        lineAnnotation.add(path)
        lineAnnotation.border = border
        lineAnnotation.color = color
        
        return lineAnnotation
    }
    
    func getPointNumber(number: Int, height: Int) -> PDFAnnotation {
        let str = String(number)
        let pointNumText = PDFAnnotation(bounds: CGRect(origin: CGPoint(x: 10, y: height - pointNumberHeight), size: CGSize(width: 50, height: pointNumberHeight)), forType: .widget, withProperties: ["isPoint": true])
        
        pointNumText.widgetStringValue = str
        pointNumText.widgetFieldType = .text
        
        // pointNumText.alignment = .center
        pointNumText.font = font
        pointNumText.fontColor = .systemPink
        pointNumText.color = .clear
        pointNumText.backgroundColor = .clear
                
        return pointNumText
    }
    
}
