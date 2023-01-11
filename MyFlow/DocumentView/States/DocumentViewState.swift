//
//  DocumentViewState.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/29.
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

/// Play mode. At this state, user can move to previous point with touching left side and next point with toucing right side.
struct PlayModeState: DocumentViewStateInterface {
    private(set) var state: DocumentViewState = .playMode
    
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
    
    func completion(next: DocumentViewState) {
        switch next {
        case .normal:
            break
        default:
            MyLogger.log("UndefinedState: from \(String(describing: self)) to \(next)", .error)
        }
    }
}
