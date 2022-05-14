//
//  DocumentViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import SnapKit

import PDFKit

class DocumentViewController: UIViewController, PDFDocumentDelegate {
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
                let pdfDocument = PDFDocument(url: self.document!.fileURL)!
                pdfDocument.delegate = self
                self.pdfView.document = pdfDocument
                if pdfDocument.allowsCommenting == false {
                    // TODO: presenting an message to the user.
                    print("This file cannot be commented")
                }
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
        print(idx)
        pdfView.go(to: CGRect(origin: now.1, size: CGSize(width: 1, height: -view.frame.height)), on: now.0)
    }
    @objc func nextPointButtonAction() {
        print("nextPointButtonAction")
        idx += 1
        idx %= points.count
        let now = points[idx]
        print(idx)
        pdfView.go(to: CGRect(origin: now.1, size: CGSize(width: 1, height: -view.frame.height)), on: now.0)
    }
    
}

// MARK: Toggle MyNavigationView
extension DocumentViewController {
    
    fileprivate func addTapGesture() {
        let taps = UITapGestureRecognizer(target: self, action: #selector(setTapGesture))
        pdfView.addGestureRecognizer(taps)
    }
    
    fileprivate func addPointLine(_ heightPoint: CGPoint, _ page: PDFPage) {
        let path = UIBezierPath()
        path.move(to: heightPoint)
        path.addLine(to: CGPoint(x: self.view.frame.size.width, y: heightPoint.y))
        path.close()
        
        let border = PDFBorder()
        border.lineWidth = 10.0
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                        width: path.bounds.size.width + 10,
                       height: path.bounds.size.height + 10)
        path.moveCenter(to: bounds.center)
        
        let inkAnnotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        inkAnnotation.add(path)
        inkAnnotation.border = border
        inkAnnotation.color = .blue
        page.addAnnotation(inkAnnotation)
    }
    
    @objc func setTapGesture(_ recognizer: UITapGestureRecognizer) {
        if myNavigationView.getIsHandlingPoints() {
            let location = recognizer.location(in: pdfView)
            guard let page = pdfView.page(for: location, nearest: true) else { return }
            let convertedLocation = pdfView.convert(location, to: page)
            guard let annotation = page.annotation(at: convertedLocation) else { return }
            print(annotation)
            return
        }
        if myNavigationView.getIsAddingPoints() {
            let location = recognizer.location(in: pdfView)
            guard let page = pdfView.page(for: location, nearest: true) else { return }
            let heightPoint = CGPoint(x: 0, y: pdfView.convert(location, to: page).y)
            print(heightPoint)
            points.append((page, heightPoint))
            
            addPointLine(heightPoint, page)
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
