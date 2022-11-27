//
//  TabCell.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


final class TabCell: UICollectionViewCell {
    lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .systemMint
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
