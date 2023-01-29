//
//  URL+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/30.
//

import Foundation

extension URL {
    var encodedPath: String {
        if #available(iOS 16.0, *) {
            return self.path()
        } else {
            return self.path
        }
    }
}
