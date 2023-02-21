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

final class UIPanGestureRecognizerWithClosure: UIPanGestureRecognizer {
    private var action: (UIPanGestureRecognizer) -> Void

    init(action: @escaping (UIPanGestureRecognizer) -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute(_ sender: UIPanGestureRecognizer) {
        action(sender)
    }
}
