//
//  RadioButtons.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit
import Then
import SnapKit


final class RadioButtons: NSObject {
    var buttons: [RadioButton] = []
    private let selectAction: (Int) -> ()
    
    init(labels: [String],
         with contents: [UIView] = [],
         defaultID: Int,
         selectAction: @escaping (Int) -> ()) {
        self.selectAction = selectAction
        
        super.init()
        
        labels.enumerated().forEach { (id, label) in
            let button = contents.isEmpty ? RadioButton(id: id, label: label)
                                          : RadioButton(id: id, label: label, with: contents[id])
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
