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
    var pdfDocument: PDFDocument?
    
    let myNavigationView = MyNavigationView.singletonView
    private var pdfView = PDFView()
    private var nowState: PdfViewState?
    
    private var pointHelper = PointHelper()
    
    
    // MARK: Getter
    func getPointHelper() -> PointHelper { return pointHelper }
    func getPdfView() -> PDFView { return pdfView }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { [self] (success) in
            if success {
                print("success")
                self.pdfDocument = PDFDocument(url: self.document!.fileURL)
                guard let pdfDocument = self.pdfDocument else {
                    return
                }
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
        myNavigationView.setCurrentVC(viewController: self)
        myNavigationView.setCurrentPH(pointHelper: pointHelper)
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
        
        nowState = NormalState(vc: self)
        
        setMyNavigationView()
        setPdfView()
        
        addTapGesture()
    }
        
    func changeState(state: PdfViewState) {
        nowState = state
    }
    
    func prevPointButtonAction() {
        print("prevPointButtonAction")
        do {
            let prev:PDFAnnotation = try pointHelper.moveToPrev()
            pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: prev.bounds.maxY), size: CGSize(width: 1, height: -view.frame.height)), on: prev.page!)
        } catch {
            showAddPointsModalView()
        }
    }
    
    func nextPointButtonAction() {
        print("nextPointButtonAction")
        do {
            let next:PDFAnnotation = try pointHelper.moveToNext()
            pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: next.bounds.maxY), size: CGSize(width: 1, height: -view.frame.height)), on: next.page!)
        } catch {
            showAddPointsModalView()
        }
    }
    
    func showAddPointsModalView() {
        let viewController = AddPointsModalViewController()
        viewController.pointHelper = pointHelper
        viewController.pdfDocument = pdfDocument!
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        } else {
            // Fallback on earlier versions
        }
        present(navigationController, animated: true, completion: nil)
    }
    
}


// MARK: Define Gestures

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
        
        nowState?.tapProcess(location: convertedLocation, page: page)
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
            pointHelper.movePoint(Int(convertedLocation.y), page)

        case .ended, .cancelled, .failed:
            guard let _ = pointHelper.getNowSelectedPoint() else { return }
            pointHelper.clearSelectedPoint()
        default:
            break
        }
    }
    
}
