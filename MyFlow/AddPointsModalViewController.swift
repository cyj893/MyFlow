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
    
    fileprivate func generatePdfThumbnail(at pageIndex: Int, width: CGFloat = 100) -> UIImage? {
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
        
        thumbnailCollectionView.allowsMultipleSelection = true
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
    
}
