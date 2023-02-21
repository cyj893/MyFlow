//
//  RadioButtonShape.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit


final class RadioButtonShape: UIView {
    enum Size: CGFloat {
        case small = 25.0
        case middle = 30.0
        case big = 35.0
    }
    
    let innerShape = CAShapeLayer()
    private let selectedColor: UIColor
    private let deselectedColor: UIColor
    
    init(_ selectedColor: UIColor = .systemMint, _ deselectedColor: UIColor = .gray, size: Size) {
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        
        super.init(frame: .zero)
        
        snp.makeConstraints { make in
            make.width.height.equalTo(size.rawValue)
        }
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let length = frame.width
        layer.cornerRadius = length / 2.0
        
        let offset = length * 0.2 + 3.0
        let innerLength = length - 2.0 * offset
        
        innerShape.frame = .init(origin: CGPoint(x: offset, y: offset), size: CGSize(width: innerLength, height: innerLength))
        innerShape.cornerRadius = innerLength / 2.0
    }
}


// MARK: Views
extension RadioButtonShape {
    private func configure() {
        layer.borderWidth = 3.0
        layer.borderColor = deselectedColor.cgColor
        
        innerShape.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(innerShape)
    }
}


extension RadioButtonShape {
    func select() {
        UIView.transition(with: self, duration: AnimateDuration.veryFast) { [unowned self] in
            layer.borderColor = selectedColor.cgColor
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimateDuration.veryFast)
        innerShape.backgroundColor = selectedColor.cgColor
        CATransaction.commit()
    }
    
    func deselect() {
        UIView.transition(with: self, duration: AnimateDuration.veryFast) { [unowned self] in
            layer.borderColor = deselectedColor.cgColor
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimateDuration.veryFast)
        innerShape.backgroundColor = UIColor.clear.cgColor
        CATransaction.commit()
    }
}
