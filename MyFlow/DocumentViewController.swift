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
    var document: UIDocument?
    
    let myNavigationView = MyNavigationView.singletonView
    private var pdfView = PDFView()
    private var isShowingMyNavigationView: Bool = true
    
    private var pointHelper = PointHelper()
    
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
        
    fileprivate func setMyNavigationView() {
        myNavigationView.setCurrentVC(vc: self)
        view.addSubview(myNavigationView)
        myNavigationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
    }
    
    fileprivate func setPdfView() {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMyNavigationView()
        setPdfView()
        
        addTapGesture()
    }
        
    func prevPointButtonAction() {
        print("prevPointButtonAction")
        let prev = pointHelper.movePrev()
        pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: prev.1), size: CGSize(width: 1, height: -view.frame.height)), on: prev.0)
    }
    
    func nextPointButtonAction() {
        print("nextPointButtonAction")
        let next = pointHelper.moveNext()
        pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: next.1), size: CGSize(width: 1, height: -view.frame.height)), on: next.0)
    }
    
}


// MARK: Define Tap Gesture

extension DocumentViewController {
    
    fileprivate func addTapGesture() {
        let taps = UITapGestureRecognizer(target: self, action: #selector(setTapGesture))
        pdfView.addGestureRecognizer(taps)
        addPanGesture()
    }
    
    fileprivate func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(setPanGesture))
        pdfView.addGestureRecognizer(pan)
    }
    
    @objc func setTapGesture(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        if myNavigationView.getIsHandlingPoints() {
            handlePoints(convertedLocation, page)
            return
        }
        if myNavigationView.getIsAddingPoints() {
            pointHelper.addPoint(Int(convertedLocation.y), page)
            return
        }
        if isShowingMyNavigationView {
            hideNavigationView()
            isShowingMyNavigationView = false
        }
        else {
            showNavigationView()
            isShowingMyNavigationView = true
        }
    }
    
    @objc func setPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        switch recognizer.state {
        case .began:
            print(convertedLocation)
            
        case .changed:
            guard let _ = pointHelper.getNowSelectedPoint() else { return }
            print("move to \(convertedLocation)")
            pointHelper.movePoint(Int(convertedLocation.y))

        case .ended, .cancelled, .failed:
            guard let _ = pointHelper.getNowSelectedPoint() else { return }
            pointHelper.endMovePoint()
        default:
            break
        }
    }
    
}


// MARK: Toggle NavigationView

extension DocumentViewController {
    
    fileprivate func showNavigationView() {
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
    
    fileprivate func hideNavigationView() {
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


// MARK: Handle Points

extension DocumentViewController {
    
    fileprivate func handlePoints(_ convertedLocation: CGPoint, _ page: PDFPage) {
        print(convertedLocation)
        guard let annotation = page.annotation(at: convertedLocation) else { return }
        print(annotation)
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        pointHelper.selectPoint(annotation)
    }
    
}
