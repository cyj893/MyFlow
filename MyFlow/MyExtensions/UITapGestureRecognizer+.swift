//
//  UITapGestureRecognizer+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit

final class UITapGestureRecognizerWithClosure: UITapGestureRecognizer {
    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
