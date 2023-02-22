//
//  SettingViewStyle.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit


/// protocol about the standard settingView.
protocol SettingViewStyle {
    /// title of the setting.
    static var title: String { get }
    
    /// the label shows title.
    var titleLabel: UILabel { get }
    
    /// the content view that actually perform the setup.
    ///
    /// Can contain buttons, radio buttons, etc.
    var content: UIView { get }
    
    /// Set up a standard style.
    
    /// Set the style and constraints of the title and content.
    ///
    /// If needs to make different, it shouldn't be called.
    func setStandardStyle()
}

extension SettingViewStyle where Self: UIView {
    func setStandardStyle() {
        addStandardView()
        
        setStandardTitleLabel()
        setStandardContent()
    }
    
    private func addStandardView() {
        addSubview(titleLabel)
        addSubview(content)
    }
    
    private func setStandardTitleLabel() {
        titleLabel.then {
            $0.text = Self.title
            $0.setHeaderStyle()
        }.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(MyOffset.padding)
        }
    }
    
    private func setStandardContent() {
        content.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(MyOffset.padding)
            make.top.equalTo(titleLabel.snp.bottom).offset(MyOffset.padding)
        }
    }
}

