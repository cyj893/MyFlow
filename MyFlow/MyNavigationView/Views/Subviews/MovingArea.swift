//
//  MovingArea.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


protocol MovingAreaDelegate {
    func nextPointButtonAction()
    func prevPointButtonAction()
}


final class MovingArea: UIStackView {
    
    var delegate: MovingAreaDelegate?
    
    private let prevPointButton = UIButton().then {
        $0.setIconStyle(systemName: "backward.frame")
    }
    
    private let nextPointButton = UIButton().then {
        $0.setIconStyle(systemName: "forward.frame")
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


extension MovingArea {
    private func setView() {
        addArrangedSubview(prevPointButton)
        addArrangedSubview(nextPointButton)
    }
    
    private func setAction() {
        setPrevPointButton()
        setNextPointButton()
    }
}


extension MovingArea {
    fileprivate func setNextPointButton() {
        nextPointButton.addAction {  [unowned self] in
            self.delegate?.nextPointButtonAction()
        }
    }
    
    fileprivate func setPrevPointButton() {
        prevPointButton.addAction {  [unowned self] in
            self.delegate?.prevPointButtonAction()
        }
    }
}
