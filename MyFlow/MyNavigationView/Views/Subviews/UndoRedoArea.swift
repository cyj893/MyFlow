//
//  UndoRedoArea.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


protocol UndoRedoAreaDelegate {
    func undoButtonAction()
    func redoButtonAction()
}


final class UndoRedoArea: UIStackView {
    
    var delegate: UndoRedoAreaDelegate?
    
    private let undoButton = UIButton().then {
        $0.setIconStyle(systemName: "arrow.uturn.backward")
    }
    
    private let redoButton = UIButton().then {
        $0.setIconStyle(systemName: "arrow.uturn.forward")
    }
    
    init() {
        super.init(frame: .zero)
        
        setView()
        setAction()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension UndoRedoArea {
    private func setView() {
        addArrangedSubview(undoButton)
        addArrangedSubview(redoButton)
        
    }
    
    private func setAction() {
        setUndoButton()
        setRedoButton()
    }
}


extension UndoRedoArea {
    private func setUndoButton() {
        undoButton.addAction {  [unowned self] in
            self.delegate?.undoButtonAction()
        }
    }
    
    private func setRedoButton() {
        redoButton.addAction {  [unowned self] in
            self.delegate?.redoButtonAction()
        }
    }
}


extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping ()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
