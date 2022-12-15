//
//  MainViewModel.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/12/05.
//

import Foundation


final class MainViewModel: NSObject {
    static let shared = MainViewModel()
    
    var delegate: MainViewDelegate?
    
    var documentViews: [DocumentViewController] = []
    var nowIndex = 0
    
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
    
    func getItem(at index: Int) -> String {
        return documentViews[index].title ?? ""
    }
    
    func closeTab(at index: Int) -> Int? {
        // TODO: Close document logic(saving points, showing message, switch to next index if needed, ...)
        
        documentViews[index].close()
        if index == nowIndex {
            delegate?.removeDocumentView(with: documentViews[index])
        }
        documentViews.remove(at: index)
        
        let nextIndex = getNextIndex(index, nowIndex)
        if let nextIndex = nextIndex {
            if index == nowIndex {
                delegate?.updateDocumentView(with: documentViews[nextIndex])
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
        
        delegate?.removeDocumentView(with: documentViews[before])
        delegate?.updateDocumentView(with: documentViews[after])
        nowIndex = after
    }
    
    func moveTab(from before: Int, to after: Int) {
        let temp = documentViews[before]
        documentViews.remove(at: before)
        documentViews.insert(temp, at: after)
    }
    
}


extension MainViewModel: MainViewModelInterface {
    func openDocument(_ vc: DocumentViewController) {
        if let idx = documentViews.firstIndex(where: { $0.viewModel?.document?.fileURL == vc.viewModel?.document?.fileURL }) {
            // reopen
            nowIndex = idx
        } else {
            documentViews.append(vc)
            nowIndex = documentViews.count - 1
        }
        delegate?.updateDocumentView(with: documentViews[nowIndex])
    }
    
    func changeCurrentDocumentState(to state: DocumentViewState) {
        documentViews[nowIndex].viewModel?.changeState(to: state)
    }
    
    func getNowDocumentViewController() -> DocumentViewController {
        return documentViews[nowIndex]
    }
}
