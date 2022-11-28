//
//  TabCell.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


extension TabCell {
    static let fontSize: CGFloat = 17.0
}

final class TabCell: UICollectionViewCell {
    lazy var label = UILabel()
    
    override var isSelected: Bool {
        willSet {
            self.setSelected(newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = MyColor.tabCell
        
        contentView.addSubview(label)
        label.font = .systemFont(ofSize: TabCell.fontSize, weight: .regular)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
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
