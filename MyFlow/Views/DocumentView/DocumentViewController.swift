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
    let logger = MyLogger(category: String(describing: DocumentViewController.self))
    
    private(set) var pdfView = MyPDFView()
    
#if DEBUG
    var stateLabel = UILabel()
#endif
    
    var viewModel: DocumentViewModel
    
    var restoreInfo: DocumentTabInfo?
    
    // MARK: LifeCycle
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        self.pdfView.document = viewModel.pdfDocument
        
        super.init(nibName: nil, bundle: nil)
        
        setMoveStrategy()
        
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
            logger.log("\(viewModel.key.lastPathComponent) Restore Info: scaleFactor \(documentTabInfo.scaleFactor) offset \(documentTabInfo.offset)")
            pdfView.scaleFactor = documentTabInfo.scaleFactor
            if let pdfScrollView = pdfView.scrollView {
                pdfScrollView.setContentOffset(documentTabInfo.offset, animated: false)
            }
            self.restoreInfo = nil
        }
    }
    
    func close() {
        viewModel.clear()
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
        title = viewModel.document.fileURL.lastPathComponent
        viewModel.delegate = self
        
        addTapGesture()
        addPanGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setMoveStrategy), name: NSNotification.Name(UserDefaults.Keys.moveStrategy.rawValue), object: nil)
    }
    
    fileprivate func setPdfView() {
        pdfView.then {
            $0.displayDirection = .vertical
            $0.usePageViewController(false)
            $0.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            //$0.autoScales = true
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
    
    @objc fileprivate func setMoveStrategy() {
        let type = MoveStrategyType(rawValue: UserDefaults.moveStrategy)!
        switch type {
        case .useGo:
            viewModel.moveStrategy = UseGo(vc: self)
        case .useScrollView:
            do {
                viewModel.moveStrategy = try UseScrollView(pdfView: pdfView)
            } catch let e as PdfError {
                logger.log("Fail to UseScrollView: \(e.localizedDescription)", .info)
                // TODO: Aleart Error
                viewModel.moveStrategy = UseGo(vc: self)
            } catch {
                // TODO: Aleart Unexpected Error
                viewModel.moveStrategy = UseGo(vc: self)
            }
        }
    }
}


// MARK: Actions
extension DocumentViewController {
    func endPlayModeButtonAction() {
        viewModel.changeState(to: .normal)
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
        
        viewModel.tapGestureRecognized(location: location, pdfView: pdfView)
    }
    
    @objc func setPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        
        switch recognizer.state {
        case .began:
            logger.log("Begin pan gesture")
            
        case .changed:
            viewModel.panGestureChanged(location: location, pdfView: pdfView)
            
        case .ended, .cancelled, .failed:
            logger.log("End pan gesture")
            viewModel.panGestureEnded()
            
        default:
            break
        }
    }
}


// MARK: DocumentViewDelegate
extension DocumentViewController: DocumentViewDelegate {
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
