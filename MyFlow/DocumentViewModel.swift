//
//  DocumentViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/26.
//

import PDFKit


protocol DocumentViewDelegate {
    func setDocument(with pdfDocument: PDFDocument)
    func hideNavi()
    func showNavi()
    func hideEndPlayModeButton()
    func showEndPlayModeButton()
    func showAddPointsModalView(_ viewController: UIViewController)
    func dismiss()
}


final class DocumentViewModel: NSObject, PDFDocumentDelegate {
    
    var delegate: DocumentViewDelegate?
    
    var document: UIDocument?
    var pdfDocument: PDFDocument? {
        didSet {
            delegate?.setDocument(with: pdfDocument!)
        }
    }
    
    var nowState: DocumentViewState?
    
    private(set) var pointHelper = PointHelper()
    var moveStrategy: MoveStrategy?
    
    
    init(delegate: DocumentViewDelegate? = nil, document: Document) {
        self.delegate = delegate
        self.document = document
        
        super.init()
        
        nowState = NormalState(vm: self)
        
        openDocument()
        
    }
    
    func clear() {
        pointHelper.clear()
        
        let pointsInfos = pointHelper
            .getPointsInfo()
            .map { (height, page) in
                PointsInfo(height: height, page: pdfDocument!.index(for: page))
            }
        FileHelper.shared.writePointsFile(absoluteString: document!.fileURL.absoluteString, pointsInfos: pointsInfos)
    }
    
}

// MARK: Prepare
extension DocumentViewModel {
    func openDocument() {
        document?.open(completionHandler: { [self] (success) in
            if success {
                print("success")
                self.pdfDocument = PDFDocument(url: self.document!.fileURL)
                guard let pdfDocument = self.pdfDocument else {
                    return
                }
                pdfDocument.delegate = self
                if pdfDocument.allowsCommenting == false {
                    // TODO: presenting an message to the user.
                    print("This file cannot be commented")
                }
                
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
    
}


// MARK: Actions
extension DocumentViewModel {
    @objc func endPlayModeButtonAction() {
        delegate?.hideEndPlayModeButton()
        delegate?.showNavi()
        nowState = NormalState(vm: self)
    }
    
    func moveToPrevPoint() {
        print("moveToPrevPoint")
        do {
            let prev = try pointHelper.moveToPrev()
            moveStrategy?.move(to: prev)
        } catch {
            delegate?.showAddPointsModalView(getAddPointsModalView())
        }
    }
    
    func moveToNextPoint() {
        print("moveToNextPoint")
        do {
            let next = try pointHelper.moveToNext()
            moveStrategy?.move(to: next)
        } catch {
            delegate?.showAddPointsModalView(getAddPointsModalView())
        }
    }
    
    
    func playButtonAction() {
        if pointHelper.getPointsCount() == 0 {
            delegate?.showAddPointsModalView(getAddPointsModalView())
            return
        }
        delegate?.showEndPlayModeButton()
        delegate?.hideNavi()
        moveToPoint(at: 0)
        nowState = PlayModeState(vm: self)
    }
    
    private func moveToPoint(at index: Int) {
        print("moveToPoint")
        do {
            let next = try pointHelper.moveToPoint(at: index)
            moveStrategy?.move(to: next)
        } catch let e as PointError {
            delegate?.showAddPointsModalView(getAddPointsModalView())
        } catch {
            // TODO: Aleart Unexpected Error
            print("Unexpected")
        }
    }
    
    private func getAddPointsModalView() -> UIViewController {
        let viewController = AddPointsModalViewController()
        viewController.pointHelper = pointHelper
        viewController.pdfDocument = pdfDocument!
        return viewController
    }
    
    func showAddPointsModalView() {
        delegate?.showAddPointsModalView(getAddPointsModalView())
    }
    
    func dismiss() {
        delegate?.dismiss()
    }
    
}


// MARK: Gestures
extension DocumentViewModel {
    
    func tapGestureRecognized(location: CGPoint, pdfView: PDFView) {
        nowState?.tapProcess(location: location, pdfView: pdfView)
    }
    
    func panGestureChanged(location: CGPoint, pdfView: PDFView) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        guard let _ = pointHelper.getNowSelectedPoint() else { return }
        if pdfView.frame.height - location.y < pdfView.frame.height * 0.2 {
            print("AutoScroll")
            moveStrategy?.moveAfter(to: pdfView.frame.height * 0.2 + 100)
        }
        print("move to \(convertedLocation)")
        pointHelper.movePoint(Int(convertedLocation.y), page)
    }
    
    func panGestureEnded() {
        guard let _ = pointHelper.getNowSelectedPoint() else { return }
        pointHelper.endMove()
    }
    
}
