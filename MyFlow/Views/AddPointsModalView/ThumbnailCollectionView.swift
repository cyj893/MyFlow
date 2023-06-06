//
//  ThumbnailCollectionView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/06/06.
//

import SwiftUI


/// Shows each `PDFPage`'s thumbnails.
/// Can select thumbnails with order.
struct ThumbnailCollectionView: View {
    /// Thumbnails of each page.
    private var thumbnails: [UIImage]
    
    /// Selected orders by user.
    @State private var orders: [Int] = []
    @State private var orderStates: [Int]
    
    init(thumbnails: [UIImage]) {
        self.thumbnails = thumbnails
        orderStates = [Int](repeating: -1, count: thumbnails.count)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: Array(repeating: .init(), count: 1)) {
                ForEach(Array(thumbnails.indices), id: \.self) { i in
                    ThumbnailCellView(id: i, thumbnail: thumbnails[i], order: $orderStates[i]) { updateOrders($0) }
                }
            }
            .padding()
        }
        .background(Color(MyColor.thumbnailViewBackground))
    }
    
}


extension ThumbnailCollectionView {
    private func updateOrders(_ index: Int) {
        if let nowIndex = orders.firstIndex(of: index) {
            orders.remove(at: nowIndex)
            updateOrder(pageIdx: index, order: nil)
            for i in nowIndex..<orders.count {
                updateOrder(pageIdx: orders[i], order: i+1)
            }
        } else {
            orders.append(index)
            updateOrder(pageIdx: index, order: orders.count)
        }
    }
    
    /// When user select or deselect the cell, set cell's selection by `order`.
    ///
    /// If `order` is `nil`, it's deselection mode.
    ///
    /// - Parameters:
    ///   - pageIdx: Index of cell to change.
    ///   - order: Order of selected cell. If `order` is `nil`, deselect cell.
    private func updateOrder(pageIdx: Int, order: Int?) {
        if let order = order {
            orderStates[pageIdx] = order
        } else {
            orderStates[pageIdx] = -1
        }
    }
}
