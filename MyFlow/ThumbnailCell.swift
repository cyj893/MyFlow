//
//  ThumbnailCell.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/26.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
    
    lazy var thumbnailCell = UIView()
    lazy var thumbnailView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("should not be in storyboard")
    }
    
    func setup() {
        contentView.addSubview(thumbnailCell)
        thumbnailCell.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        thumbnailCell.backgroundColor = .orange
        
        thumbnailCell.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
