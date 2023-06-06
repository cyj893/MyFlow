//
//  AddPointsModalView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/06/06.
//


import SwiftUI
import PDFKit


/// ModalView that user can select pages to add points on the top.
struct AddPointsModalView: View {
    /// The object that helps add points.`
    var pointHelper: PointHelper?
    /// PDFDocument to generate thumbnails and add point annotations.
    var pdfDocument: PDFDocument?
    
    /// Thumbnails of each page.
    var thumbnails: [UIImage] = []
    /// The maximum height of each thumbnail.
    var maxHeight: Int = 0
    
    /// Selected orders by user.
    @State var orders: [Int] = []
    
    let dismissClosure: () -> Void
    
    init(pointHelper: PointHelper?, pdfDocument: PDFDocument?, dismissClosure: @escaping () -> Void) {
        self.pointHelper = pointHelper
        self.pdfDocument = pdfDocument
        self.dismissClosure = dismissClosure
        
        getPdfThumbnails()
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Pages to add points")
                .font(.title2)
                .padding(20)
            ThumbnailCollectionView(thumbnails: thumbnails, orders: $orders)
                .frame(height: CGFloat(maxHeight) + 40)
            Spacer()
            HStack {
                ExpandableButton("Cancel") { cancelButtonAction() }
                    .foregroundColor(.red)
                ExpandableButton("Add Points") { addPointsButtonAction() }
                    .foregroundColor(Color(MyColor.icon))
            }
            .padding(20)
        }
        .background(Color(MyColor.pageSheetBackground))
    }
    
}


// MARK: Generate PDF Thumbnails
extension AddPointsModalView {
    /// Set array `thumbnails`.
    mutating private func getPdfThumbnails() {
        guard let pdfDocument = pdfDocument else { return }
        for i in 0..<pdfDocument.pageCount {
            if let thumbnail = generatePdfThumbnail(at: i) {
                thumbnails.append(thumbnail)
            }
        }
    }
    
    /// Get `UIImage` from each `PDFPage`.
    ///
    /// - Parameters:
    ///   - at pageIdx: Index of the page.
    ///   - width: Thumbnail's width. Default is 150.
    /// - Returns: Thumbnail of the page.
    mutating private func generatePdfThumbnail(at pageIdx: Int, width: CGFloat = 150) -> UIImage? {
        guard let page = pdfDocument?.page(at: pageIdx) else {
            return nil
        }
        
        let pageSize = page.bounds(for: .mediaBox)
        let scale = pageSize.height / pageSize.width
        
        let size = CGSize(width: width, height: width * scale)
        
        maxHeight = max(maxHeight, Int(size.height))
        return page.thumbnail(of: size, for: .mediaBox)
    }
}


// MARK: Button Actions
extension AddPointsModalView {
    /// Cancel selection and just dismiss modal.
    private func cancelButtonAction() {
        dismissClosure()
    }
    
    /// Add point annotations at top of selected pages and dismiss modal.
    private func addPointsButtonAction() {
        guard let pointHelper = pointHelper else { return }
        orders.forEach {
            guard let page = pdfDocument?.page(at: $0) else { return }
            let pageSize = page.bounds(for: .mediaBox)
            pointHelper.addPoint(Int(pageSize.height), page)
        }
        dismissClosure()
    }
}
