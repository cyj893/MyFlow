//
//  NowPointView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


class NowPointView: UIView {
    
    lazy var label = UILabel()
    var pointNum = 1
    
    
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        
        setView()
        setLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        addInnerShadow()
    }
    
    func setPointNum(with num: Int) {
        pointNum = num
        label.text = "\(pointNum)"
    }
}


// MARK: Views
extension NowPointView {
    
    private func setView() {
        layer.cornerRadius = 5
        backgroundColor = MyColor.secondaryNavigationBackground
    }
    
    private func setLabel() {
        label.then {
            $0.tintColor = .label
            $0.text = "\(pointNum)"
            $0.textAlignment = .center
        }.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(30.0)
        }
    }
    
}
