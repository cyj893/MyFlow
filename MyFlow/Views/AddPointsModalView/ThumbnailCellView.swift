//
//  ThumbnailCellView.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/06/06.
//

import SwiftUI


/// Shows each `PDFPage`'s thumbnail.
struct ThumbnailCellView: View {
    let id: Int
    let thumbnail: UIImage
    
    /// Cell's selected order.
    @Binding var order: Int
    
    let onTapped: (Int) -> Void
    
    
    var body: some View {
        Button {
            onTapped(id)
        } label: {
            ZStack{
                Image(uiImage: thumbnail)
                Text(order < 0 ? "" : String(order))
                    .frame(width: MyFont.sizeMiddle.width * 1.5, height: MyFont.sizeMiddle.height, alignment: .center)
                    .font(Font(MyFont.middle!))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .background(order < 0 ? .gray.opacity(0.5) : Color(MyColor.border))
                    .cornerRadius(MyFont.sizeMiddle.height/2)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .border(Color(MyColor.border), width: order < 0 ? 0 : 5)
        .shadow(radius: 4)
    }
    
}
