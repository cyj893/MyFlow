//
//  TogglableButton.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit
import Then
import SnapKit


final class ToggleableButton: UIView {
    
    var isSelected = false
    
    var buttonShape: RadioButtonShape
    
    init(_ size: RadioButtonShape.Size = .middle) {
        buttonShape = RadioButtonShape(size: size)
        
        super.init(frame: .zero)
        
        addSubviews()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(action: @escaping (Bool) -> ()) {
        addGestureRecognizer(UITapGestureRecognizerWithClosure { [unowned self] in
            isSelected.toggle()
            action(isSelected)
        })
    }
}


// MARK: Views
extension ToggleableButton {
    private func addSubviews() {
        addSubview(buttonShape)
    }
    
    private func setViews() {
        setButtonView()
    }
    
    private func setButtonView() {
        buttonShape.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ToggleableButton {
    func toggle() {
        isSelected.toggle()
        if isSelected {
            buttonShape.select()
        } else {
            buttonShape.deselect()
        }
    }
    
    func select() {
        isSelected = true
        buttonShape.select()
    }
    
    func deselect() {
        isSelected = false
        buttonShape.deselect()
    }
}
