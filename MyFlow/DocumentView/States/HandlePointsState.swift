//
//  HandlePointsState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/26.
//

import UIKit
import PDFKit


/// State that handling points. User can select and move points at this state.
struct HandlePointsState: DocumentViewStateInterface {
    private(set) var state: DocumentViewState = .handlePoints
    
    private(set) weak var vm: DocumentViewModel?
    
    /// Move selected points to `location`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let page = pdfView.page(for: location, nearest: true),
              let annotation = page.annotation(at: pdfView.convert(location, to: page)),
              let _ = annotation.annotationKeyValues["/isPoint"] else {
            
            MyLogger.log("ignore tapProcess: location is not point annotation")
            return
        }
        
        MyLogger.log("tapProcess: point annotation selected")
        
        vm.pointHelper.selectPoint(annotation)
    }
    
    func panGestureBegan(location: CGPoint, pdfView: PDFView) { }
    
    func panGestureChanged(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        guard let _ = vm.pointHelper.getNowSelectedPoint() else { return }
        if pdfView.frame.height - location.y < pdfView.frame.height * 0.2 {
            vm.moveStrategy?.moveAfter(to: pdfView.frame.height * 0.2 + 100)
        }
        vm.pointHelper.movePoint(Int(convertedLocation.y), page)
    }
    
    func panGestureEnded(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let _ = vm.pointHelper.getNowSelectedPoint() else { return }
        vm.pointHelper.endMove()
    }
    
    func completion(next: DocumentViewState) {
        switch next {
        case .normal:
            vm?.clearSelectedPoint()
        case .handlePoints:
            break
        case .addPoints:
            vm?.clearSelectedPoint()
        case .playMode:
            vm?.clearSelectedPoint()
        default:
            MyLogger.log("UndefinedState: from \(String(describing: self)) to \(next)", .error)
        }
    }
}
