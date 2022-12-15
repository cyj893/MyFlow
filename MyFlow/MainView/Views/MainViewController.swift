//
//  MainViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


final class MainViewController: UIViewController {
    var viewModel = MainViewModel.shared
    
    let myNavigationView = MyNavigationView()
    var isNaviShowing = true
    
    var documentArea = UIView()
    
    private let endPlayModeButton = UIButton()
    
    
    // MARK: LifeCycle
    init(initialVC: DocumentViewController) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
        viewModel.openDocument(initialVC)
        myNavigationView.tabsAdaptor.dataSource = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleNavi), name: NSNotification.Name("ToggleNavi"), object: nil)
        
        view.addSubview(documentArea)
        view.addSubview(myNavigationView)
        
        setMyNavigationView()
        setDocumentView()
        
        setEndPlayModeButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ToggleNavi"), object: nil)
        myNavigationView.clear()
    }
}


// MARK: Views
extension MainViewController {
    private func setMyNavigationView() {
        myNavigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(MyOffset.navigationViewHeight)
        }
        myNavigationView.viewModel.mainViewDelegate = self
        myNavigationView.viewModel.currentVM = viewModel.getNowDocumentViewController().viewModel
    }
    
    private func setDocumentView() {
        documentArea.backgroundColor = MyColor.pdfBackground
        documentArea.snp.makeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        showDocumentView(with: viewModel.getNowDocumentViewController())
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
    
    @objc func toggleNavi() {
        if isNaviShowing {
            hideNavi()
        } else {
            showNavi()
        }
        isNaviShowing = !isNaviShowing
    }
    
    @objc func endPlayMode() {
        viewModel.changeCurrentDocumentState(to: .normal)
        showNavi()
        endPlayModeButton.isHidden = true
    }
    
    /// hide`MyNavigationView`
    private func hideNavi() {
        print("hide myNavigationView")
        myNavigationView.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        animateIt()
    }
    
    /// show `MyNavigationView`
    private func showNavi() {
        print("show myNavigationView")
        myNavigationView.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(MyOffset.navigationViewHeight)
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
    
    private func showDocumentView(with vc: DocumentViewController) {
        print(vc)
        addChild(vc)
        vc.view.frame = documentArea.bounds
        documentArea.addSubview(vc.view)
    }
}


// MARK: MainViewDelegate
extension MainViewController: MainViewDelegate {
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func playModeStart() {
        hideNavi()
        endPlayModeButton.isHidden = false
    }
    
    func updateDocumentView(with vc: DocumentViewController) {
        myNavigationView.viewModel.currentVM = vc.viewModel
        showDocumentView(with: vc)
    }
    
    func removeDocumentView(with vc: DocumentViewController) {
        vc.willMove(toParent: nil)
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
    
}
