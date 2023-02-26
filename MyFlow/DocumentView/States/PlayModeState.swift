//
//  PlayModeState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
//

import UIKit
import PDFKit


/// Play mode. At this state, user can move to previous point with touching left side and next point with toucing right side.
class PlayModeState: DocumentViewStateInterface {
    enum TapAreaAxis: Int {
        case horizontal
        case vertical
    }

    private(set) var state: DocumentViewState = .playMode
    
    private(set) weak var vm: DocumentViewModel?
    
    
    var trueDepthHelper: TrueDepthHelper?
    var isFarAway = false
    
    init(vm: DocumentViewModel? = nil) {
        self.vm = vm
        
        if UserDefaults.useTrueDepth {
            trueDepthHelper = TrueDepthHelper()
            trueDepthHelper?.delegate = self
        }
    }
    
    
    /// Move to previous point with touching left side and next point with toucing right side.
    func tapProcess(location: CGPoint, pdfView: PDFView) {
        guard let vm = vm else { return }
        
        let axis = UserDefaults.playModeTapAreaAxis
        let length = UserDefaults.playModeTapAreaLength
        switch TapAreaAxis(rawValue: axis) ?? .horizontal {
        case .horizontal:
            if location.x < length {
                vm.moveToPrevPoint()
            }
            else {
                vm.moveToNextPoint()
            }
        case .vertical:
            if location.y < length {
                vm.moveToPrevPoint()
            }
            else {
                vm.moveToNextPoint()
            }
        }
    }
    
    func panGestureBegan(location: CGPoint, pdfView: PDFView) { }
    func panGestureChanged(location: CGPoint, pdfView: PDFView) { }
    func panGestureEnded(location: CGPoint, pdfView: PDFView) { }
    
    func completion(next: DocumentViewState) {
        switch next {
        case .normal:
            break
        default:
            MyLogger.log("UndefinedState: from \(String(describing: self)) to \(next)", .error)
        }
    }
}

extension PlayModeState: TrueDepthHelperDelegate {
    func depthDataAverageOutput(_ average: Float) {
        if average > UserDefaults.trueDepthThreshold && !isFarAway {
            isFarAway = true
        } else if average < UserDefaults.trueDepthThreshold && isFarAway {
            isFarAway = false
            DispatchQueue.main.async { [weak self] in
                self?.vm?.moveToNextPoint()
            }
        }
    }
}
