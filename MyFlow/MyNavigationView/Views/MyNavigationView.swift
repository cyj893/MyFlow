//
//  MyNavigationView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import Then
import SnapKit
import PDFKit

class MyNavigationView: UIView {
    var viewModel = MyNavigationViewModel()
    
    private let backButton = UIButton()
    
    private let undoRedoArea = UndoRedoArea()
    private let pointsArea = PointsArea()
    private let movingArea = MovingArea()
    
    private let playButton = UIButton()
    
    let tabsAdaptor = DocumentTabsCollectionViewAdaptor()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubviews()
        setViews()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    
    func clear() {
        pointsArea.clear()
    }
    
}


// MARK: Views
extension MyNavigationView {
    private func addSubviews() {
        addSubview(backButton)
        addSubview(playButton)
        
        addSubview(movingArea)
        addSubview(pointsArea)
        addSubview(undoRedoArea)
        
        addSubview(tabsAdaptor.collectionView)
    }
    
    private func setViews() {
        backgroundColor = MyColor.navigationBackground
        
        snp.makeConstraints {
            $0.height.equalTo(MyOffset.navigationViewHeight + MyOffset.topPadding)
        }
        
        setTabsCollectionView()
        setButtons()
        addShadow()
    }
    
    private func configure() {
        viewModel.delegate = self
        
        backButton.addAction { [unowned self] in
            self.viewModel.backButtonAction()
        }
        playButton.addAction { [unowned self] in
            self.viewModel.playButtonAction()
        }
        
        movingArea.delegate = viewModel
        pointsArea.delegate = viewModel
        undoRedoArea.delegate = viewModel
    }
    
    fileprivate func setTabsCollectionView() {
        tabsAdaptor.collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    fileprivate func setButtons() {
        setBackButton()
        setPlayButton()
        setAreas()
        [backButton, playButton].forEach {
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
            }
        }
    }
    
    fileprivate func setBackButton() {
        backButton.then {
            $0.setIconStyle(systemName: "chevron.left")
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(MyOffset.betweenIcon)
        }
    }
    
    fileprivate func setPlayButton() {
        playButton.then {
            $0.setIconStyle(systemName: "play.fill", tintColor: .green)
        }.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-MyOffset.betweenIcon)
        }
    }
    
    fileprivate func setAreas() {
        [movingArea, pointsArea, undoRedoArea].forEach { area in
            area.then {
                $0.axis = .horizontal
                $0.spacing = MyOffset.betweenIcon
            }.snp.makeConstraints { make in
                make.centerY.equalTo(playButton)
            }
        }
        
        setMovingArea()
        setPointsArea()
        setUndoRedoArea()
    }
    
    private func setMovingArea() {
        movingArea.snp.makeConstraints { make in
            make.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    private func setPointsArea() {
        pointsArea.snp.makeConstraints { make in
            make.trailing.equalTo(movingArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    private func setUndoRedoArea() {
        undoRedoArea.snp.makeConstraints { make in
            make.trailing.equalTo(pointsArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
}


// MARK: MyNavigationViewDelegate
extension MyNavigationView: MyNavigationViewDelegate {
    func toggleHandlePointButton() {
        pointsArea.toggleHandlePointButton()
    }
    
    func toggleAddPointsButton() {
        pointsArea.toggleAddPointsButton()
    }
    
    func setPointNum(with num: Int) {
        movingArea.setPointNum(with: num)
    }
}
