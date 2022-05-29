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
    lazy var orderLabel = UILabel()
    private var pointNumberHeight: Int = 30
        
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
        thumbnailView.then{
            $0.layer.borderColor = MyColor.borderColor?.cgColor
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailCell.addSubview(orderLabel)
        orderLabel.then {
            $0.text = " "
            $0.font = MyFont.middle
            $0.textAlignment = .center
            $0.backgroundColor = .gray.withAlphaComponent(0.5)
            $0.layer.cornerRadius = MyFont.sizeMiddle.height/2
            $0.layer.masksToBounds = true
        }.snp.makeConstraints {
            $0.width.equalTo(MyFont.sizeMiddle.width * 1.5)
            $0.trailing.bottom.equalToSuperview().offset(-10)
        }
    }
    
}
