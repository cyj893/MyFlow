//
//  MyNavigationView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import Then
import SnapKit
import PDFKit

class MyNavigationView: UIView {
    static let singletonView = MyNavigationView()
    
    var mainViewDelegate: MainViewDelegate?
    var currentVM: DocumentViewModelInterface?
    
    private let backButton = UIButton()
    
    private let undoRedoArea = UndoRedoArea()
    private let pointsArea = PointsArea()
    private let movingArea = MovingArea()
    
    private let playButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = MyColor.navigationBackground
        
        snp.makeConstraints {
            $0.height.equalTo(MyOffset.navigationViewHeight + MyOffset.topPadding)
        }
        
        setButtons()
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    
    func clear() {
        currentVM = nil
        pointsArea.clear()
    }
    
    // MARK: Setting Buttons
    
    fileprivate func setButtons() {
        setBackButton()
        setPlayButton()
        setAreas()
        [backButton, playButton].forEach {
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
            }
        }
    }
    
    fileprivate func setBackButton() {
        self.addSubview(backButton)
        backButton.then {
            $0.setIconStyle(systemName: "chevron.left")
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(MyOffset.betweenIcon)
        }
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setPlayButton() {
        self.addSubview(playButton)
        playButton.then {
            $0.setIconStyle(systemName: "play.fill", tintColor: .green)
        }.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-MyOffset.betweenIcon)
        }
        playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setAreas() {
        [movingArea, pointsArea, undoRedoArea].forEach { area in
            addSubview(area)
            area.then {
                $0.axis = .horizontal
                $0.spacing = MyOffset.betweenIcon
            }.snp.makeConstraints { make in
                make.centerY.equalTo(playButton)
            }
        }
        
        setMovingArea()
        setPointsArea()
        setUndoRedoArea()
    }
    
    
    // MARK: Button Actions
    
    @objc fileprivate func backButtonAction() {
        currentVM?.dismiss()
    }
    
    @objc fileprivate func playButtonAction() {
        mainViewDelegate?.playModeStart()
        currentVM?.playButtonAction()
    }
    
}


// MARK: Views - Set Moving Area
extension MyNavigationView: MovingAreaDelegate {
    
    private func setMovingArea() {
        movingArea.delegate = self
        movingArea.snp.makeConstraints { make in
            make.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    func prevPointButtonAction() {
        currentVM?.moveToPrevPoint()
    }
    
    func nextPointButtonAction() {
        currentVM?.moveToNextPoint()
    }
    
}


// MARK: Views - Set Points Area
extension MyNavigationView: PointsAreaDelegate {
    
    private func setPointsArea() {
        pointsArea.delegate = self
        pointsArea.snp.makeConstraints { make in
            make.trailing.equalTo(movingArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    func addPointsPagesButtonAction() {
        currentVM?.showAddPointsModalView()
    }
    
    func toggleAddingPointsMode(_ isAddingPoints: Bool, _ isHandlingPoints: Bool) {
        if isHandlingPoints {
            pointsArea.toggleHandlePointButton()
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
            pointsArea.toggleAddPointsButton()
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


// MARK: Views - Set Undo Redo Area
extension MyNavigationView: UndoRedoAreaDelegate {
    
    private func setUndoRedoArea() {
        undoRedoArea.delegate = self
        undoRedoArea.snp.makeConstraints { make in
            make.trailing.equalTo(pointsArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    func redoButtonAction() {
        currentVM?.redo()
    }
    
    func undoButtonAction() {
        currentVM?.undo()
    }
    
}
