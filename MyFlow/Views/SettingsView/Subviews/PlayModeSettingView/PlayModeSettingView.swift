//
//  PlayModeTapAreaSettingView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/20.
//

import UIKit
import Then
import SnapKit


protocol PlayModeSettingDelegate: NSObject {
    func showVcWithFullScreen(_ vc: UIViewController)
}


extension PlayModeSettingView {
    static let title = "In PlayMode"
    static let autoScaleTitle = "Auto Scale When Start"
    static let tapAreaTitle = "Set Tap Area"
    
}

final class PlayModeSettingView: UIView, ExpandableSettingViewStyle {
    weak var delegate: PlayModeSettingDelegate?
    
    var isExpanded = false
    
    var titleView = UIView()
    var contentView = UIView()
    
    var titleLabel = UILabel()
    var content = UIView()
    
    var stackView = UIStackView()
    var autoScaleLabel = SettingStackCell(title: PlayModeSettingView.autoScaleTitle,
                                          type: .toggleable(UserDefaults.playModeAutoScale))
    var tapAreaLabel = SettingStackCell(title: PlayModeSettingView.tapAreaTitle,
                                        type: .withIcon("chevron.right"))
    
    
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
        [autoScaleLabel, tapAreaLabel].forEach { subview in
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
        tapAreaLabel.addTapAction { [unowned self] in
            let vc = PlayModeTapAreaSettingView()
            self.delegate?.showVcWithFullScreen(vc)
        }
        
#if DEBUG
        titleLabel.backgroundColor = .systemCyan
        content.backgroundColor = .systemPink.withAlphaComponent(0.3)
        tapAreaLabel.backgroundColor = .systemBlue.withAlphaComponent(0.3)
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
