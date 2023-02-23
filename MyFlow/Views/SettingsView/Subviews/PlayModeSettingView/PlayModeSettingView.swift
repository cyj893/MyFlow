//
//  PlayModeTapAreaSettingView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/20.
//

import UIKit
import Then
import SnapKit

import AVFoundation


protocol PlayModeSettingDelegate: NSObject {
    func present(_ vc: UIViewController)
}


extension PlayModeSettingView {
    static let title = "In PlayMode"
    static let autoScaleTitle = "Auto Scale When Start"
    static let tapAreaTitle = "Set Tap Area"
    static let trueDepthTitle = "Move to Next Point with Head Bowing"
    static let trueDepthBody = "You can move to the next point by lowering your head(get closer to the camera) and raising your head(move away from camera).\nA TrueDepth camera must be available."
    static let trueDepthSensitivityTitle = "Set Head Bowing Detection Sensitivity"
    
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
    var trueDepthLabel = SettingStackCell(title: PlayModeSettingView.trueDepthTitle,
                                          body: PlayModeSettingView.trueDepthBody,
                                          type: .toggleable(UserDefaults.useTrueDepth))
    var trueDepthSensitivityLabel = SettingStackCell(title: PlayModeSettingView.trueDepthSensitivityTitle,
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
        [autoScaleLabel, tapAreaLabel, trueDepthLabel, trueDepthSensitivityLabel].forEach { subview in
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
        if !UserDefaults.useTrueDepth {
            trueDepthSensitivityLabel.setState(with: .disabled)
        }
        
        autoScaleLabel.addToggleAction { isSelected in
            UserDefaults.playModeAutoScale = isSelected
        }
        tapAreaLabel.addTapAction { [unowned self] in
            let vc = PlayModeTapAreaSettingView()
            vc.modalPresentationStyle = .fullScreen
            self.delegate?.present(vc)
        }
        trueDepthLabel.addConditionalToggleAction { [unowned self] nowState in
            if nowState { // The user does not want to use
                UserDefaults.useTrueDepth = false
                trueDepthSensitivityLabel.setState(with: .disabled)
                return false
            }
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera
                UserDefaults.useTrueDepth = true
                trueDepthSensitivityLabel.setState(with: .activated)
                return true
            case .notDetermined: // The user has not yet been presented with the option to grant access
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                    if granted {
                        UserDefaults.useTrueDepth = granted
                        DispatchQueue.main.async { [weak self] in
                            self?.trueDepthLabel.updateToggleState(with: granted)
                        }
                    }
                })
                trueDepthSensitivityLabel.setState(with: .disabled)
                return false
            default: // The user has previously denied access
                delegate?.present(AlertMaker.trueDepthAlert())
                trueDepthSensitivityLabel.setState(with: .disabled)
                return false
            }
        }
        trueDepthSensitivityLabel.addTapAction { [unowned self] in
            let vc = TrueDepthThresholdSettingView()
            vc.modalPresentationStyle = .fullScreen
            self.delegate?.present(vc)
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
