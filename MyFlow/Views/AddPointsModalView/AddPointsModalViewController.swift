//
//  AddPointsModalViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/26.
//

import UIKit
import SnapKit
import PDFKit
import SwiftUI


/// ModalView that user can select pages to add points on the top.
class AddPointsModalViewController: UIViewController {
    /// The object that helps add points.`
    var pointHelper: PointHelper?
    /// PDFDocument to generate thumbnails and add point annotations.
    var pdfDocument: PDFDocument?
    
    /// Thumbnails of each page.
    var thumbnails: [UIImage] = []
    /// The maximum height of each thumbnail.
    var maxHeight:Int = 0
    
    /// Selected orders by user.
    var orders: [Int] = []
    
    /// Shows the guide text.
    lazy var thumbnailLabel = UILabel().then {
        $0.text = "Choose Pages to add points"
        $0.font = UIFont.boldSystemFont(ofSize: 25)
    }
    
    /// CollectionView containing thumbnails. User can select pages from it.
    var thumbnailCollectionView: UIHostingController<ThumbnailCollectionView>?
    
    lazy var cancelButton = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        $0.configuration = config
    }
    lazy var addPointsButton = UIButton().then {
        $0.setTitle("Add Points", for: .normal)
        $0.setTitleColor(MyColor.icon, for: .normal)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        $0.configuration = config
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = MyColor.pageSheetBackground
        
        getPdfThumbnails()
        thumbnailCollectionView = UIHostingController(rootView: CollectionSwiftUI(thumbnails: thumbnails))
        thumbnailCollectionView = UIHostingController(rootView: ThumbnailCollectionView(thumbnails: thumbnails))
        
        view.addSubview(thumbnailLabel)
        setThumbnailLabel()
        
        view.addSubview(thumbnailCollectionView!.view)
        setThumbnailCollectionView()
        
        view.addSubview(cancelButton)
        view.addSubview(addPointsButton)
        setButtons()
    }
    
    
    /// Get `UIImage` from each `PDFPage`.
    ///
    /// - Parameters:
    ///   - at pageIdx: Index of the page.
    ///   - width: Thumbnail's width. Default is 150.
    /// - Returns: Thumbnail of the page.
    fileprivate func generatePdfThumbnail(at pageIdx: Int, width: CGFloat = 150) -> UIImage? {
        guard let page = pdfDocument?.page(at: pageIdx) else {
            return nil
        }
        
        let pageSize = page.bounds(for: .mediaBox)
        let scale = pageSize.height / pageSize.width
        
        let size = CGSize(width: width, height: width * scale)
        
        maxHeight = max(maxHeight, Int(size.height))
        return page.thumbnail(of: size, for: .mediaBox)
    }
    
    /// Set array `thumbnails`.
    fileprivate func getPdfThumbnails() {
        guard let pdfDocument = pdfDocument else { return }
        for i in 0..<pdfDocument.pageCount {
            if let thumbnail = generatePdfThumbnail(at: i) {
                thumbnails.append(thumbnail)
            }
        }
    }
    
    /// Set `thumbnailLabel`'s constraints.
    fileprivate func setThumbnailLabel() {
        thumbnailLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    /// Set `thumbnailCollectionView`'s constraints.
    fileprivate func setThumbnailCollectionView() {
        thumbnailCollectionView!.view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(thumbnailLabel.snp.bottom).offset(10)
            $0.height.equalTo(maxHeight + 40)
        }
    }
    
    /// Set `cancelButton` and `addPointsButton`'s action and constraints.
    fileprivate func setButtons() {
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(addPointsButton.snp.left)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(addPointsButton)
        }
        addPointsButton.addTarget(self, action: #selector(addPointsButtonAction), for: .touchUpInside)
        addPointsButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.left.equalTo(cancelButton.snp.right)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(cancelButton)
        }
    }
    
    
    // MARK: Button Actions
    
    /// Cancel selection and just dismiss modal.
    @objc fileprivate func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Add point annotations at top of selected pages and dismiss modal.
    @objc fileprivate func addPointsButtonAction() {
        guard let pointHelper = pointHelper else { return }
        orders.forEach {
            guard let page = pdfDocument?.page(at: $0) else { return }
            let pageSize = page.bounds(for: .mediaBox)
            pointHelper.addPoint(Int(pageSize.height), page)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
