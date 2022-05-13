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
        
        self.addSubview(someOptionButton)
        someOptionButton.then {
            $0.setTitle("옵션", for: .normal)
            $0.backgroundColor = .cyan
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalTo(optionsView.snp.top).offset(30)
        }
        someOptionButton.addTarget(self, action: #selector(setSomeOption), for: .touchUpInside)
        
        self.addSubview(playButton)
        playButton.then {
            $0.setTitle("플레이", for: .normal)
            $0.backgroundColor = .cyan
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.top.equalTo(optionsView.snp.top).offset(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    @objc func setSomeOption() {
        print("옵션")
        isSomeOptionTrue = !isSomeOptionTrue
    }
    
}
