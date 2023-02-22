//
//  MoveStrategyAnimationView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/18.
//

import UIKit
import Then
import SnapKit


extension MoveStrategyAnimationView {
    static let pageHeight = 230.0
    static let pointHeight = 200.0
}


/// Shows the moving method according to MoveStrategy as an animation.
final class MoveStrategyAnimationView: UIView {
    let strategy: MoveStrategyType
    
    /// the white view that the sheet music is based on. It doesn't actually animate.
    lazy var pageView = UIView()
    
    /// the view that perform the animation.
    lazy var pointView = UIView()
    
    /// point layers in pointView.
    let points = (0..<3).map { _ in CAShapeLayer() }
    /// wireframe of sheet music layers in pointView.
    let wireframes = (0..<12).map { _ in CAShapeLayer() }
    
    init(_ strategy: MoveStrategyType) {
        self.strategy = strategy
        
        super.init(frame: .zero)
        
        addSubviews()
        setViews()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: LifeCycle
extension MoveStrategyAnimationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addInnerShadow(opacity: 1.0, radius: 5)
        makeSheetMusic()
    }
    
    /// Place the layers at regular intervals to create the shape of a sheet music.
    func makeSheetMusic() {
        points.enumerated().forEach { (i, point) in
            point.frame = .init(origin: CGPoint(x: 0, y: CGFloat(i) * MoveStrategyAnimationView.pointHeight), size: CGSize(width: pointView.frame.width, height: 5))
        }
        wireframes.enumerated().forEach { (i, wireframe) in
            if i % 4 == 0 {
                wireframe.frame = .init(origin: CGPoint(x: 0, y: CGFloat(i / 4 + 1) * MoveStrategyAnimationView.pageHeight), size: CGSize(width: pointView.frame.width, height: 10))
            } else {
                let pageOffset = 30.0 + CGFloat(i / 4) * MoveStrategyAnimationView.pageHeight
                let idxOffset = CGFloat(i % 4 - 1) * 60.0
                wireframe.frame = .init(origin: CGPoint(x: 10, y: pageOffset + idxOffset), size: CGSize(width: pointView.frame.width - 20, height: 40))
            }
        }
    }
}


// MARK: Views
extension MoveStrategyAnimationView {
    private func addSubviews() {
        addSubview(pageView)
        addSubview(pointView)
    }
    
    private func setViews() {
        setPageView()
        setPointView()
        setPointViewLayers()
    }
    
    private func configure() {
        snp.makeConstraints { make in
            make.height.equalTo(MoveStrategyAnimationView.pageHeight + 30)
        }
        layer.cornerRadius = 10
        backgroundColor = MyColor.pdfBackground
        clipsToBounds = true
    }
    
    private func setPageView() {
        pageView.then {
            $0.backgroundColor = .white
        }.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func setPointView() {
        pointView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(pageView)
        }
    }
    
    private func setPointViewLayers() {
        points.forEach { point in
            point.backgroundColor = UIColor.systemPink.cgColor
            pointView.layer.addSublayer(point)
        }
        wireframes.enumerated().forEach { (i, wireframe) in
            if i % 4 == 0 {
                wireframe.backgroundColor = MyColor.pdfBackground.cgColor
                pointView.layer.addSublayer(wireframe)
            } else {
                wireframe.backgroundColor = UIColor.gray.withAlphaComponent(0.3).cgColor
                wireframe.cornerRadius = 10.0
                pointView.layer.addSublayer(wireframe)
            }
        }
    }
}


extension MoveStrategyAnimationView: AnimatableView {
    func startAnimation() {
        let duration = strategy == .useScrollView ? 1.0/10.0 : 0.0
        UIView.animateKeyframes(withDuration: 5, delay: 0, options: [.repeat]) { [unowned self] in
            UIView.addKeyframe(withRelativeStartTime: 1.0/8.0,
                               relativeDuration: duration) { [unowned self] in
                pointView.frame = pointView.frame.offsetBy(dx: 0, dy: -MoveStrategyAnimationView.pointHeight)
            }
            UIView.addKeyframe(withRelativeStartTime: 4.0/8.0,
                               relativeDuration: duration) { [unowned self] in
                pointView.frame = pointView.frame.offsetBy(dx: 0, dy: -MoveStrategyAnimationView.pointHeight)
            }
            UIView.addKeyframe(withRelativeStartTime: 7.0/8.0,
                               relativeDuration: duration) { [unowned self] in
                pointView.frame = pointView.frame.offsetBy(dx: 0, dy: MoveStrategyAnimationView.pointHeight * 2)
            }
        }
    }
    
    func stopAnimation() {
        pointView.layer.removeAllAnimations()
    }
}
