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
    
    
    private let undoRedoArea = UIStackView()
    private let undoButton = UIButton()
    private let redoButton = UIButton()
    
    private let pointsArea = UIStackView()
    private let addPointsPagesButton = UIButton()
    private let addPointsButton = UIButton()
    private let deleteButton = UIButton()
    private let handlePointButton = UIButton()
    
    private let movingArea = UIStackView()
    private let prevPointButton = UIButton()
    private let nextPointButton = UIButton()
    
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
    
    
    // MARK: Getter, Setter
    
    func getIsAddingPoints() -> Bool { addPointsButton.isSelected }
    func getIsHandlingPoints() -> Bool { handlePointButton.isSelected }
    
    
    func clear() {
        currentVM = nil
        addPointsButton.isSelected = false
        handlePointButton.isSelected = false
    }
    
    // MARK: Setting Buttons
    
    fileprivate func setButtons() {
        setBackButton()
        setPlayButton()
        setPointsButtons()
        [backButton, playButton, undoButton, redoButton, deleteButton, addPointsPagesButton, prevPointButton, addPointsButton, nextPointButton, handlePointButton].forEach {
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
    
    fileprivate func setPointsButtons() {
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
    
    @objc fileprivate func toggleAddingPointsMode() {
        addPointsButton.toggleIconWithTransition()
        if getIsAddingPoints() {
            print("포인트 추가")
            currentVM?.changeState(to: .addPoints)
        }
        else {
            print("포인트 추가 끝")
            currentVM?.changeState(to: .normal)
        }
        if getIsHandlingPoints() {
            handlePointButton.toggleIconWithTransition()
            currentVM?.clearSelectedPoint()
        }
    }
    
    @objc fileprivate func toggleHandlingPointsMode() {
        handlePointButton.toggleIconWithTransition()
        if getIsHandlingPoints() {
            print("포인트 핸들링")
            currentVM?.changeState(to: .handlePoints)
        }
        else {
            print("포인트 핸들링 끝")
            currentVM?.changeState(to: .normal)
            currentVM?.clearSelectedPoint()
        }
        if getIsAddingPoints() { addPointsButton.toggleIconWithTransition() }
    }
    
    @objc fileprivate func prevPointButtonAction() {
        currentVM?.moveToPrevPoint()
    }
    
    @objc fileprivate func nextPointButtonAction() {
        currentVM?.moveToNextPoint()
    }
    
    @objc fileprivate func addPointsPagesButtonAction() {
        currentVM?.showAddPointsModalView()
    }
    
    @objc fileprivate func deleteButtonAction() {
        currentVM?.deletePoint()
    }
    
    @objc fileprivate func redoButtonAction() {
        currentVM?.redo()
    }
    
    @objc fileprivate func undoButtonAction() {
        currentVM?.undo()
    }
    
    @objc fileprivate func playButtonAction() {
        mainViewDelegate?.playModeStart()
        currentVM?.playButtonAction()
    }
    
}


// MARK: Views - Set Moving Area
extension MyNavigationView {
    
    private func setMovingArea() {
        movingArea.snp.makeConstraints { make in
            make.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        
        movingArea.addArrangedSubview(prevPointButton)
        movingArea.addArrangedSubview(nextPointButton)
        
        setPrevPointButton()
        setNextPointButton()
    }
    
    fileprivate func setNextPointButton() {
        nextPointButton.then {
            $0.setIconStyle(systemName: "forward.frame")
        }
        nextPointButton.addTarget(self, action: #selector(nextPointButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setPrevPointButton() {
        prevPointButton.then {
            $0.setIconStyle(systemName: "backward.frame")
        }
        prevPointButton.addTarget(self, action: #selector(prevPointButtonAction), for: .touchUpInside)
    }
    
}


// MARK: Views - Set Points Area
extension MyNavigationView {
    
    private func setPointsArea() {
        pointsArea.snp.makeConstraints { make in
            make.trailing.equalTo(movingArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
        
        pointsArea.addArrangedSubview(addPointsPagesButton)
        pointsArea.addArrangedSubview(addPointsButton)
        pointsArea.addArrangedSubview(deleteButton)
        pointsArea.addArrangedSubview(handlePointButton)
        
        setAddPointsPagesButton()
        setAddPointsButton()
        setDeleteButton()
        setHandlePointButton()
    }
    
    private func setAddPointsPagesButton() {
        addPointsPagesButton.then {
            $0.setIconStyle(systemName: "plus.square.on.square")
            $0.setIconStyle(systemName: "plus.square.on.square.fill", forState: .selected)
        }
        addPointsPagesButton.addTarget(self, action: #selector(addPointsPagesButtonAction), for: .touchUpInside)
    }
    
    private func setAddPointsButton() {
        addPointsButton.then {
            $0.setIconStyle(systemName: "plus.app")
            $0.setIconStyle(systemName: "plus.app.fill", tintColor: .orange, forState: .selected)
        }
        addPointsButton.addTarget(self, action: #selector(toggleAddingPointsMode), for: .touchUpInside)
    }
    
    private func setDeleteButton() {
        deleteButton.then {
            $0.setIconStyle(systemName: "trash")
        }
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
    }
    
    private func setHandlePointButton() {
        handlePointButton.then {
            $0.setIconStyle(systemName: "hand.tap")
            $0.setIconStyle(systemName: "hand.tap.fill", forState: .selected)
        }
        handlePointButton.addTarget(self, action: #selector(toggleHandlingPointsMode), for: .touchUpInside)
    }
    
}


// MARK: Views - Set Undo Redo Area
extension MyNavigationView {
    
    private func setUndoRedoArea() {
        undoRedoArea.snp.makeConstraints { make in
            make.trailing.equalTo(pointsArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
        
        undoRedoArea.addArrangedSubview(undoButton)
        undoRedoArea.addArrangedSubview(redoButton)
        
        setUndoButton()
        setRedoButton()
    }
    
    fileprivate func setUndoButton() {
        undoButton.then {
            $0.setIconStyle(systemName: "arrow.uturn.backward")
        }
        undoButton.addTarget(self, action: #selector(undoButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setRedoButton() {
        redoButton.then {
            $0.setIconStyle(systemName: "arrow.uturn.forward")
        }
        redoButton.addTarget(self, action: #selector(redoButtonAction), for: .touchUpInside)
    }
    
}
