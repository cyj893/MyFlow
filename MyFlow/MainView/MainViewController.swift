//
//  MainViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


final class MainViewController: UIViewController {
    
    let myNavigationView = MyNavigationView.singletonView
    var isNaviShowing = true
    
    var documentArea = UIView()
    var documentViews: [DocumentViewController]
    var nowIndex = 0
    
    private let endPlayModeButton = UIButton()
    
    
    // MARK: LifeCycle
    init(initialVC: DocumentViewController) {
        documentViews = [initialVC]
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMyNavigationView()
        setDocumentView()
        
        setEndPlayModeButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        myNavigationView.clear()
        documentViews = []
    }
}


// MARK: Views
extension MainViewController {
    private func setMyNavigationView() {
        myNavigationView.currentVM = documentViews[nowIndex].viewModel
        view.addSubview(myNavigationView)
        myNavigationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
    }
    
    private func setDocumentView() {
        view.addSubview(documentArea)
        documentArea.snp.makeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        addChild(documentViews[nowIndex])
        documentViews[nowIndex].view.frame = documentArea.frame
        documentArea.addSubview(documentViews[nowIndex].view)
    }
    
    private func setEndPlayModeButton() {
        view.addSubview(endPlayModeButton)
        endPlayModeButton.then {
            $0.setIconStyle(systemName: "stop.circle", tintColor: .gray.withAlphaComponent(0.5))
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MyOffset.betweenIconGroup)
            $0.right.equalToSuperview().offset(-MyOffset.betweenIconGroup)
        }
        endPlayModeButton.addTarget(self, action: #selector(endPlayMode), for: .touchUpInside)
        endPlayModeButton.isHidden = true
    }
    
}


// MARK: Action
extension MainViewController {
    
    @objc func endPlayMode() {
        documentViews[nowIndex].viewModel?.changeState(to: .normal)
        showNavi()
        endPlayModeButton.isHidden = true
    }
    
    /// hide`MyNavigationView`
    private func hideNavi() {
        print("hide myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        documentArea.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animateIt()
    }
    
    /// show `MyNavigationView`
    private func showNavi() {
        print("show myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        documentArea.snp.remakeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        animateIt()
    }
    
    /// Configurate and animate for `MyNavigationView`
    private func animateIt() {
        UIView.animate(
            withDuration: 0.5,
            animations: view.layoutIfNeeded
        )
    }
    
}
