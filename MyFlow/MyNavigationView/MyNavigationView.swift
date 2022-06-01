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
    
    private var currentVC:DocumentViewController?
    private var currentPH:PointHelper?
    
    private let optionsView = UIView()
    private let backButton = UIButton()
    
    
    private let undoButton = UIButton()
    private let addPointsPagesButton = UIButton()
    private let handlePointButton = UIButton()
    private let prevPointButton = UIButton()
    private let addPointsButton = UIButton()
    private let nextPointButton = UIButton()
    
    private let playButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(optionsView)
        optionsView.backgroundColor = MyColor.navigationBackgroundColor
        optionsView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        setButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    
    // MARK: Getter, Setter
    
    func getIsAddingPoints() -> Bool { addPointsButton.isSelected }
    func getIsHandlingPoints() -> Bool { handlePointButton.isSelected }
    
    func setCurrentVC(viewController: DocumentViewController) { currentVC = viewController }
    func setCurrentPH(pointHelper: PointHelper) { currentPH = pointHelper }
    
    
    // MARK: Setting Buttons
    
    fileprivate func setButtons() {
        setBackButton()
        setPlayButton()
        setPointsButtons()
        [backButton, playButton, undoButton, addPointsPagesButton, prevPointButton, addPointsButton, nextPointButton, handlePointButton].forEach {
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
        setNextPointButton()
        setAddPointsButton()
        setPrevPointButton()
        setHandlePointButton()
        setAddPointsPagesButton()
        setUndoButton()
    }
    
    fileprivate func setNextPointButton() {
        self.addSubview(nextPointButton)
        nextPointButton.then {
            $0.setIconStyle(systemName: "forward.frame")
        }.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIconGroup)
        }
        nextPointButton.addTarget(self, action: #selector(nextPointButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setAddPointsButton() {
        self.addSubview(addPointsButton)
        addPointsButton.then {
            $0.setIconStyle(systemName: "plus.app")
            $0.setIconStyle(systemName: "plus.app.fill", tintColor: .orange, forState: .selected)
        }.snp.makeConstraints {
            $0.trailing.equalTo(nextPointButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        addPointsButton.addTarget(self, action: #selector(toggleAddingPointsMode), for: .touchUpInside)
    }
    
    fileprivate func setPrevPointButton() {
        self.addSubview(prevPointButton)
        prevPointButton.then {
            $0.setIconStyle(systemName: "backward.frame")
        }.snp.makeConstraints {
            $0.trailing.equalTo(addPointsButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        prevPointButton.addTarget(self, action: #selector(prevPointButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setHandlePointButton() {
        self.addSubview(handlePointButton)
        handlePointButton.then {
            $0.setIconStyle(systemName: "hand.tap")
            $0.setIconStyle(systemName: "hand.tap.fill", forState: .selected)
        }.snp.makeConstraints {
            $0.trailing.equalTo(prevPointButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        handlePointButton.addTarget(self, action: #selector(toggleHandlingPointsMode), for: .touchUpInside)
    }
    
    fileprivate func setAddPointsPagesButton() {
        self.addSubview(addPointsPagesButton)
        addPointsPagesButton.then {
            $0.setIconStyle(systemName: "plus.square.on.square")
            $0.setIconStyle(systemName: "plus.square.on.square.fill", forState: .selected)
        }.snp.makeConstraints {
            $0.trailing.equalTo(handlePointButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        addPointsPagesButton.addTarget(self, action: #selector(addPointsPagesButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setUndoButton() {
        self.addSubview(undoButton)
        undoButton.then {
            $0.setIconStyle(systemName: "arrow.uturn.backward")
        }.snp.makeConstraints {
            $0.trailing.equalTo(addPointsPagesButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
        undoButton.addTarget(self, action: #selector(undoButtonAction), for: .touchUpInside)
    }
    
    
    // MARK: Button Actions
    
    @objc fileprivate func backButtonAction() {
        guard let currentVC = currentVC else { return }
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func toggleAddingPointsMode() {
        addPointsButton.toggleIconWithTransition()
        if getIsAddingPoints() {
            print("포인트 추가")
            currentVC?.changeState(state: AddPointsState(vc: currentVC))
        }
        else {
            print("포인트 추가 끝")
            currentVC?.changeState(state: NormalState(vc: currentVC))
        }
        if getIsHandlingPoints() {
            handlePointButton.toggleIconWithTransition()
            clearSelectedPoint()
        }
    }
    
    @objc fileprivate func toggleHandlingPointsMode() {
        handlePointButton.toggleIconWithTransition()
        if getIsHandlingPoints() {
            print("포인트 핸들링")
            currentVC?.changeState(state: HandlePointsState(vc: currentVC))
        }
        else {
            print("포인트 핸들링 끝")
            currentVC?.changeState(state: NormalState(vc: currentVC))
            clearSelectedPoint()
        }
        if getIsAddingPoints() { addPointsButton.toggleIconWithTransition() }
    }
    
    @objc fileprivate func prevPointButtonAction() {
        guard let currentVC = currentVC else { return }
        currentVC.prevPointButtonAction()
    }
    
    @objc fileprivate func nextPointButtonAction() {
        guard let currentVC = currentVC else { return }
        currentVC.nextPointButtonAction()
    }
    
    @objc fileprivate func addPointsPagesButtonAction() {
        guard let currentVC = currentVC else { return }
        currentVC.showAddPointsModalView()
    }
    
    @objc fileprivate func undoButtonAction() {
        guard let currentPH = currentPH else { return }
        currentPH.undo()
    }
    
    @objc fileprivate func playButtonAction() {
        guard let currentVC = currentVC else { return }
        currentVC.playButtonAction()
    }
    
    
    fileprivate func clearSelectedPoint() {
        guard let currentPH = currentPH else { return }
        currentPH.clearSelectedPoint()
    }
    
    
}
