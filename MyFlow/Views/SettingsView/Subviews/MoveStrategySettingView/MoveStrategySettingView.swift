//
//  MoveStrategySettingView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit
import Then
import SnapKit


extension MoveStrategySettingView {
    static let USE_SCROLLVIEW_ID = 0
    static let USE_GO_ID = 1
    
    static let labels = ["Move with scrolling", "Just move"]
    
    static let title = "Style to Move"
    
    static func changeMoveStrategy(_ id: Int) {
        switch id {
        case MoveStrategySettingView.USE_SCROLLVIEW_ID:
            UserDefaults.moveStrategy = MoveStrategyType.useScrollView.rawValue
            NotificationCenter.default.post(name: NSNotification.Name(UserDefaults.Keys.moveStrategy.rawValue), object: nil, userInfo: nil)
        case MoveStrategySettingView.USE_GO_ID:
            UserDefaults.moveStrategy = MoveStrategyType.useGo.rawValue
            NotificationCenter.default.post(name: NSNotification.Name(UserDefaults.Keys.moveStrategy.rawValue), object: nil, userInfo: nil)
        default: break
        }
    }
}


final class MoveStrategySettingView: UIView, ExpandableSettingViewStyle {
    var isExpanded = false
    
    var titleLabel = UILabel()
    
    var content = UIView()
    var stackView = UIStackView()
    var animationViews = [MoveStrategyAnimationView(.useScrollView), MoveStrategyAnimationView(.useGo)]
    var radioButtons: RadioButtons
    
    init() {
        radioButtons = RadioButtons(labels: MoveStrategySettingView.labels,
                                    with: animationViews,
                                    defaultID: UserDefaults.moveStrategy) { id in
            MoveStrategySettingView.changeMoveStrategy(id)
        }
        
        super.init(frame: .zero)
        
        setStandardStyle()
        setExpandable()
        
        addSubviews()
        setViews()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: Views
extension MoveStrategySettingView {
    private func addSubviews() {
        content.addSubview(stackView)
        
        radioButtons.buttons.forEach { button in
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setViews() {
        setStackView()
    }
    
    private func configure() {
#if DEBUG
        titleLabel.backgroundColor = .systemCyan
        content.backgroundColor = .systemPink.withAlphaComponent(0.3)
#endif
    }
    
    private func setStackView() {
        stackView.then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.spacing = MyOffset.padding
            $0.distribution = .fillEqually
        }.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


extension MoveStrategySettingView: AnimatableView {
    func startAnimation() {
        animationViews.forEach { animationView in
            animationView.startAnimation()
        }
    }
    
    func stopAnimation() {
        animationViews.forEach { animationView in
            animationView.stopAnimation()
        }
    }
}
