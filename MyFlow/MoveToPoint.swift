//
//  MoveToPoint.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/30.
//

import UIKit
import PDFKit

protocol MoveToPoint {
    func move(to point: PDFAnnotation)
}

struct UseGo: MoveToPoint {
    private(set) weak var vc: DocumentViewController?
    
    func move(to point: PDFAnnotation) {
        guard let vc = vc else { return }
        
        vc.getPdfView().go(to: CGRect(origin: CGPoint(x: 0, y: point.bounds.maxY), size: CGSize(width: 1, height: -vc.view.frame.height)), on: point.page!)
    }
}

struct UseScrollView: MoveToPoint {
    private weak var pdfView: PDFView?
    private var pdfScrollView: UIScrollView
    private var pdfDocument: PDFDocument
    private var pageHeights: [CGFloat] = []
    private var pageHeightsPrefixSum: [CGFloat] = []
    
    public init (pdfView: PDFView) throws {
        self.pdfView = pdfView
        guard let pdfScrollView = pdfView.subviews.first as? UIScrollView else {
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
        do {
            try tryMove(to: point)
        } catch {
            // TODO: log
        }
    }
    
    func tryMove(to point: PDFAnnotation) throws {
        // Actual scrollView's height(pdfScrollView?.contentSize.height)
        // keeps changing depending on whether user zoom or not.
        // So get scaleFactor from pdfView and multiply scrollView's height by it
        // to get the converted height of the current scrollview.
        guard let scaleFactor = pdfView?.scaleFactor else {
            throw PdfError.cannotGetScaleFactor
        }
        let pageIndex: Int = pdfDocument.index(for: point.page!)
        let height = pageHeightsPrefixSum[pageIndex] + pageHeights[pageIndex] - point.bounds.maxY
        let convertedHeight = CGPoint(x: 0, y: height * scaleFactor)
        print("Move to \(convertedHeight.y)")
        pdfScrollView.setContentOffset(convertedHeight, animated: true)
    }
}
