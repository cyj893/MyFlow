//
//  DocumentTabsCollectionViewAdaptor.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


final class DocumentTabsCollectionViewAdaptor: NSObject {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 30)
        layout.minimumLineSpacing = 2.0
        
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 1.0, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        
        return cv
    }()
    
    var tabs: [String] = ["asd", "asd2", "asd3", "asd4", "asd5", "asd6"]
    var nowSelectedIdx = 0
    
    override init() {
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.backgroundColor = MyColor.separator
        
        collectionView.register(TabCell.self, forCellWithReuseIdentifier: "TabCell")
    }
}


extension DocumentTabsCollectionViewAdaptor: UICollectionViewDelegate {
    
}


extension DocumentTabsCollectionViewAdaptor: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCell
        let item = tabs[indexPath.row]
        cell.label.text = item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if nowSelectedIdx == indexPath.item {
            cell.isSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == nowSelectedIdx {
            return
        }
        
        let beforeSelectedIdx = nowSelectedIdx
        nowSelectedIdx = indexPath.item
        
        collectionView.cellForItem(at: IndexPath(item: beforeSelectedIdx, section: 0))?.isSelected = false
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        
        print(beforeSelectedIdx, nowSelectedIdx)
        // TODO: logic for changing document
    }
}


extension DocumentTabsCollectionViewAdaptor: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}


extension DocumentTabsCollectionViewAdaptor: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: tabs.count - 1, section: 0)
        
        if coordinator.proposal.operation == .move {
            if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates {
                    let temp = self.tabs[sourceIndexPath.item]
                    self.tabs.remove(at: sourceIndexPath.item)
                    self.tabs.insert(temp, at: destinationIndexPath.item)
                    
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                } completion: { _ in
                    if sourceIndexPath.item == self.nowSelectedIdx {
                        collectionView.cellForItem(at: destinationIndexPath)?.isSelected = true
                        self.nowSelectedIdx = destinationIndexPath.item
                    }
                    collectionView.scrollToItem(at: destinationIndexPath, at: .centeredHorizontally, animated: true)
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}
