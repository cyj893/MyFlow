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
    
    let optionsView = UIView()
    let backButton = UIButton()
    
    
    let handlePointButton = UIButton()
    let prevPointButton = UIButton()
    let addPointsButton = UIButton()
    let nextPointButton = UIButton()
    
    let playButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(optionsView)
        optionsView.backgroundColor = UIColor(named: "navigationBackgroundColor")
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
    
    
    // MARK: Setting Buttons
    fileprivate func setButtons() {
        setBackButton()
        setPlayButton()
        setPointsButtons()
        [backButton, playButton, prevPointButton, addPointsButton, nextPointButton, handlePointButton].forEach {
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
    }
    
    fileprivate func setPlayButton() {
        self.addSubview(playButton)
        playButton.then {
            $0.setIconStyle(systemName: "play.fill", tintColor: .green)
        }.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-MyOffset.betweenIcon)
        }
    }
    
    fileprivate func setPointsButtons() {
        setNextPointButton()
        setAddPointsButton()
        setPrevPointButton()
        setHandlePointButton()
    }
    
    fileprivate func setNextPointButton() {
        self.addSubview(nextPointButton)
        nextPointButton.then {
            $0.setIconStyle(systemName: "forward.frame")
        }.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIconGroup)
        }
    }
    
    fileprivate func setAddPointsButton() {
        self.addSubview(addPointsButton)
        addPointsButton.then {
            $0.setIconStyle(systemName: "rectangle.stack.badge.plus")
            $0.setIconStyle(systemName: "rectangle.stack.fill.badge.plus", tintColor: .orange, forState: .selected)
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
    }
    
    fileprivate func setHandlePointButton() {
        self.addSubview(handlePointButton)
        handlePointButton.then {
            $0.setIconStyle(systemName: "hand.raised")
        }.snp.makeConstraints {
            $0.trailing.equalTo(prevPointButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    
    // MARK: Button Actions
    @objc func toggleAddingPointsMode() {
        addPointsButton.toggleIconWithTransition()
        if getIsAddingPoints() { print("포인트 추가") }
        else { print("포인트 추가 끝") }
    }
    
}
