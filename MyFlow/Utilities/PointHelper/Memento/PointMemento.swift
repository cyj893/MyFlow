//
//  PointMemento.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/06/01.
//

import PDFKit

class PointMemento {
    private(set) var page: PDFPage
    private(set) var height: Int
    
    init(page: PDFPage, height: Int) {
        self.page = page
        self.height = height
    }
}
