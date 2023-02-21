//
//  UIStackView+.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/21.
//

import UIKit


extension UIStackView {
    func addArrangedSubviewWithDivider(_ view: UIView) {
        addArrangedSubview(view)
        let divider = UIView.divider(axis == .horizontal ? .horizontal : .vertical)
        addArrangedSubview(divider)
        divider.snp.makeConstraints { make in
            (axis == .horizontal ? make.width : make.height).equalToSuperview()
        }
    }
}
