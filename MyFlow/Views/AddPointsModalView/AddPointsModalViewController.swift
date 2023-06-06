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
    
    var addPointsModalView: UIHostingController<AddPointsModalView>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = MyColor.pageSheetBackground
        
        addPointsModalView = UIHostingController(rootView: AddPointsModalView(pointHelper: pointHelper, pdfDocument: pdfDocument) { [unowned self] in
            self.dismiss(animated: true)
        })
        
        view.addSubview(addPointsModalView!.view)
        addPointsModalView!.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}
