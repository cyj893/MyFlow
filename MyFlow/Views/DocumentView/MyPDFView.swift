//
//  MyPDFView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/02.
//

import PDFKit

/// For disable selection.
/// Reference: https://stackoverflow.com/a/60377242
final class MyPDFView: PDFView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        self.currentSelection = nil
        self.clearSelection()

        return false
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }

        super.addGestureRecognizer(gestureRecognizer)
    }

}
