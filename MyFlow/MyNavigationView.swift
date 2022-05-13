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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(optionsView)
        optionsView.backgroundColor = .blue
        optionsView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        self.addSubview(backButton)
        backButton.then {
            $0.setTitle("뒤로", for: .normal)
            $0.backgroundColor = .cyan
        }.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(optionsView.snp.top).offset(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    @objc func backButtonAction() {
        print("clicked")
    }
    
}
