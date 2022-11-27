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
    
    var viewModel: DocumentViewModel?
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.delegate = self
        
        setPdfView()
        
        addTapGesture()
        addPanGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel?.clear()
        viewModel = nil
    }
    
}


// MARK: Views
extension DocumentViewController {
    fileprivate func setPdfView() {
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        
        pdfView.backgroundColor = MyColor.pdfBackground
    }
    
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
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
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
    
}
