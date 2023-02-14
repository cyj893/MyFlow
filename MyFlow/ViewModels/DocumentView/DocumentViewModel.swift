//
//  DocumentViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/26.
//

import PDFKit


final class DocumentViewModel: NSObject, PDFDocumentDelegate {
    let logger = MyLogger(category: String(describing: DocumentViewModel.self))
    
    var key: URL {
        document.fileURL
    }
    
    
    weak var delegate: DocumentViewDelegate?
    
    var document: UIDocument
    var pdfDocument: PDFDocument?
    
    var nowState: DocumentViewStateInterface? {
        willSet {
            nowState?.completion(next: newValue!.state)
            
#if DEBUG
            delegate?.setStateLabelText(with: newValue!.state)
#endif
        }
    }
    
    private(set) var pointHelper = PointHelper()
    var moveStrategy: MoveStrategy?
    
    
    init(delegate: DocumentViewDelegate? = nil, document: Document) async throws {
        self.delegate = delegate
        self.document = document
        
        super.init()
        
        nowState = NormalState(vm: self)
        
        try await openDocument()
    }
    
    func clear() {
        pointHelper.clear()
        savePointsInfosIfNeeded()
    }
    
    func savePointsInfosIfNeeded() {
        if !pointHelper.isEdited {
            return
        }
        
        guard let pdfDocument = pdfDocument else {
            logger.log("Cant' savePointsInfos \(key.lastPathComponent): pdfDocument is nil", .error)
            return
        }
        
        logger.log("savePointsInfos \(key.lastPathComponent)")
        FileHelper.shared.writePointsFile(absoluteString: document.fileURL.absoluteString,
                                          pointsInfos: pointHelper.getPointsInfos(in: pdfDocument))
        
        pointHelper.isEdited = false
    }
    
}

// MARK: Prepare
extension DocumentViewModel {
    func openDocument() async throws {
        let isSuccess = await document.open()
        
        if isSuccess {
            try openSuccess()
        } else {
            try openFail()
        }
    }
    
    func openSuccess() throws {
        logger.log("Success to read file: \(document.fileURL.lastPathComponent)")
        
        guard let pdfDocument = PDFDocument(url: document.fileURL) else {
            logger.log("Fail to get pdf file: \(document.fileURL.absoluteString)", .error)
            throw PdfError.cannotFindDocument
        }
        self.pdfDocument = pdfDocument
        pdfDocument.delegate = self
        if !pdfDocument.allowsCommenting {
            // TODO: presenting an message to the user.
            logger.log("This file cannot be commented", .info)
        }
        
        if let pointsInfos = FileHelper.shared.readPointsFileIfExist(absoluteString: document.fileURL.absoluteString) {
            pointsInfos.forEach { info in
                pointHelper.addPoint(info.height, pdfDocument.page(at: info.page)!)
            }
        }
    }
    
    func openFail() throws {
        logger.log("Fail to read file: \(document.fileURL.absoluteString)", .error)
        throw PdfError.cannotFindDocument
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
            logger.log("autoScroll")
            moveStrategy?.moveAfter(to: pdfView.frame.height * 0.2 + 100)
        }
        // logger.log("move point to \(convertedLocation)")
        pointHelper.movePoint(Int(convertedLocation.y), page)
    }
    
    private func moveToPoint(at index: Int) {
        logger.log("moveToPoint \(index)")
        do {
            let next = try pointHelper.getPoint(at: index)
            moveStrategy?.move(to: next)
        } catch PointError.emptyPoints {
            logger.log("No point to move, Show AddPointsModalView")
            delegate?.showAddPointsModalView(getAddPointsModalView())
        } catch {
            // TODO: Aleart Unexpected Error
            logger.log("Unexpected error: \(error.localizedDescription)", .error)
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
        logger.log("Change state from \(nowState == nil ? "nil" : String(describing: nowState!.state)) to \(state)")
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
        logger.log("now \(getNowPointNum()), moveToPrevPoint")
        do {
            let prev = try pointHelper.getPrevPoint()
            moveStrategy?.move(to: prev)
        } catch {
            logger.log("No point to move, Show AddPointsModalView")
            delegate?.showAddPointsModalView(getAddPointsModalView())
        }
    }
    
    func moveToNextPoint() {
        logger.log("now \(getNowPointNum()), moveToNextPoint")
        do {
            let next = try pointHelper.getNextPoint()
            moveStrategy?.move(to: next)
        } catch {
            logger.log("No point to move, Show AddPointsModalView")
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
        logger.log("Start play mode")
        if pointHelper.getPointsCount() == 0 {
            logger.log("No point to move, Show AddPointsModalView")
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
