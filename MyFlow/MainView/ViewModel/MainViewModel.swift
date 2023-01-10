//
//  MainViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/12/05.
//

import Foundation


struct DocumentTabInfo {
    var nowPointNum: Int
}

final class MainViewModel: NSObject {
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
        return (documentViews[index].title ?? "", documentViews[index].viewModel?.key)
    }
    
    func closeTab(key: URL?) -> Int? {
        guard let index = documentViews.firstIndex(where:{ $0.viewModel?.key == key }) else {
            return nil
        }
        
        // TODO: Close document logic(saving points, showing message, switch to next index if needed, ...)
        print(index, "삭제")
        documentViews[index].close()
        if index == nowIndex {
            delegate?.removeDocumentView(with: documentViews[index])
        }
        documentViews.remove(at: index)
        infos.remove(at: index)
        
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
    
    private func saveTabInfo(_ index: Int) {
        infos[index].nowPointNum = documentViews[index].viewModel?.getNowPointNum() ?? 1
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
        if let idx = documentViews.firstIndex(where: { $0.viewModel?.key == vc.viewModel?.key }) {
            // reopen
            nowIndex = idx
        } else {
            appendNewTab(vc)
            nowIndex = documentViews.count - 1
        }
        delegate?.updateDocumentView(with: documentViews[nowIndex], info: infos[nowIndex])
        
#if DEBUG
        print(nowIndex)
        delegate?.setNowIndex(with: nowIndex)
#endif
    }
    
    private func appendNewTab(_ vc: DocumentViewController) {
        documentViews.append(vc)
        infos.append(DocumentTabInfo(nowPointNum: 1))
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
        let userActivity = NSUserActivity(activityType: SceneDelegate.MainSceneActivityType)
        
        let urls = documentViews
            .map { vc in
                vc.viewModel?.key
            }
        
        userActivity.addUserInfoEntries(from: ["urls": urls,
                                               "nowIndex": nowIndex])
        return userActivity
    }
    
    func restoreUserActivityState(_ activity: NSUserActivity) {
        guard let urls = activity.userInfo?["urls"] as? [URL?],
              let nowIndex = activity.userInfo?["nowIndex"] as? Int else {
            return
        }
        
        urls
            .compactMap { $0 }
            .forEach { url in
                let documentViewController = DocumentViewController()
                documentViewController.viewModel = DocumentViewModel(document: Document(fileURL: url))
                openDocument(documentViewController)
            }
        
        self.nowIndex = min(nowIndex, documentViews.count - 1)
    }
}
