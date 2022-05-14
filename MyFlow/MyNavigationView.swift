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
    
    let someOptionButton = UIButton()
    var isSomeOptionTrue: Bool = false
    
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
        
        self.addSubview(someOptionButton)
        someOptionButton.then {
            $0.setIconStyle(systemName: "rectangle.stack.badge.plus")
            $0.setIconStyle(systemName: "rectangle.stack.fill.badge.plus", tintColor: .orange, forState: .selected)
        }.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIcon)
            $0.centerY.equalToSuperview()
        }
        someOptionButton.addTarget(self, action: #selector(setSomeOption), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    
    @objc func setSomeOption() {
        print("옵션")
        someOptionButton.toggleIconWithTransition()
        isSomeOptionTrue = someOptionButton.isSelected
    }
    
}
