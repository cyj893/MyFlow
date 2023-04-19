//
//  RadioComponetWrapperView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import UIKit


class RadioComponetWrapperView: UIView, RadioComponent {
    weak var delegate: RadioButtonDelegate?
    
    var selectClosure: () -> () = {}
    var deselectClosure: () -> () = {}
    
    let id: Int
    var isSelected = false
    
    init(id: Int, subview: UIView, selectClosure: @escaping () -> (), deselectClosure: @escaping () -> ()) {
        self.id = id
        self.selectClosure = selectClosure
        self.deselectClosure = deselectClosure
        
        super.init(frame: .zero)
        
        addSubview(subview)
        subview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        isSelected = true
        selectClosure()
    }
    
    func deselect() {
        isSelected = false
        deselectClosure()
    }
}

extension RadioComponetWrapperView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let presentationFrame = layer.presentation()!.frame
        let convertedPoint = self.convert(point, to: superview!)
        
        if presentationFrame.contains(convertedPoint) {
            if !isSelected {
                isSelected.toggle()
                delegate?.selected(id)
            }
            return super.hitTest(point, with: event)
        }
        return nil
    }
}
