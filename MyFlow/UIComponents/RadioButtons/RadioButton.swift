//
//  RadioButton.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit
import Then
import SnapKit


protocol RadioButtonDelegate: NSObject {
    func selected(_ id: Int)
}


final class RadioButton: UIView {
    var isSelected = false
    
    let id: Int
    let labelText: String
    let content: UIView?
    
    weak var delegate: RadioButtonDelegate?
    
    lazy var stackView = UIStackView()
    var buttonShape: RadioButtonShape
    lazy var label = UILabel()
    
    init(id: Int, label: String, with content: UIView? = nil, size: RadioButtonShape.Size) {
        self.id = id
        self.labelText = label
        self.content = content
        buttonShape = RadioButtonShape(size: size)
        
        super.init(frame: .zero)
        
        addSubviews()
        setViews()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let presentationFrame = layer.presentation()!.frame
        let convertedPoint = self.convert(point, to: superview!)
        
        if presentationFrame.contains(convertedPoint) { return self }
        return nil
    }
}


// MARK: Views
extension RadioButton {
    private func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(buttonShape)
        stackView.addArrangedSubview(label)
    }
    
    private func setViews() {
        setStackView()
        setLabel()
        setContentIfNeeded()
    }
    
    private func configure() {
        addGestureRecognizer(UITapGestureRecognizerWithClosure { [unowned self] in
            if isSelected { return }
            isSelected.toggle()
            delegate?.selected(id)
        })
        
#if DEBUG
        stackView.backgroundColor = .systemOrange
#endif
    }
    
    private func setStackView() {
        stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = MyOffset.padding
            $0.distribution = .fill
        }.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    private func setLabel() {
        label.text = labelText
        label.setBodyStyle()
    }
    
    private func setContentIfNeeded() {
        if let content = content {
            addSubview(content)
            content.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom).offset(MyOffset.smallPadding)
            }
        } else {
            stackView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
    }
}


extension RadioButton {
    func select() {
        isSelected = true
        buttonShape.select()
    }
    
    func deselect() {
        isSelected = false
        buttonShape.deselect()
    }
}
