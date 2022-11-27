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
    static let singletonView = MyNavigationView()
    
    var viewModel = MyNavigationViewModel()
    
    private let backButton = UIButton()
    
    private let undoRedoArea = UndoRedoArea()
    private let pointsArea = PointsArea()
    private let movingArea = MovingArea()
    
    private let playButton = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        viewModel.delegate = self
        
        backgroundColor = MyColor.navigationBackground
        
        snp.makeConstraints {
            $0.height.equalTo(MyOffset.navigationViewHeight + MyOffset.topPadding)
        }
        
        setButtons()
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("storyboard only DocumentBrowserViewController")
    }
    
    
    func clear() {
        viewModel.clear()
        pointsArea.clear()
    }
    
}


// MARK: Views
extension MyNavigationView {
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
        self.addSubview(backButton)
        backButton.then {
            $0.setIconStyle(systemName: "chevron.left")
        }.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(MyOffset.betweenIcon)
        }
        backButton.addAction { [unowned self] in
            self.viewModel.backButtonAction()
        }
    }
    
    fileprivate func setPlayButton() {
        self.addSubview(playButton)
        playButton.then {
            $0.setIconStyle(systemName: "play.fill", tintColor: .green)
        }.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-MyOffset.betweenIcon)
        }
        playButton.addAction { [unowned self] in
            self.viewModel.playButtonAction()
        }
    }
    
    fileprivate func setAreas() {
        [movingArea, pointsArea, undoRedoArea].forEach { area in
            addSubview(area)
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
        movingArea.delegate = viewModel
        movingArea.snp.makeConstraints { make in
            make.trailing.equalTo(playButton.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    private func setPointsArea() {
        pointsArea.delegate = viewModel
        pointsArea.snp.makeConstraints { make in
            make.trailing.equalTo(movingArea.snp.leading).offset(-MyOffset.betweenIcon)
        }
    }
    
    private func setUndoRedoArea() {
        undoRedoArea.delegate = viewModel
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
