//
//  TabCell.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit

import Then
import SnapKit


extension TabCell {
    static let fontSize: CGFloat = 17.0
    static let contentInset: CGFloat = 8.0
}


final class TabCell: UICollectionViewCell {
    
    lazy var label = UILabel().then {
        $0.textAlignment = .center
    }
    
    lazy var deleteButton = UIButton().then {
        $0.setIconStyle(systemName: "xmark", tintColor: MyColor.icon.withAlphaComponent(0.5), weight: .regular, scale: .small)
    }
    
    var deleteAction: (() -> ())?
    
    override var isSelected: Bool {
        willSet {
            self.setSelected(newValue)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setSelected(false)
        addViews()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setSelected(_ selected: Bool) {
        if selected {
            backgroundColor = MyColor.tabCellSelected
            label.font = .systemFont(ofSize: TabCell.fontSize, weight: .bold)
        } else {
            backgroundColor = MyColor.tabCell
            label.font = .systemFont(ofSize: TabCell.fontSize, weight: .regular)
        }
    }
}


extension TabCell {
    private func addViews() {
        contentView.addSubview(label)
        contentView.addSubview(deleteButton)
    }
    
    private func setViews() {
        setLabel()
        setDeleteButton()
    }
    
    private func setLabel() {
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(TabCell.contentInset)
            make.right.equalTo(deleteButton.snp.left).offset(-TabCell.contentInset)
        }
        label.setContentHuggingPriority(UILayoutPriority(250), for: .horizontal)
    }
    
    private func setDeleteButton() {
        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(TabCell.contentInset)
            make.centerY.equalToSuperview()
        }
        deleteButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        deleteButton.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        
        deleteButton.addAction { [weak self] in
            if let action = self?.deleteAction {
                action()
            }
        }
    }
}
