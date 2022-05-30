//
//  PdfViewState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
//

import UIKit
import PDFKit

protocol DocumentViewState {
    func tapProcess(location: CGPoint, page: PDFPage)
}

/// Configurate and animate for `MyNavigationView`
fileprivate func animateIt(vc: UIViewController) {
    UIView.animate(
        withDuration: 0.5,
        animations: vc.view.layoutIfNeeded
    )
}

/// State that is not any modes(adding, handling), just showing navigationView.
struct NormalState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Hide navigationView and change state to `HideNaviState`.
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        print("hide myNavigationView")
        vc.myNavigationView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        vc.getPdfView().snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animateIt(vc: vc)
        vc.changeState(state: HideNaviState(vc: vc))
    }
}

/// State that not any modes(adding, handling), hiding navigaionView.
struct HideNaviState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Show navigationView and change state to `NormalState`.
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        print("show myNavigationView")
        vc.myNavigationView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        vc.getPdfView().snp.remakeConstraints {
            $0.top.equalTo(vc.myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        animateIt(vc: vc)
        vc.changeState(state: NormalState(vc: vc))
    }
}

/// State that handling points. User can select and move points at this state.
struct HandlePointsState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// Move selected points to `location`.
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        print(location)
        guard let annotation = page.annotation(at: location) else { return }
        print(annotation)
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        vc.getPointHelper().selectPoint(annotation)
    }
}

/// State that adding points. User can  add new points at this state.
struct AddPointsState: DocumentViewState {
    private(set) weak var vc: DocumentViewController?
    
    /// add new point to `location`.
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        vc.getPointHelper().addPoint(Int(location.y), page)
    }
}
