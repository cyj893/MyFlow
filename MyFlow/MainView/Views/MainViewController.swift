//
//  MainViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


final class MainViewController: UIViewController {
    
    var mainViewUserActivity: NSUserActivity {
        viewModel.getUserActivity()
    }
    
    var viewModel = MainViewModel.shared
    
    let myNavigationView = MyNavigationView()
    var isNaviShowing = true
    
    var documentArea = UIView()
    
    private let endPlayModeButton = UIButton()
    
#if DEBUG
    var nowIndexLabel = UILabel()
#endif
    
    // MARK: LifeCycle
    init(initialVC: DocumentViewController? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
        if let initialVC = initialVC {
            viewModel.openDocument(initialVC)
        }
        myNavigationView.tabsAdaptor.dataSource = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setViews()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ToggleNavi"), object: nil)
        myNavigationView.clear()
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        viewModel.restoreUserActivityState(activity)
    }
}


// MARK: Views
extension MainViewController {
    private func addSubviews() {
        view.addSubview(documentArea)
        view.addSubview(myNavigationView)
        view.addSubview(endPlayModeButton)
        
#if DEBUG
        view.addSubview(nowIndexLabel)
#endif
    }
    
    private func setViews() {
        setMyNavigationView()
        setDocumentView()
        setEndPlayModeButton()
        
#if DEBUG
        setNowIndexLabel()
#endif
    }
    
    private func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(toggleNavi), name: NSNotification.Name("ToggleNavi"), object: nil)
        
        myNavigationView.viewModel.mainViewDelegate = self
        
        if let nowDocumentVC = viewModel.getNowDocumentViewController() {
            myNavigationView.viewModel.currentVM = nowDocumentVC.viewModel
            showDocumentView(with: nowDocumentVC)
        }
        
        endPlayModeButton.addTarget(self, action: #selector(endPlayMode), for: .touchUpInside)
        endPlayModeButton.isHidden = true
    }
    
    private func setMyNavigationView() {
        myNavigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(MyOffset.navigationViewHeight)
        }
    }
    
    private func setDocumentView() {
        documentArea.backgroundColor = MyColor.pdfBackground
        documentArea.snp.makeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setEndPlayModeButton() {
        endPlayModeButton.then {
            $0.setIconStyle(systemName: "stop.circle", tintColor: .gray.withAlphaComponent(0.5))
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MyOffset.betweenIconGroup)
            $0.right.equalToSuperview().offset(-MyOffset.betweenIconGroup)
        }
    }
    
#if DEBUG
    private func setNowIndexLabel() {
        nowIndexLabel.then {
            $0.textColor = .black
            $0.backgroundColor = .systemMint
            $0.font = .systemFont(ofSize: 20)
        }.snp.makeConstraints {
            $0.centerX.equalTo(myNavigationView).multipliedBy(0.5)
            $0.centerY.equalTo(myNavigationView)
        }
    }
#endif
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
    
    func updateDocumentView(with vc: DocumentViewController, info: DocumentTabInfo) {
        if let beforeState = myNavigationView.viewModel.currentVM?.nowState?.state {
            vc.viewModel?.changeState(to: beforeState)
        }
        myNavigationView.viewModel.currentVM = vc.viewModel
        
        myNavigationView.setPointNum(with: info.nowPointNum)
        showDocumentView(with: vc)
    }
    
    func removeDocumentView(with vc: DocumentViewController) {
        vc.willMove(toParent: nil)
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
    
#if DEBUG
    func setNowIndex(with index: Int) {
        nowIndexLabel.text = "\(index)"
        nowIndexLabel.backgroundColor = UIColor(
            red: .random(in: 150...200),
            green: .random(in: 150...200),
            blue: .random(in: 150...200),
            alpha: 1.0
        )
    }
#endif
}
