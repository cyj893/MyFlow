//
//  LineViewStyle.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/20.
//

import UIKit
import SnapKit


class LineViewStyle: UIView {
    static let lineWidth: CGFloat = 1.0
    static let lineColor: CGColor = UIColor.systemMint.cgColor
    static let prevBackgroundColor: CGColor = UIColor.black.withAlphaComponent(0.2).cgColor
    
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height
    
    let prevLayer = CAShapeLayer()
    let lineLayer = CAShapeLayer()
    
    let prevLabel = UILabel()
    let nextLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setConstraint()
        setLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        snp.makeConstraints { make in
            make.width.equalTo(screenW)
            make.height.equalTo(screenH)
        }
    }
    
    private func setLabels() {
        prevLabel.text = "Area to move to the previous point"
        prevLabel.setSeconderyHeaderStyle()
        
        nextLabel.text = "Area to move to the next point"
        nextLabel.setSeconderyHeaderStyle()
    }
}
