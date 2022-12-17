//
//  MyNavigationViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import Foundation


protocol MyNavigationViewDelegate: NSObject {
    func toggleHandlePointButton()
    func toggleAddPointsButton()
    func clearButtonState()
    func setPointNum(with num: Int)
}
