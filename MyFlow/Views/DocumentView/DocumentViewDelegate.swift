//
//  DocumentViewDelegate.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import PDFKit

protocol DocumentViewDelegate: AnyObject {
    func showAddPointsModalView(_ viewController: UIViewController)
    func setAutoScale(_ autoScale: Bool)
    
#if DEBUG
    func setStateLabelText(with state: DocumentViewState)
#endif
}
