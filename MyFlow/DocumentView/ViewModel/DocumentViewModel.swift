//
//  DocumentViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/26.
//

import PDFKit


final class DocumentViewModel: NSObject, PDFDocumentDelegate {
    var key: URL? {
        document?.fileURL
    }
    
    
    weak var delegate: DocumentViewDelegate?
    
    var document: UIDocument?
    var pdfDocument: PDFDocument? {
        didSet {
            delegate?.setDocument(with: pdfDocument!)
        }
    }
    
    var nowState: DocumentViewStateInterface?
    
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
    
    func panGestureEnded() {
        guard let _ = pointHelper.getNowSelectedPoint() else { return }
        pointHelper.endMove()
    }
    
}


// MARK: DocumentViewModelInterface
extension DocumentViewModel: DocumentViewModelInterface {
    
    func changeState(to state: DocumentViewState) {
        switch state {
        case .normal:
            nowState = NormalState(vm: self)
        case .handlePoints:
            nowState = HandlePointsState(vm: self)
        case .addPoints:
            nowState = AddPointsState(vm: self)
        case .playMode:
            nowState = PlayModeState(vm: self)
        }
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
    
    func getNowPointNum() -> Int {
        return pointHelper.idx + 1
    }
    
    func deletePoint() {
        pointHelper.deletePoint()
    }
    
    func selectPoint(_ annotation: PDFAnnotation) {
        pointHelper.selectPoint(annotation)
    }
    
    func addPoint(_ height: Int, _ page: PDFPage) {
        pointHelper.addPoint(height, page)
    }
    
    func clearSelectedPoint() {
        pointHelper.clearSelectedPoint()
    }
    
    func undo() {
        pointHelper.undo()
    }
    
    func redo() {
        pointHelper.redo()
    }
    
    func playButtonAction() {
        if pointHelper.getPointsCount() == 0 {
            delegate?.showAddPointsModalView(getAddPointsModalView())
            return
        }
        moveToPoint(at: 0)
        nowState = PlayModeState(vm: self)
    }
    
    func showAddPointsModalView() {
        delegate?.showAddPointsModalView(getAddPointsModalView())
    }
    
    private func getAddPointsModalView() -> UIViewController {
        let viewController = AddPointsModalViewController()
        viewController.pointHelper = pointHelper
        viewController.pdfDocument = pdfDocument!
        return viewController
    }
}
