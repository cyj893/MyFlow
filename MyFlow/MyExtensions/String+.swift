//
//  StringExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/17.
//

import UIKit

extension String {
    func sizeOfString( font: UIFont) -> CGSize {
        let fontAttribute = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttribute)
        return size;
    }
}
