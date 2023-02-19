//
//  SettingsView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/15.
//

import UIKit


final class SettingsView: UIViewController {
    lazy var scrollView = UIScrollView()
    lazy var stackView = UIStackView()
    
    lazy var moveStrategySettingView = MoveStrategySettingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setViews()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveStrategySettingView.startAnimation()
    }
    
}


// MARK: Views
extension SettingsView {
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        [moveStrategySettingView].forEach { settingCell in
            stackView.addArrangedSubview(settingCell)
            stackView.addArrangedSubview(UIView.divider(.horizontal))
        }
        
        stackView.arrangedSubviews.forEach { subview in
            subview.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }
    }
    
    private func setViews() {
        setScrollView()
        setStackView()
        setCells()
    }
    
    private func configure() {
        view.backgroundColor = MyColor.pageSheetBackground
        
#if DEBUG
        scrollView.backgroundColor = .systemOrange.withAlphaComponent(0.3)
        moveStrategySettingView.backgroundColor = .systemCyan.withAlphaComponent(0.3)
#endif
    }
    
    private func setScrollView() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(MyOffset.padding)
        }
    }
    
    private func setStackView() {
        stackView.then {
            $0.axis = .vertical
            $0.alignment = .center
        }.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalToSuperview()
        }
    }
    
    private func setCells() {
        [moveStrategySettingView].forEach { settingCell in
            settingCell.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(50)
            }
        }
    }
}

