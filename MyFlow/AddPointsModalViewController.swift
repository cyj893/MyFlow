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
        
    lazy var thumbnailCollectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        getPdfThumbnails()
        
        view.addSubview(thumbnailCollectionView)
        setThumbnailCollectionView()
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
    
    fileprivate func setThumbnailCollectionView() {
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
        thumbnailCollectionView.backgroundColor = .gray
        
        thumbnailCollectionView.showsHorizontalScrollIndicator = true
        thumbnailCollectionView.register(ThumbnailCell.classForCoder(), forCellWithReuseIdentifier: "ThumbnailCell")
        
        thumbnailCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(maxHeight + 20)
        }
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
