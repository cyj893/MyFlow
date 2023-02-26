//
//  AddPointsState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/26.
//

import UIKit
import PDFKit


/// State that adding points. User can  add new points at this state.
struct AddPointsState: DocumentViewStateInterface {
    private(set) var state: DocumentViewState = .addPoints
    
    private(set) weak var vm: DocumentViewModel?
    
    /// add new point to `location`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        vm.pointHelper.addPoint(Int(convertedLocation.y), page)
    }
    
    func panGestureBegan(location: CGPoint, pdfView: PDFView) { }
    func panGestureChanged(location: CGPoint, pdfView: PDFView) { }
    func panGestureEnded(location: CGPoint, pdfView: PDFView) { }
    
    func completion(next: DocumentViewState) {
        switch next {
        case .normal:
            break
        case .handlePoints:
            break
        case .addPoints:
            break
        case .playMode:
            break
        default:
            MyLogger.log("UndefinedState: from \(String(describing: self)) to \(next)", .error)
        }
    }
}
