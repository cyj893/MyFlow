//
//  DocumentViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import SnapKit

import PDFKit

class DocumentViewController: UIViewController {
        
    var pdfView = PDFView()
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                print(self.document?.fileURL.lastPathComponent)
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        
        pdfView.backgroundColor = .gray
        
    }
    
}
