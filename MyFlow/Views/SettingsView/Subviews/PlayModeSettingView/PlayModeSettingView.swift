//
//  PlayModeTapAreaSettingView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/20.
//

import UIKit
import Then
import SnapKit


extension PlayModeSettingView {
    static let title = "In PlayMode"
    static let autoScaleTitle = "Auto Scale When Start"
    
}

final class PlayModeSettingView: UIView, ExpandableSettingViewStyle {
    var isExpanded = false
    
    var titleView = UIView()
    var contentView = UIView()
    
    var titleLabel = UILabel()
    var content = UIView()
    
    var stackView = UIStackView()
    var autoScaleLabel = SettingStackCell(title: PlayModeSettingView.autoScaleTitle,
                                          type: .toggleable(UserDefaults.playModeAutoScale))
    
    
    init() {
        super.init(frame: .zero)
        
        setExpandableStyle()
        
        addSubviews()
        setViews()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: Views
extension PlayModeSettingView {
    private func addSubviews() {
        content.addSubview(stackView)
        [autoScaleLabel].forEach { subview in
            stackView.addArrangedSubviewWithDivider(subview)
        }
        stackView.arrangedSubviews.forEach { subview in
            subview.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }
    }
    
    private func setViews() {
        setStackView()
    }
    
    private func configure() {
        autoScaleLabel.addToggleAction { isSelected in
            UserDefaults.playModeAutoScale = isSelected
        }
        
#if DEBUG
        titleLabel.backgroundColor = .systemCyan
        content.backgroundColor = .systemPink.withAlphaComponent(0.3)
#endif
    }
    
    private func setStackView() {
        stackView.then {
            $0.axis = .vertical
            $0.alignment = .center
        }.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
