//
//  AnotationHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit
import PDFKit

class PointHelper {
    
    private var points:[(PDFPage, Int)] = []
    
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
    
    
    init() {
        
    }
    
    
    // MARK: Getter, Setter
    
    func getPointsCount() -> Int { points.count }
    
    
    // MARK: Moving Point
    
    func movePrev() -> (PDFPage, Int) {
        idx -= 1
        if idx < 0 { idx += getPointsCount() }
        return points[idx]
    }
    
    func moveNext() -> (PDFPage, Int) {
        idx += 1
        idx %= getPointsCount()
        return points[idx]
    }
    
    
    // MARK: Select Point
    
    func selectPoint(_ annotation: PDFAnnotation) {
        guard let str:String = annotation.widgetStringValue else { return }
        let number = Int(str)!
        print(number)
        
        let height = points[number-1].1
        let page = points[number-1].0
        
        for i in 0...3 {
            guard let lineAnnotation = page.annotation(at: CGPoint(x: 50, y: height - i - 1)) else { return }
            guard let _ = lineAnnotation.annotationKeyValues["/isPointLine"] else { return }
            print(lineAnnotation)
            lineAnnotation.color = selectedGradientColors[i]
        }
        
    }
    
    
    // MARK: Adding Point
    
    func addPoint(_ height: Int, _ page: PDFPage) {
        points.append((page, height))
        addAnnotation(height, page, getPointsCount())
    }
    
    fileprivate func addAnnotation(_ height: Int, _ page: PDFPage, _ number: Int) {
        addPointLineGradient(height, page)
        addNumber(height, page, number)
    }
    
    fileprivate func addPointLineGradient(_ height: Int, _ page: PDFPage) {
        for i in 0...3 {
            addPointLine(height - i, page, color: gradientColors[i])
        }
    }
    
    fileprivate func addPointLine(_ height: Int, _ page: PDFPage, color: UIColor = .blue) {
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
    }
    
    fileprivate func addNumber(_ height: Int, _ page: PDFPage, _ number: Int) {
        let str = String(number)
        let font = UIFont.Fonarto(size: 20)
        let size = str.sizeOfString(font: font!)
        let pointNumText = PDFAnnotation(bounds: CGRect(origin: CGPoint(x: 10, y: height - Int(size.height)), size: size), forType: .widget, withProperties: ["isPoint": true])
        
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
