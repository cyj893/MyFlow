//
//  ExpandableSettingViewStyle.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit


/// protocol about the expandable settingView. should conform `SettingViewStyle`.
protocol ExpandableSettingViewStyle: AnyObject, SettingViewStyle {
    /// current state of expansion.
    var isExpanded: Bool { get set }
    
    /// Set the expandable style.
    ///
    /// When folded, only the title is visible; when expanded, the contents are expanded.
    func setExpandable()
    
    /// Returns `UITapGestureRecognizer` with tab action.
    ///
    /// Override it if you need different behavior depending on the case.
    func getTapGesture() -> UITapGestureRecognizer
}


extension ExpandableSettingViewStyle where Self: UIView {
    func setExpandable() {
        content.clipsToBounds = true
        fold()
        addGestureRecognizer(getTapGesture())
    }
    
    /// This is the default behavior. Expands and collapses content according to the state.
    func getTapGesture() -> UITapGestureRecognizer {
        UITapGestureRecognizerWithClosure { [unowned self] in
            isExpanded.toggle()
            UIView.animate(withDuration: AnimateDuration.fast, delay: 0, options: .curveEaseOut) { [unowned self] in
                if isExpanded {
                    expand()
                } else {
                    fold()
                }
                superview?.superview?.layoutIfNeeded()
            }
        }
    }
    
    private func expand() {
        content.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(MyOffset.padding)
            make.top.equalTo(titleLabel.snp.bottom).offset(MyOffset.padding)
        }
        
        content.alpha = 1.0
        
        content.layer.transform = CATransform3DIdentity
    }
    
    private func fold() {
        content.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(MyOffset.padding)
            make.top.bottom.equalTo(titleLabel.snp.bottom).offset(MyOffset.padding)
        }
        
        content.alpha = 0.0
        
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0 / 200
        transform3D = CATransform3DRotate(transform3D, -(.pi / 4), 1, 0, 0)
        transform3D = CATransform3DTranslate(transform3D, 0, 30, -50)
        content.layer.transform = transform3D
    }
}


extension ExpandableSettingViewStyle where Self: AnimatableView {
    /// In case of `AnimatableView`, animation should be managed by completion.
    func getTapGesture() -> UITapGestureRecognizer {
        UITapGestureRecognizerWithClosure { [unowned self] in
            isExpanded.toggle()
            UIView.animate(withDuration: AnimateDuration.fast, delay: 0, options: .curveEaseOut) { [unowned self] in
                if isExpanded {
                    expand()
                } else {
                    fold()
                }
                superview?.superview?.layoutIfNeeded()
            } completion: { [unowned self] _ in
                if isExpanded {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
        }
    }
}

