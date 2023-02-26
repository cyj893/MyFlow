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
