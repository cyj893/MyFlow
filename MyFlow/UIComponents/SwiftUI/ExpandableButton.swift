//
//  ExpandableButton.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/06/06.
//

import SwiftUI


struct ExpandableButton: View {
    var title: String
    var action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                Text(title)
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}
