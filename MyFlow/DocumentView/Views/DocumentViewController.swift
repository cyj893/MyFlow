//
//  DocumentViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import PDFKit

import Then
import SnapKit


final class DocumentViewController: UIViewController {
    private(set) var pdfView = MyPDFView()
    
#if DEBUG
    var stateLabel = UILabel()
#endif
    
    var viewModel: DocumentViewModel?
    
    var restoreInfo: DocumentTabInfo?
    
    // MARK: LifeCycle
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let documentTabInfo = restoreInfo {
            print("Restore Info")
            pdfView.scaleFactor = documentTabInfo.scaleFactor
            if let pdfScrollView = pdfView.scrollView {
                pdfScrollView.setContentOffset(documentTabInfo.offset, animated: false)
            }
            self.restoreInfo = nil
        }
    }
    
    func close() {
        viewModel?.clear()
        viewModel = nil
    }
    
}


// MARK: Views
extension DocumentViewController {
    private func addSubviews() {
        view.addSubview(pdfView)
        
#if DEBUG
        view.addSubview(stateLabel)
#endif
    }
    
    private func setViews() {
        setPdfView()
        
#if DEBUG
        setStateLabel()
#endif
    }
    
    private func configure() {
        title = viewModel?.document?.fileURL.lastPathComponent
        viewModel?.delegate = self
        
        addTapGesture()
        addPanGesture()
    }
    
    fileprivate func setPdfView() {
        pdfView.then {
            $0.displayDirection = .vertical
            $0.usePageViewController(false)
            $0.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            $0.autoScales = true
            $0.backgroundColor = MyColor.pdfBackground
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
#if DEBUG
    fileprivate func setStateLabel() {
        stateLabel.then {
            $0.text = "\(DocumentViewState.normal)"
            $0.textColor = .black
            $0.backgroundColor = .systemMint
            $0.font = .systemFont(ofSize: 20)
        }.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
        }
    }
#endif
    
    fileprivate func getMoveStrategy() -> MoveStrategy {
        do {
            return try UseScrollView(pdfView: pdfView)
        } catch let e as PdfError {
            // TODO: Aleart Error
            return UseGo(vc: self)
        } catch {
            // TODO: Aleart Unexpected Error
            return UseGo(vc: self)
        }
    }
}


// MARK: Actions
extension DocumentViewController {
    func endPlayModeButtonAction() {
        viewModel?.changeState(to: .normal)
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
        
        viewModel?.tapGestureRecognized(location: location, pdfView: pdfView)
    }
    
    @objc func setPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        
        switch recognizer.state {
        case .began:
            print("Begin pan gesture")
            
        case .changed:
            viewModel?.panGestureChanged(location: location, pdfView: pdfView)
            
        case .ended, .cancelled, .failed:
            viewModel?.panGestureEnded()
            
        default:
            break
        }
    }
}


// MARK: DocumentViewDelegate
extension DocumentViewController: DocumentViewDelegate {
    func setDocument(with pdfDocument: PDFDocument) {
        self.pdfView.document = pdfDocument
        viewModel?.moveStrategy = getMoveStrategy()
    }
    
    func showAddPointsModalView(_ viewController: UIViewController) {
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
    
#if DEBUG
    func setStateLabelText(with state: DocumentViewState) {
        stateLabel.text = "\(state)"
        stateLabel.backgroundColor = UIColor(
            red: .random(in: 150...200),
            green: .random(in: 150...200),
            blue: .random(in: 150...200),
            alpha: 1.0
        )
    }
#endif
}
