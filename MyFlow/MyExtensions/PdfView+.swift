//
//  PdfViewExtension.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/10.
//

import PDFKit


extension PDFView {
    var scrollView: UIScrollView? {
        subviews.first as? UIScrollView
    }
}
