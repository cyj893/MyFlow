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
    private var pdfView = MyPDFView()
    private let endPlayModeButton = UIButton()
    
    private var nowState: DocumentViewState?
    
    private var pointHelper = PointHelper()
    private var moveStrategy: MoveStrategy?
    
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowState = NormalState(vc: self)
        
        setMyNavigationView()
        setPdfView()
        
        addTapGesture()
        addPanGesture()
        
        openDocument()
        
        setEndPlayModeButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        myNavigationView.clear()
        pointHelper.clear()
        
        let pointsInfos = pointHelper
            .getPointsInfo()
            .map { (height, page) in
                PointsInfo(height: height, page: pdfDocument!.index(for: page))
            }
        FileHelper.shared.writePointsFile(absoluteString: document!.fileURL.absoluteString, pointsInfos: pointsInfos)
    }
    
}


// MARK: Getter & Setter
extension DocumentViewController {
    func getPointHelper() -> PointHelper { return pointHelper }
    func getPdfView() -> PDFView { return pdfView }
    
    func changeState(state: DocumentViewState) {
        nowState = state
    }
}


// MARK: Views
extension DocumentViewController {
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
    
    fileprivate func setEndPlayModeButton() {
        view.addSubview(endPlayModeButton)
        endPlayModeButton.then {
            $0.setIconStyle(systemName: "stop.circle", tintColor: .gray.withAlphaComponent(0.5))
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MyOffset.betweenIconGroup)
            $0.right.equalToSuperview().offset(-MyOffset.betweenIconGroup)
        }
        endPlayModeButton.addTarget(self, action: #selector(endPlayModeButtonAction), for: .touchUpInside)
        hideEndPlayModeButton()
    }
}


// MARK: Actions
extension DocumentViewController {
    @objc fileprivate func endPlayModeButtonAction() {
        hideEndPlayModeButton()
        showNavi()
        changeState(state: NormalState(vc: self))
    }
    
    func prevPointButtonAction() {
        print("prevPointButtonAction")
        do {
            let prev:PDFAnnotation = try pointHelper.moveToPrev()
            moveStrategy?.move(to: prev)
        } catch {
            showAddPointsModalView()
        }
    }
    
    func nextPointButtonAction() {
        print("nextPointButtonAction")
        do {
            let next:PDFAnnotation = try pointHelper.moveToNext()
            moveStrategy?.move(to: next)
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
    
    func playButtonAction() {
        if pointHelper.getPointsCount() == 0 {
            showAddPointsModalView()
            return
        }
        showEndPlayModeButton()
        hideNavi()
        moveToPoint(at: 0)
        changeState(state: PlayModeState(vc: self))
    }
    
    func deleteButtonAction() {
        pointHelper.deletePoint()
    }
    
    func moveToPoint(at index: Int) {
        print("nextPointButtonAction")
        do {
            let next:PDFAnnotation = try pointHelper.moveToPoint(at: index)
            moveStrategy?.move(to: next)
        } catch let e as PointError {
            showAddPointsModalView()
        } catch {
            // TODO: Aleart Unexpected Error
            print("Unexpected")
        }
    }
    
    private func showEndPlayModeButton() {
        endPlayModeButton.isHidden = false
    }
    
    private func hideEndPlayModeButton() {
        endPlayModeButton.isHidden = true
    }
    
}


// MARK: Prepare
extension DocumentViewController {
    func openDocument() {
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
                setMoveStrategy()
                
                if let pointsInfos = FileHelper.shared.readPointsFileIfExist(absoluteString: document!.fileURL.absoluteString) {
                    pointsInfos.forEach { info in
                        pointHelper.addPoint(info.height, pdfDocument.page(at: info.page)!)
                    }
                }
            }
            else {
                print("error")
                // TODO: presenting an error message to the user.
            }
        })
    }
    
    fileprivate func setMoveStrategy() {
        do {
            moveStrategy = try UseScrollView(pdfView: pdfView)
        } catch let e as PdfError {
            // TODO: Aleart Error
            moveStrategy = UseGo(vc: self)
        } catch {
            // TODO: Aleart Unexpected Error
            moveStrategy = UseGo(vc: self)
        }
    }
}


// MARK: Define Gestures
extension DocumentViewController {
    
    fileprivate func addTapGesture() {
        let taps = UITapGestureRecognizer(target: self, action: #selector(setTapGesture))
        pdfView.addGestureRecognizer(taps)
    }
    
    fileprivate func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(setPanGesture))
        pdfView.addGestureRecognizer(pan)
    }
    
    @objc func setTapGesture(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        
        nowState?.tapProcess(location: location)
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
            if pdfView.frame.height - location.y < pdfView.frame.height * 0.2 {
                print("AutoScroll")
                moveStrategy?.moveAfter(to: pdfView.frame.height * 0.2 + 100)
            }
            print("move to \(convertedLocation)")
            pointHelper.movePoint(Int(convertedLocation.y), page)

        case .ended, .cancelled, .failed:
            guard let _ = pointHelper.getNowSelectedPoint() else { return }
            pointHelper.endMove()
        default:
            break
        }
    }
    
}

// MARK: Show/Hide NavigationView

extension DocumentViewController {
    
    /// hide`MyNavigationView`
    func hideNavi() {
        print("hide myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        getPdfView().snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animateIt()
    }
    
    /// show `MyNavigationView`
    func showNavi() {
        print("show myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        getPdfView().snp.remakeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        animateIt()
    }
    
    /// Configurate and animate for `MyNavigationView`
    fileprivate func animateIt() {
        UIView.animate(
            withDuration: 0.5,
            animations: view.layoutIfNeeded
        )
    }
    
}
