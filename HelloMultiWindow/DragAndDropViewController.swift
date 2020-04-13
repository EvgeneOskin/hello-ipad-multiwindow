//
//  DragAndDropViewController.swift
//  HelloMultiWindow
//
//  Created by Eugene Oskin on 13.04.2020.
//  Copyright © 2020 eoskin. All rights reserved.
//

import SwiftUI

class DragAndDropViewControoler: UIViewController {

    private let dragDelegate = DragDelegate()
    private let dropDelegate = DropDelegate()
    
    public override func viewDidLoad() {
        customEnableDragging(on: self.view, dragInteractionDelegate: dragDelegate)
    }
    func customEnableDragging(on view: UIView, dragInteractionDelegate: UIDragInteractionDelegate) {
        let dragInteraction = UIDragInteraction(delegate: dragInteractionDelegate)
        view.addInteraction(dragInteraction)
    }
    func customEnableDragging(on view: UIView) {
        customEnableDragging(on: view, dragInteractionDelegate: dragDelegate)
    }
    
    func customEnableDropping(on view: UIView, dropInteractionDelegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: dropInteractionDelegate)
        view.addInteraction(dropInteraction)
    }
    func customEnableDropping(on view: UIView) {
        customEnableDropping(on: view, dropInteractionDelegate: dropDelegate)
    }
}

class DragDelegate: NSObject, UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let content = CellContent(counter: (interaction.view! as! AlbumPrivateCell).counter)
        let stringItemProvider = NSItemProvider(object: content)
        return [
            UIDragItem(itemProvider: stringItemProvider)
        ]
    }
}

class DropDelegate: NSObject, UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: CellContent.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: CellContent.self) { [interaction] cell in
            let content = cell[0] as! CellContent
            let view = interaction.view as! UICollectionView
            let coordinator = view.dataSource as! AlbumGridView.Coordinator
            coordinator.addCellData(content.counter)
            view.reloadData()
        }
    }
}
