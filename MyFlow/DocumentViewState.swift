//
//  PdfViewState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
//

import UIKit
import PDFKit

protocol DocumentViewState {
    func tapProcess(location: CGPoint, pdfView: PDFView)
}


/// State that is not any modes(adding, handling), just showing navigationView.
struct NormalState: DocumentViewState {
    private(set) weak var vm: DocumentViewModel?
    
    /// Hide navigationView and change state to `HideNaviState`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        vm.delegate?.hideNavi()
        vm.nowState = HideNaviState(vm: vm)
    }
}

/// State that not any modes(adding, handling), hiding navigaionView.
struct HideNaviState: DocumentViewState {
    private(set) weak var vm: DocumentViewModel?
    
    /// Show navigationView and change state to `NormalState`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        vm.delegate?.showNavi()
        vm.nowState = NormalState(vm: vm)
    }
    
}

/// State that handling points. User can select and move points at this state.
struct HandlePointsState: DocumentViewState {
    private(set) weak var vm: DocumentViewModel?
    
    /// Move selected points to `location`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        print(convertedLocation)
        guard let annotation = page.annotation(at: convertedLocation) else { return }
        print(annotation)
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        vm.pointHelper.selectPoint(annotation)
    }
}

/// State that adding points. User can  add new points at this state.
struct AddPointsState: DocumentViewState {
    private(set) weak var vm: DocumentViewModel?
    
    /// add new point to `location`.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        vm.pointHelper.addPoint(Int(convertedLocation.y), page)
    }
}

/// Play mode. At this state, user can move to previous point with touching left side and next point with toucing right side.
struct PlayModeState: DocumentViewState {
    private(set) weak var vm: DocumentViewModel?
    
    /// Move to previous point with touching left side and next point with toucing right side.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        let halfWidth = UIScreen.main.bounds.width / 2
        if location.x < halfWidth {
            vm.moveToPrevPoint()
        }
        else {
            vm.moveToNextPoint()
        }
    }
}
