//
//  MainViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/12/05.
//

import UIKit


struct DocumentTabInfo {
    var url: URL?
    var nowPointNum: Int = 1
    var offset: CGPoint = .zero
    var scaleFactor: CGFloat = 1.0
}

final class MainViewModel: NSObject {
    
    let logger = MyLogger(category: String(describing: MainViewController.self))
    
    static let shared = MainViewModel()
    
    weak var delegate: MainViewDelegate?
    
    var documentViews: [DocumentViewController] = []
    var infos: [DocumentTabInfo] = []
    
    var nowIndex = 0 {
        willSet {
#if DEBUG
            delegate?.setNowIndex(with: newValue)
#endif
        }
    }
    
}


extension MainViewModel {
    func savePointsInfos() {
        documentViews
            .forEach { vc in
                vc.viewModel?.savePointsInfosIfNeeded()
            }
    }
    
    private func saveTabInfo(_ index: Int) {
        infos[index].nowPointNum = documentViews[index].viewModel?.getNowPointNum() ?? 1
        infos[index].offset = documentViews[index].pdfView.scrollView?.contentOffset ?? .zero
        infos[index].scaleFactor = documentViews[index].pdfView.scaleFactor
    }
    
}


extension MainViewModel: DocumentTabsCollectionDataSource {
    func numberOfItems() -> Int {
        return documentViews.count
    }
    
    func getSelectedIndex() -> Int {
        return nowIndex
    }
    
    func setSelectedIndex(with index: Int) {
        nowIndex = index
    }
    
    func getItem(at index: Int) -> (String, URL?) {
        return (infos[index].url?.lastPathComponent ?? "", infos[index].url)
    }
    
    func closeTab(key: URL?) -> Int? {
        guard let index = documentViews.firstIndex(where:{ $0.viewModel?.key == key }) else {
            return nil
        }
        
        // TODO: Close document logic(saving points, showing message, switch to next index if needed, ...)
        logger.log("Delete tab\(index) \(infos[index].url?.lastPathComponent ?? "")")
        documentViews[index].close()
        if index == nowIndex {
            delegate?.removeDocumentView(with: documentViews[index])
        }
        documentViews.remove(at: index)
        infos.remove(at: index)
        
        if documentViews.isEmpty {
            delegate?.dismiss()
            return 0
        }
        
        let nextIndex = getNextIndex(index, nowIndex)
        if let nextIndex = nextIndex {
            if index == nowIndex {
                delegate?.updateDocumentView(with: documentViews[nextIndex], info: infos[nextIndex])
            }
            nowIndex = nextIndex
        }
        return nextIndex
    }
    
    private func getNextIndex(_ index: Int, _ nowSelectedIdx: Int) -> Int? {
        if index != nowSelectedIdx {
            return index < nowSelectedIdx ? nowSelectedIdx - 1 : nowSelectedIdx
        } else if documentViews.isEmpty {
            return nil
        }
        return min(index, documentViews.count - 1)
    }
    
    func openTab(from before: Int, to after: Int) {
        // TODO: Open document logic(saving points, switch to after index, ...)
        
        saveTabInfo(before)
        delegate?.removeDocumentView(with: documentViews[before])
        delegate?.updateDocumentView(with: documentViews[after], info: infos[after])
        nowIndex = after
    }
    
    func moveTab(from before: Int, to after: Int) {
        let temp = documentViews[before]
        documentViews.remove(at: before)
        documentViews.insert(temp, at: after)
        
        let tempInfo = infos[before]
        infos.remove(at: before)
        infos.insert(tempInfo, at: after)
    }
    
}


extension MainViewModel: MainViewModelInterface {
    func openDocument(_ vc: DocumentViewController) {
        logger.log("openDocument")
        if let idx = documentViews.firstIndex(where: { $0.viewModel?.key == vc.viewModel?.key }) {
            // reopen
            nowIndex = idx
        } else {
            appendNewTab(vc)
            nowIndex = documentViews.count - 1
        }
        delegate?.updateDocumentView(with: documentViews[nowIndex], info: infos[nowIndex])
        
#if DEBUG
        delegate?.setNowIndex(with: nowIndex)
#endif
    }
    
    private func appendNewTab(_ vc: DocumentViewController, withInfo info: DocumentTabInfo? = nil) {
        documentViews.append(vc)
        if let info = info {
            infos.append(info)
        } else {
            infos.append(DocumentTabInfo(url: vc.viewModel?.key))
        }
    }
    
    func changeCurrentDocumentState(to state: DocumentViewState) {
        documentViews[nowIndex].viewModel?.changeState(to: state)
    }
    
    func getNowDocumentViewController() -> DocumentViewController? {
        if documentViews.isEmpty {
            return nil
        }
        return documentViews[nowIndex]
    }
    
    func getUserActivity() -> NSUserActivity {
        if !documentViews.isEmpty {
            saveTabInfo(nowIndex)
        }
        return UserActivityHelper.convert(from: infos, nowIndex: nowIndex)
    }
    
    func restoreUserActivityState(_ activity: NSUserActivity) {
        guard let activity = UserActivityHelper.convert(from: activity) else {
            return
        }
        
        zip(activity.urls, zip(activity.points, activity.scaleFactors))
            .map { ($0, $1.0, $1.1) }
            .forEach { (url, point, scaleFactor) in
                let documentViewController = DocumentViewController(viewModel: .init(document: Document(fileURL: url)))
                restoreDocument(documentViewController, info: DocumentTabInfo(url: url, offset: point, scaleFactor: scaleFactor))
            }
        
        self.nowIndex = min(nowIndex, documentViews.count - 1)
        delegate?.updateDocumentView(with: documentViews[nowIndex], info: infos[nowIndex])
        
#if DEBUG
        delegate?.setNowIndex(with: nowIndex)
#endif
    }
    
    private func restoreDocument(_ vc: DocumentViewController, info: DocumentTabInfo) {
        appendNewTab(vc, withInfo: info)
        vc.restoreInfo = info
    }
    
}
