//
//  MoveToPoint.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/30.
//

import UIKit
import PDFKit


enum MoveStrategyType: Int {
    case useScrollView
    case useGo
}

protocol MoveStrategy {
    func move(to point: PDFAnnotation)
    func moveAfter(to height: CGFloat)
}

class UseGo: MoveStrategy {
    private(set) weak var vc: DocumentViewController?
    
    public init(vc: DocumentViewController?) {
        self.vc = vc
    }
    
    func move(to point: PDFAnnotation) {
        guard let vc = vc else { return }
        
        vc.pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: point.bounds.maxY), size: CGSize(width: 1, height: -vc.view.frame.height)), on: point.page!)
    }
    
    func moveAfter(to height: CGFloat) {
        MyLogger.log("[MoveStrategy - UseGo] Can't autoscroll with this", .info)
    }
}

class UseScrollView: MoveStrategy {
    private weak var pdfView: PDFView?
    private weak var pdfScrollView: UIScrollView?
    private weak var pdfDocument: PDFDocument?
    private var pageHeights: [CGFloat] = []
    private var pageHeightsPrefixSum: [CGFloat] = []
    
    public init (pdfView: PDFView) throws {
        self.pdfView = pdfView
        guard let pdfScrollView = pdfView.scrollView else {
            throw PdfError.cannotFindScrollView
        }
        self.pdfScrollView = pdfScrollView
        guard let pdfDocument = pdfView.document else {
            throw PdfError.cannotFindDocument
        }
        self.pdfDocument = pdfDocument
        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else {
                throw PdfError.cannotFindPage
            }
            let pageSize = page.bounds(for: .mediaBox)
            pageHeights.append(pageSize.height)
        }
        var prefixSum: CGFloat = 0
        pageHeightsPrefixSum.append(0)
        pageHeights.forEach {
            prefixSum += $0
            pageHeightsPrefixSum.append(prefixSum)
        }
    }
    
    func move(to point: PDFAnnotation) {
        // Actual scrollView's height(pdfScrollView.contentSize.height)
        // keeps changing depending on whether user zoom or not.
        // So get scaleFactor from pdfView and multiply scrollView's height by it
        // to get the converted height of the current scrollview.
        guard let pdfView = pdfView,
              let pdfDocument = pdfDocument,
              let pdfScrollView = pdfScrollView else {
            MyLogger.log("[MoveStrategy - UseScrollView] Some of pdfView, pdfDocument and pdfScrollView is nil", .error)
            return
        }
        let scaleFactor = pdfView.scaleFactor
        let pageIndex = pdfDocument.index(for: point.page!)
        let height = pageHeightsPrefixSum[pageIndex] + pageHeights[pageIndex] - point.bounds.maxY
        let convertedHeight = CGPoint(x: 0, y: height * scaleFactor)
        pdfScrollView.setContentOffset(convertedHeight, animated: true)
    }
    
    func moveAfter(to height: CGFloat) {
        guard let pdfScrollView = pdfScrollView else {
            MyLogger.log("[MoveStrategy - UseScrollView] pdfScrollView is nil", .error)
            return
        }
        pdfScrollView.setContentOffset(CGPoint(x: 0, y: pdfScrollView.contentOffset.y + height), animated: true)
    }
    
}
