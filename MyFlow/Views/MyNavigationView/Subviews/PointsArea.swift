//
//  PointsArea.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


protocol PointsAreaDelegate {
    func addPointsPagesButtonAction()
    func toggleAddingPointsMode(_ isAddingPoints: Bool, _ isHandlingPoints: Bool)
    func deleteButtonAction()
    func toggleHandlingPointsMode(_ isHandlingPoints: Bool, _ isAddingPoints: Bool)
}


final class PointsArea: UIStackView {
    
    var delegate: PointsAreaDelegate?
    
    private let addPointsPagesButton = UIButton().then {
        $0.setIconStyle(systemName: "plus.square.on.square")
        $0.setIconStyle(systemName: "plus.square.on.square.fill", forState: .selected)
    }
    
    private let addPointsButton = UIButton().then {
        $0.setIconStyle(systemName: "plus.app")
        $0.setIconStyle(systemName: "plus.app.fill", tintColor: .orange, forState: .selected)
    }
    
    private let deleteButton = UIButton().then {
        $0.setIconStyle(systemName: "trash")
    }
    
    private let handlePointButton = UIButton().then {
        $0.setIconStyle(systemName: "hand.tap")
        $0.setIconStyle(systemName: "hand.tap.fill", forState: .selected)
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


extension PointsArea {
    func clear() {
        addPointsButton.isSelected = false
        handlePointButton.isSelected = false
    }
    
    func toggleAddPointsButton() {
        addPointsButton.toggleIconWithTransition()
    }
    
    func toggleHandlePointButton() {
        handlePointButton.toggleIconWithTransition()
    }
}


extension PointsArea {
    private func setView() {
        addArrangedSubview(addPointsPagesButton)
        addArrangedSubview(addPointsButton)
        addArrangedSubview(deleteButton)
        addArrangedSubview(handlePointButton)
    }
    
    private func setAction() {
        setAddPointsPagesButton()
        setAddPointsButton()
        setDeleteButton()
        setHandlePointButton()
    }
}


extension PointsArea {
    private func setAddPointsPagesButton() {
        addPointsPagesButton.addAction { [unowned self] in
            self.delegate?.addPointsPagesButtonAction()
        }
    }
    
    private func setAddPointsButton() {
        addPointsButton.addAction { [unowned self] in
            self.addPointsButton.toggleIconWithTransition()
            self.delegate?.toggleAddingPointsMode(self.addPointsButton.isSelected,
                                                  self.handlePointButton.isSelected)
        }
    }
    
    private func setDeleteButton() {
        deleteButton.addAction { [unowned self] in
            self.delegate?.deleteButtonAction()
        }
    }
    
    private func setHandlePointButton() {
        handlePointButton.addAction { [unowned self] in
            self.handlePointButton.toggleIconWithTransition()
            self.delegate?.toggleHandlingPointsMode(self.handlePointButton.isSelected,
                                                    self.addPointsButton.isSelected)
        }
    }
}
