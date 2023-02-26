//
//  NormalState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/26.
//

import UIKit
import PDFKit


/// State that is not any modes(adding, handling). If user touches the screen, navigation is toggled.
struct NormalState: DocumentViewStateInterface {
    private(set) var state: DocumentViewState = .normal
    
    private(set) weak var vm: DocumentViewModel?
    
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleNavi"), object: nil, userInfo: nil)
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
            vm?.clearSelectedPoint()
        default:
            MyLogger.log("UndefinedState: from \(String(describing: self)) to \(next)", .error)
        }
    }
}
