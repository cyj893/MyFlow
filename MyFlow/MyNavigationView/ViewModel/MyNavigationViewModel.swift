//
//  MyNavigationViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import Foundation


final class MyNavigationViewModel {
    
    var delegate: MyNavigationViewDelegate?
    
    var mainViewDelegate: MainViewDelegate?
    var currentVM: DocumentViewModelInterface?
    
    
    func clear() {
        currentVM = nil
    }
}

extension MyNavigationViewModel: MovingAreaDelegate {
    func prevPointButtonAction() {
        currentVM?.moveToPrevPoint()
    }
    
    func nextPointButtonAction() {
        currentVM?.moveToNextPoint()
    }
}


extension MyNavigationViewModel: PointsAreaDelegate {
    func addPointsPagesButtonAction() {
        currentVM?.showAddPointsModalView()
    }
    
    func toggleAddingPointsMode(_ isAddingPoints: Bool, _ isHandlingPoints: Bool) {
        if isHandlingPoints {
            delegate?.toggleHandlePointButton()
        }
        
        if isAddingPoints {
            print("포인트 추가")
            currentVM?.clearSelectedPoint()
            currentVM?.changeState(to: .addPoints)
        }
        else {
            print("포인트 추가 끝")
            currentVM?.changeState(to: .normal)
        }
    }
    
    func deleteButtonAction() {
        currentVM?.deletePoint()
    }
    
    func toggleHandlingPointsMode(_ isHandlingPoints: Bool, _ isAddingPoints: Bool) {
        if isAddingPoints {
            delegate?.toggleAddPointsButton()
        }
        
        if isHandlingPoints {
            print("포인트 핸들링")
            currentVM?.changeState(to: .handlePoints)
        }
        else {
            print("포인트 핸들링 끝")
            currentVM?.clearSelectedPoint()
            currentVM?.changeState(to: .normal)
        }
    }
}


extension MyNavigationViewModel: UndoRedoAreaDelegate {
    func redoButtonAction() {
        currentVM?.redo()
    }
    
    func undoButtonAction() {
        currentVM?.undo()
    }
}


// MARK: MyNavigationViewModelInterface
extension MyNavigationViewModel: MyNavigationViewModelInterface {
    func backButtonAction() {
        currentVM?.dismiss()
    }
    
    func playButtonAction() {
        mainViewDelegate?.playModeStart()
        currentVM?.playButtonAction()
    }
}
