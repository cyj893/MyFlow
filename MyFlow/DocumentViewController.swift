//
//  DocumentViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import SnapKit

import PDFKit

class DocumentViewController: UIViewController {
    let myNavigationView = MyNavigationView.singletonView
    var pdfView = PDFView()
    var document: UIDocument?
    var isShowingMyNavigationView: Bool = true
    var points:[(PDFPage, CGPoint)] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                print("success")
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
            }
            else {
                print("error")
                // TODO: presenting an error message to the user.
            }
        })
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(myNavigationView)
        myNavigationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        myNavigationView.backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        myNavigationView.prevPointButton.addTarget(self, action: #selector(prevPointButtonAction), for: .touchUpInside)
        myNavigationView.nextPointButton.addTarget(self, action: #selector(nextPointButtonAction), for: .touchUpInside)
        
        
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        
        pdfView.backgroundColor = .black
        
        addTapGesture()
        
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    var idx:Int = 0
    @objc func prevPointButtonAction() {
        print("prevPointButtonAction")
        idx += -1 + points.count
        idx %= points.count
        let now = points[idx]
        print(now)
        pdfView.go(to: CGRect(x: now.1.x, y: now.1.y, width: 1, height: 1), on: now.0)
    }
    @objc func nextPointButtonAction() {
        print("nextPointButtonAction")
        idx += 1
        idx %= points.count
        let now = points[idx]
        print(now)
        pdfView.go(to: CGRect(x: now.1.x, y: now.1.y, width: 1, height: 1), on: now.0)
    }
}

// MARK: Toggle MyNavigationView
extension DocumentViewController {
    
    fileprivate func addTapGesture() {
        let taps = UITapGestureRecognizer(target: self, action: #selector(toggleMyNavigationwView))
        pdfView.addGestureRecognizer(taps)
    }
    
    @objc func toggleMyNavigationwView(_ recognizer: UITapGestureRecognizer) {
        if myNavigationView.getIsAddingPoints() {
            let location = recognizer.location(in: pdfView)
            guard let page = pdfView.page(for: location, nearest: true) else { return }
            let convertedPoint = pdfView.convert(location, to: page)
            print(convertedPoint)
            points.append((page, convertedPoint))
            return
        }
        if isShowingMyNavigationView {
            hide()
            isShowingMyNavigationView = false
        }
        else {
            show()
            isShowingMyNavigationView = true
        }
    }
    
    fileprivate func show() {
        print("show myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        pdfView.snp.remakeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        animateIt()
    }
    
    fileprivate func hide() {
        print("hide myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        pdfView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animateIt()
    }
    
    fileprivate func animateIt() {
        UIView.animate(
            withDuration: 0.5,
            animations: self.view.layoutIfNeeded
        )
    }
}
