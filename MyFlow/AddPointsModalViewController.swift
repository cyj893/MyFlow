//
//  AddPointsModalViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/26.
//

import UIKit
import SnapKit
import PDFKit

class AddPointsModalViewController: UIViewController {
    var pointHelper: PointHelper?
    var pdfDocument: PDFDocument?
    
    var thumbnails: [UIImage] = []
    var maxHeight:Int = 0
    
    var orders: [Int] = []
    
    lazy var thumbnailLabel = UILabel().then {
        $0.text = "Choose Pages to add points"
        $0.font = UIFont.boldSystemFont(ofSize: 25)
    }
    
    lazy var thumbnailCollectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }()
    
    lazy var cancelButton = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    lazy var addPointsButton = UIButton().then {
        $0.setTitle("Add Points", for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = MyColor.pageSheetBackgroundColor
        
        getPdfThumbnails()
        
        view.addSubview(thumbnailLabel)
        setThumbnailLabel()
        
        view.addSubview(thumbnailCollectionView)
        setThumbnailCollectionView()
        
        view.addSubview(cancelButton)
        view.addSubview(addPointsButton)
        setButtons()
    }
    
    fileprivate func generatePdfThumbnail(at pageIndex: Int, width: CGFloat = 150) -> UIImage? {
        guard let page = pdfDocument?.page(at: pageIndex) else {
            return nil
        }
        
        let pageSize = page.bounds(for: .mediaBox)
        let scale = pageSize.height / pageSize.width
        
        let size = CGSize(width: width, height: width * scale)
        
        maxHeight = max(maxHeight, Int(size.height))
        return page.thumbnail(of: size, for: .mediaBox)
    }
    
    fileprivate func getPdfThumbnails() {
        guard let pdfDocument = pdfDocument else { return }
        for i in 0..<pdfDocument.pageCount {
            if let thumbnail = generatePdfThumbnail(at: i) {
                thumbnails.append(thumbnail)
            }
        }
    }
    
    fileprivate func setThumbnailLabel() {
        thumbnailLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    fileprivate func setThumbnailCollectionView() {
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
        thumbnailCollectionView.backgroundColor = MyColor.thumbnailViewBackgroundColor
        
        thumbnailCollectionView.showsHorizontalScrollIndicator = true
        thumbnailCollectionView.register(ThumbnailCell.classForCoder(), forCellWithReuseIdentifier: "ThumbnailCell")
        
        thumbnailCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(thumbnailLabel.snp.bottom).offset(10)
            $0.height.equalTo(maxHeight + 40)
        }
    }
    
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
    
    @objc fileprivate func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
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

extension AddPointsModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.item
        return thumbnails[index].size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        cell.thumbnailView.image = thumbnails[index]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        if let nowIndex = orders.firstIndex(of: index) {
            orders.remove(at: nowIndex)
            updateOrder(pageIdx: index, order: nil, collectionView)
            for i in nowIndex..<orders.count {
                updateOrder(pageIdx: orders[i], order: i+1, collectionView)
            }
        }
        else {
            orders.append(index)
            updateOrder(pageIdx: index, order: orders.count, collectionView)
        }
    }
    
    func updateOrder(pageIdx: Int, order: Int?, _ collectionView: UICollectionView) {
        let indexPath = IndexPath(item: pageIdx, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell {
            if let order = order {
                cell.orderLabel.text = String(order)
                cell.orderLabel.backgroundColor = MyColor.borderColor
                cell.thumbnailView.layer.borderWidth = 5
            }
            else {
                cell.orderLabel.text = " "
                cell.orderLabel.backgroundColor = .gray.withAlphaComponent(0.5)
                cell.thumbnailView.layer.borderWidth = 0
            }
        }
    }
    
}
