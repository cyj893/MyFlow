//
//  PlayModeTapAreaSettingViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit
import Then
import SnapKit


final class PlayModeTapAreaSettingView: UIViewController, AnimatableGradientBackground {
    
    typealias Axis = PlayModeState.TapAreaAxis
    
    lazy var stackView = UIStackView()
    
    lazy var backButton = UIButton()
    lazy var radioStackView = UIStackView()
    var radioButtons: RadioButtons?
    lazy var saveButton = UIButton()
    
    
    lazy var horizontalLine = HorizontalLineView()
    lazy var verticalLine = VerticalLineView()
    
    let gradientLayer = CAGradientLayer()
    
    var nowAxis = Axis(rawValue: UserDefaults.playModeTapAreaAxis) ?? .horizontal
    var nowLength = [UIScreen.main.bounds.width / 2.0, UIScreen.main.bounds.height / 2.0]
    
    
    override func viewDidLoad() {
        nowLength[nowAxis.rawValue] = UserDefaults.playModeTapAreaLength
        
        radioButtons = RadioButtons(labels: ["Horizontal", "Vertical"],
                                    defaultID: UserDefaults.playModeTapAreaAxis,
                                    selectAction: { [unowned self] id in
            changePlayModeTapArea(id)
        })
        
        super.viewDidLoad()
        
        setGradientLayer()
        view.layer.addSublayer(gradientLayer)
        
        addSubviews()
        setViews()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateGradient()
    }
    
}


// MARK: Views
extension PlayModeTapAreaSettingView {
    private func addSubviews() {
        view.addSubview(horizontalLine)
        view.addSubview(verticalLine)
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(radioStackView)
        stackView.addArrangedSubview(saveButton)
        
        if let radioButtons = radioButtons {
            radioButtons.buttons.forEach { button in
                radioStackView.addArrangedSubview(button)
            }
        }
    }
    
    private func setViews() {
        setLines()
        setStackView()
        setBackButton()
        setRadioStackView()
        setSaveButton()
    }
    
    private func configure() {
        view.clipsToBounds = true
        view.backgroundColor = MyColor.pageSheetBackground
        
        view.addGestureRecognizer(UIPanGestureRecognizerWithClosure { [unowned self] sender in
            let transition = sender.translation(in: view)
            switch nowAxis {
            case .horizontal:
                let nextX = min(UIScreen.main.bounds.width, max(0, horizontalLine.center.x + transition.x))
                horizontalLine.center = CGPoint(x: nextX, y: horizontalLine.center.y)
                nowLength[Axis.horizontal.rawValue] = nextX
            case .vertical:
                let nextY = min(UIScreen.main.bounds.height, max(0, verticalLine.center.y + transition.y))
                verticalLine.center = CGPoint(x: verticalLine.center.x, y: nextY)
                nowLength[Axis.vertical.rawValue] = nextY
            }
            sender.setTranslation(.zero, in: view)
        })
        
        backButton.addAction { [unowned self] in
            self.dismiss(animated: true)
        }
        saveButton.addAction { [unowned self] in
            UserDefaults.playModeTapAreaAxis = nowAxis.rawValue
            UserDefaults.playModeTapAreaLength = nowLength[nowAxis.rawValue]
            self.dismiss(animated: true)
        }
    }
    
    private func setStackView() {
        stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.backgroundColor = .black.withAlphaComponent(0.1)
            $0.layoutMargins = UIEdgeInsets(top: MyOffset.topPadding, left: MyOffset.topPadding, bottom: MyOffset.topPadding, right: MyOffset.topPadding)
            $0.isLayoutMarginsRelativeArrangement = true
        }.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    private func setRadioStackView() {
        radioStackView.axis = .horizontal
        radioStackView.alignment = .fill
        radioStackView.spacing = MyOffset.padding * 2.0
        radioStackView.distribution = .fillEqually
    }
    
    private func setBackButton() {
        backButton.setIconStyle(systemName: "chevron.left")
    }
    
    private func setSaveButton() {
        saveButton.setIconStyle(systemName: "checkmark")
    }
    
    private func setLines() {
        setHorizontalLineConstraint()
        setVerticalLineConstraint()
        
        switch nowAxis {
        case .horizontal:
            hideVerticalLine()
        case .vertical:
            hideHorizontalLine()
        }
    }
    
    private func setHorizontalLineConstraint() {
        horizontalLine.snp.makeConstraints { make in
            make.centerX.equalTo(nowLength[Axis.horizontal.rawValue])
            make.centerY.equalToSuperview()
        }
    }
    
    private func setVerticalLineConstraint() {
        verticalLine.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(nowLength[Axis.vertical.rawValue])
        }
    }
}

// MARK: Actions
extension PlayModeTapAreaSettingView {
    private func changePlayModeTapArea(_ id: Int) {
        switch id {
        case Axis.horizontal.rawValue:
            changeToHorizontalLine()
        case Axis.vertical.rawValue:
            changeToVerticalLine()
        default: break
        }
    }
    
    private func hideHorizontalLine() {
        horizontalLine.snp.updateConstraints { make in
            make.centerX.equalTo(nowLength[Axis.horizontal.rawValue] - UIScreen.main.bounds.width)
        }
    }
    
    private func hideVerticalLine() {
        verticalLine.snp.updateConstraints { make in
            make.centerY.equalTo(nowLength[Axis.vertical.rawValue] - UIScreen.main.bounds.height)
        }
    }
    
    private func showHorizontalLine() {
        horizontalLine.snp.updateConstraints { make in
            make.centerX.equalTo(nowLength[Axis.horizontal.rawValue])
        }
    }
    
    private func showVerticalLine() {
        verticalLine.snp.updateConstraints { make in
            make.centerY.equalTo(nowLength[Axis.vertical.rawValue])
        }
    }
    
    private func changeToHorizontalLine() {
        nowAxis = .horizontal
        hideVerticalLine()
        showHorizontalLine()
        UIView.animate(withDuration: AnimateDuration.normal, delay: 0, options: .curveEaseIn) { [unowned self] in
            view.layoutIfNeeded()
        }
    }
    
    private func changeToVerticalLine() {
        nowAxis = .vertical
        hideHorizontalLine()
        showVerticalLine()
        UIView.animate(withDuration: AnimateDuration.normal, delay: 0, options: .curveEaseIn) { [unowned self] in
            view.layoutIfNeeded()
        }
    }
}
