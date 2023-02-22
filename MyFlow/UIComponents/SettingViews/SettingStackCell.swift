//
//  SettingStackCell.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit
import Then
import SnapKit


/// The view that defines the style of each cell used in the Setting's stackView.
final class SettingStackCell: UIView {
    
    enum CellType {
        /// Contains a toggle button. Takes the initial state as a parameter.
        case toggleable(Bool)
        /// Contains an icon image. Takes `systemName` as a parameter.
        case withIcon(String)
    }
    
    /// The title of the cell.
    let title: String
    
    lazy var label = UILabel()
    var typeView: UIView
    
    init(title: String, type: CellType) {
        self.title = title
        
        switch type {
        case .toggleable(let isSelected):
            let toggleButton = ToggleableButton(.small)
            typeView = toggleButton
            if isSelected {
                toggleButton.select()
            }
        case .withIcon(let systemName):
            let imageView = UIImageView(image: UIImage.withIconStyle(systemName: systemName))
            imageView.tintColor = MyColor.icon
            typeView = imageView
            break
        }
        
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
        addSubviews()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: Action
extension SettingStackCell {
    /// Add a tap action to the cell.
    func addTapAction(action: @escaping () -> ()) {
        addGestureRecognizer(UITapGestureRecognizerWithClosure {
            action()
        })
    }
    
    /// If the CellType is .togglable, the toggle action is performed on cells.
    func addToggleAction(action: @escaping (Bool) -> ()) {
        addGestureRecognizer(UITapGestureRecognizerWithClosure { [unowned self] in
            guard let toggleButton = typeView as? ToggleableButton else { return }
            toggleButton.toggle()
            action(toggleButton.isSelected)
        })
    }
}


// MARK: View
extension SettingStackCell {
    private func addSubviews() {
        addSubview(label)
        addSubview(typeView)
    }
    
    private func setViews() {
        setLabel()
        setTypeView()
        
#if DEBUG
        label.backgroundColor = .systemPink.withAlphaComponent(0.3)
        typeView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
#endif
    }
    
    private func setLabel() {
        label.then {
            $0.text = title
            $0.setSeconderyHeaderStyle()
        }.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(MyOffset.padding)
        }
    }
    
    private func setTypeView() {
        typeView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(MyOffset.padding)
            make.left.equalTo(label.snp.right).offset(MyOffset.padding)
        }
    }
}
