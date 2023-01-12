//
//  DocumentTabsCollectionViewAdaptor.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/27.
//

import UIKit


protocol DocumentTabsCollectionDataSource: NSObjectProtocol {
    func numberOfItems() -> Int
    func getSelectedIndex() -> Int
    func setSelectedIndex(with index: Int)
    func getItem(at index: Int) -> (String, URL?)
    func closeTab(key: URL?) -> Int?
    func openTab(from before: Int, to after: Int)
    func moveTab(from before: Int, to after: Int)
}


final class DocumentTabsCollectionViewAdaptor: NSObject {
    
    let logger = MyLogger(category: String(describing: DocumentTabsCollectionViewAdaptor.self))
    
    weak var dataSource: DocumentTabsCollectionDataSource?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 29)
        layout.minimumLineSpacing = 2.0
        
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 1.0, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        
        return cv
    }()
    
    
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
        return dataSource?.numberOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCell
        
        let item = dataSource?.getItem(at: indexPath.row)
        cell.label.text = item?.0 ?? ""
        
        cell.deleteAction = {
            if let next = self.dataSource?.closeTab(key: item?.1) {
                self.dataSource?.setSelectedIndex(with: next)
                collectionView.cellForItem(at: IndexPath(item: next, section: 0))?.isSelected = true
            }
            
            collectionView.reloadData()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if dataSource?.getSelectedIndex() == indexPath.item {
            cell.isSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        if indexPath.item == dataSource.getSelectedIndex() {
            return
        }
        
        let beforeSelectedIdx = dataSource.getSelectedIndex()
        
        collectionView.cellForItem(at: IndexPath(item: beforeSelectedIdx, section: 0))?.isSelected = false
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        logger.log("didSelectItemAt: Tapped \(indexPath.item), before is \(beforeSelectedIdx)")
        
        dataSource.openTab(from: beforeSelectedIdx, to: indexPath.item)
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
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: (dataSource?.numberOfItems() ?? 1) - 1, section: 0)
        
        if coordinator.proposal.operation == .move {
            guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else {
                logger.log("performDropWith: Fail to move tab\(destinationIndexPath.item)", .info)
                
                return
            }
            
            logger.log("performDropWith: Move \(sourceIndexPath.item) to \(destinationIndexPath.item)")
            
            collectionView.performBatchUpdates {
                self.dataSource?.moveTab(from: sourceIndexPath.item, to: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            } completion: { _ in
                guard let dataSource = self.dataSource else { return }
                
                if sourceIndexPath.item == dataSource.getSelectedIndex() {
                    collectionView.scrollToItem(at: destinationIndexPath, at: .centeredHorizontally, animated: true)
                }
                
                collectionView.cellForItem(at: IndexPath(item: dataSource.getSelectedIndex(), section: 0))?.isSelected = false
                
                let next = self.move(s: sourceIndexPath.item, d: destinationIndexPath.item, now: dataSource.getSelectedIndex())
                dataSource.setSelectedIndex(with: next)
                
                collectionView.cellForItem(at: IndexPath(item: next, section: 0))?.isSelected = true
            }
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    private func move(s: Int, d: Int, now: Int) -> Int {
        if s == now {
            return d
        } else if s > now {
            if d <= now {
                return now + 1
            }
        } else {
            if d >= now {
                return now - 1
            }
        }
        return now
    }
}
