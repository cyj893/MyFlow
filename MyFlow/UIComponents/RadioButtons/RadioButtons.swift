//
//  RadioButtons.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit
import Then
import SnapKit


final class RadioButtons {
    var buttons: [RadioButton] = []
    private let selectAction: (Int) -> ()
    
    init(labels: [String],
         with contents: [UIView] = [],
         defaultID: Int,
         size: RadioButtonShape.Size = .middle,
         selectAction: @escaping (Int) -> ()) {
        self.selectAction = selectAction
        
        labels.enumerated().forEach { (id, label) in
            let button = contents.isEmpty ? RadioButton(id: id, label: label, size: size)
            : RadioButton(id: id, label: label, with: contents[id], size: size)
            button.delegate = self
            if id == defaultID {
                button.select()
            }
            buttons.append(button)
        }
    }
}


extension RadioButtons: RadioButtonDelegate {
    func selected(_ id: Int) {
        selectAction(id)
        buttons.enumerated().forEach { (i, button) in
            if i == id {
                button.select()
            } else {
                button.deselect()
            }
        }
    }
}
