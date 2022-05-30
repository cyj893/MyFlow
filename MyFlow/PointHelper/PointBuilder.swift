//
//  PointBuilder.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/19.
//

import UIKit
import PDFKit

/// Builds the point annotaion group at specific height.
class PointBuilder {
    
    /// line annotation's border.
    private var border = PDFBorder()
    /// pointNumber annotation's height.
    private var pointNumberHeight = Int(MyFont.sizePointNum.height)
    
    init() {
        border.lineWidth = 1.0
    }
    
    
    // MARK: Build Point Line, Number
    
    /// Returns gradient line annotation group.
    ///
    /// - Parameters:
    ///   - pageWidth: PDFPage's width. Becomes the line annotaion's length.
    ///   - height: Height position at PDFPage.
    /// - Returns: An array of line annotations each 1 px thick and 1 different in height.
    func getPointLineGradient(pageWidth: Int, height: Int) -> [PDFAnnotation] {
        var lines:[PDFAnnotation] = []
        for i in 0...3 {
            let line = buildPointLine(pageWidth: pageWidth, height: height - i, color: GradientColor.normal[i])
            lines.append(line)
        }
        return lines
    }
    
    
    /// Returns gradient line annotation.
    ///
    /// - Parameters:
    ///   - pageWidth: `PDFPage`'s width. Becomes the line annotaion's length.
    ///   - height: Height position at `PDFPage`.
    ///   - color: Line's color. Default is blue,
    /// - Returns: A colored line annotation with a thickness of 1 px that exists at a certain height.
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
    
    /// Returns point number annotation.
    ///
    /// - Parameters:
    ///   - number: Point's number by order.
    ///   - height: Height position at the `PDFPage`.
    /// - Returns: Point number annotation that exists at a height down by `pointNumberHeight`.
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
