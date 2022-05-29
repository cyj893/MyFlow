//
//  PdfViewState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
//

import UIKit
import PDFKit

protocol PdfViewState {
    func tapProcess(location: CGPoint, page: PDFPage)
}

fileprivate func animateIt(vc: UIViewController) {
    UIView.animate(
        withDuration: 0.5,
        animations: vc.view.layoutIfNeeded
    )
}

struct NormalState: PdfViewState {
    private(set) weak var vc: DocumentViewController?
    
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

struct HideNaviState: PdfViewState {
    private(set) weak var vc: DocumentViewController?
    
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

struct HandlePointsState: PdfViewState {
    private(set) weak var vc: DocumentViewController?
    
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        print(location)
        guard let annotation = page.annotation(at: location) else { return }
        print(annotation)
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        vc.getPointHelper().selectPoint(annotation)
    }
}

struct AddPointsState: PdfViewState {
    private(set) weak var vc: DocumentViewController?
    
    func tapProcess(location: CGPoint, page: PDFPage) {
        guard let vc = vc else { return }
        
        vc.getPointHelper().addPoint(Int(location.y), page)
    }
}
