//
//  TrueDepthThresholdSettingView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/22.
//

import UIKit
import Then
import SnapKit


final class TrueDepthThresholdSettingView: UIViewController, AnimatableGradientBackground {
    
    let trueDepthHelper = TrueDepthHelper()
    
    lazy var stackView = UIStackView()
    lazy var backButton = UIButton()
    lazy var saveButton = UIButton()
    
    
    lazy var detectedLabel = UILabel()
    lazy var slider = UISlider()
    
    
#if DEBUG
    lazy var valueLabel = UILabel()
#endif
    
    let gradientLayer = CAGradientLayer()
    
    var nowThreshold: Float = UserDefaults.trueDepthThreshold
    var isFarAway = false
    
    override func viewDidLoad() {
        trueDepthHelper.delegate = self
        
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
extension TrueDepthThresholdSettingView {
    private func addSubviews() {
        view.addSubview(detectedLabel)
        view.addSubview(slider)
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(saveButton)
        
#if DEBUG
        view.addSubview(valueLabel)
#endif
    }
    
    private func setViews() {
        setStackView()
        setBackButton()
        setDetectedLabel()
        setSlider()
        setSaveButton()
        
#if DEBUG
        setValueLabel()
#endif
    }
    
    private func configure() {
        view.clipsToBounds = true
        view.backgroundColor = MyColor.pageSheetBackground
        
        backButton.addAction { [unowned self] in
            self.dismiss(animated: true)
        }
        saveButton.addAction { [unowned self] in
            UserDefaults.trueDepthThreshold = nowThreshold
            self.dismiss(animated: true)
        }
        
        slider.addAction(for: .valueChanged) { [unowned self] in
            nowThreshold = slider.value
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
    
    private func setDetectedLabel() {
        detectedLabel.then {
            $0.text = "Detected"
            $0.setSeconderyHeaderStyle()
            $0.textAlignment = .center
        }.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setSlider() {
        slider.then {
            $0.minimumValue = 0.0
            $0.maximumValue = 300.0
            $0.value = nowThreshold
        }.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    private func setBackButton() {
        backButton.setIconStyle(systemName: "chevron.left")
    }
    
    private func setSaveButton() {
        saveButton.setIconStyle(systemName: "checkmark")
    }
    
#if DEBUG
    private func setValueLabel() {
        valueLabel.then {
            $0.setSeconderyHeaderStyle()
            $0.backgroundColor = .systemOrange
        }.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
    }
#endif
    
}


// MARK: Actions
extension TrueDepthThresholdSettingView: TrueDepthHelperDelegate {
    func depthDataAverageOutput(_ average: Float) {
#if DEBUG
        DispatchQueue.main.async { [weak self] in
            self?.valueLabel.text = "DepthData Average: \(average)cm\nnowThreshold: \(self?.nowThreshold ?? 0)cm"
        }
#endif
        if Float(average) > nowThreshold && !isFarAway {
            isFarAway = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: AnimateDuration.normal, delay: 0) { [unowned self] in
                    self.detectedLabel.alpha = 0.0
                }
                CATransaction.begin()
                CATransaction.setAnimationDuration(AnimateDuration.normal)
                self.gradientLayer.opacity = 0.3
                CATransaction.commit()
            }
        } else if Float(average) < nowThreshold && isFarAway {
            isFarAway = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: AnimateDuration.normal, delay: 0) { [unowned self] in
                    self.detectedLabel.alpha = 1.0
                }
                CATransaction.begin()
                CATransaction.setAnimationDuration(AnimateDuration.normal)
                self.gradientLayer.opacity = 0.8
                CATransaction.commit()
            }
        }
    }
}
