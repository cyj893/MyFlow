//
//  PdfViewState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
//

import UIKit
import PDFKit

protocol DocumentViewState {
    func tapProcess(location: CGPoint)
}


/// State that is not any modes(adding, handling), just showing navigationView.
struct NormalState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Hide navigationView and change state to `HideNaviState`.
    func tapProcess(location: CGPoint) {
        guard let vc = vc else { return }
        vc.hideNavi()
        vc.changeState(state: HideNaviState(vc: vc))
    }
}

/// State that not any modes(adding, handling), hiding navigaionView.
struct HideNaviState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Show navigationView and change state to `NormalState`.
    func tapProcess(location: CGPoint) {
        guard let vc = vc else { return }
        vc.showNavi()
        vc.changeState(state: NormalState(vc: vc))
    }
    
}

/// State that handling points. User can select and move points at this state.
struct HandlePointsState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Move selected points to `location`.
    func tapProcess(location: CGPoint) {
        guard let vc = vc else { return }
        
        guard let page = vc.getPdfView().page(for: location, nearest: true) else { return }
        let convertedLocation = vc.getPdfView().convert(location, to: page)
        
        print(convertedLocation)
        guard let annotation = page.annotation(at: convertedLocation) else { return }
        print(annotation)
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        vc.getPointHelper().selectPoint(annotation)
    }
}

/// State that adding points. User can  add new points at this state.
struct AddPointsState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// add new point to `location`.
    func tapProcess(location: CGPoint) {
        guard let vc = vc else { return }
        
        guard let page = vc.getPdfView().page(for: location, nearest: true) else { return }
        let convertedLocation = vc.getPdfView().convert(location, to: page)
        
        vc.getPointHelper().addPoint(Int(convertedLocation.y), page)
    }
}

/// Play mode. At this state, user can move to previous point with touching left side and next point with toucing right side.
struct PlayModeState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Move to previous point with touching left side and next point with toucing right side.
    func tapProcess(location: CGPoint) {
        guard let vc = vc else { return }
        
        let halfWidth = vc.view.frame.width / 2
        if location.x < halfWidth {
            vc.prevPointButtonAction()
        }
        else {
            vc.nextPointButtonAction()
        }
    }
}
