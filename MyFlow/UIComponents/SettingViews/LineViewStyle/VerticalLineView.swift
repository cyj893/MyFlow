//
//  VerticalLineView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/20.
//

import UIKit


final class VerticalLineView: LineViewStyle {
    
    override init() {
        super.init()
        
        setLayers()
        setLabelsConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayers() {
        prevLayer.backgroundColor = LineViewStyle.prevBackgroundColor
        prevLayer.frame = CGRect(origin: CGPoint(x: 0, y: -screenH / 2.0),
                                 size: CGSize(width: screenW, height: screenH))
        layer.addSublayer(prevLayer)
        
        lineLayer.backgroundColor = LineViewStyle.lineColor
        lineLayer.frame = CGRect(origin: CGPoint(x: 0, y: (screenH - LineViewStyle.lineWidth) / 2.0),
                                 size: CGSize(width: screenW, height: LineViewStyle.lineWidth))
        layer.addSublayer(lineLayer)
    }
    
    private func setLabelsConstraint() {
        addSubview(prevLabel)
        addSubview(nextLabel)
        
        prevLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
        nextLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.5)
        }
    }
}
