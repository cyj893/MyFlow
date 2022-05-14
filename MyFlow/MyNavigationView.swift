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
    
    
    let prevPointButton = UIButton()
    
    let addPointsButton = UIButton()
    var isAddingPoints: Bool = false
    
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
        
        self.addSubview(backButton)
        backButton.then {
            $0.setIconStyle(systemName: "chevron.left")
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(MyOffset.betweenIcon)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(playButton)
        playButton.then {
            $0.setIconStyle(systemName: "play.fill", tintColor: .green)
        }.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-MyOffset.betweenIcon)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(nextPointButton)
        nextPointButton.then {
            $0.setIconStyle(systemName: "forward.frame")
        }.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIconGroup)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(addPointsButton)
        addPointsButton.then {
            $0.setIconStyle(systemName: "rectangle.stack.badge.plus")
            $0.setIconStyle(systemName: "rectangle.stack.fill.badge.plus", tintColor: .orange, forState: .selected)
        }.snp.makeConstraints {
            $0.trailing.equalTo(nextPointButton.snp.leading).offset(-MyOffset.betweenIcon)
            $0.centerY.equalToSuperview()
        }
        addPointsButton.addTarget(self, action: #selector(toggleAddingPointsMode), for: .touchUpInside)
        
        self.addSubview(prevPointButton)
        prevPointButton.then {
            $0.setIconStyle(systemName: "backward.frame")
        }.snp.makeConstraints {
            $0.trailing.equalTo(addPointsButton.snp.leading).offset(-MyOffset.betweenIcon)
            $0.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    @objc func toggleAddingPointsMode() {
        addPointsButton.toggleIconWithTransition()
        isAddingPoints = addPointsButton.isSelected
        if isAddingPoints { print("포인트 추가") }
        else { print("포인트 추가 끝") }
    }
    
}
