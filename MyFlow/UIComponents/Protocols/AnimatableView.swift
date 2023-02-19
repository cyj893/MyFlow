//
//  AnimatableView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/19.
//

import UIKit


/// protocol about the view that perform the animation.
protocol AnimatableView: UIView {
    /// Starts animation.
    ///
    /// Call this function when need to start the animation, depending on the lifecycle, etc.
    func startAnimation()
    
    /// Stops animation.
    ///
    /// Call this function when need to stop the animation, depending on the lifecycle, etc.
    func stopAnimation()
}
