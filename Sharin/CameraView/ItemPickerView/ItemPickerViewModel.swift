//
//  ItemPickerViewModel.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import Combine
import UIKit

final class ItemPickerViewModel: NSObject {
    let itemPick = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()
}

extension ItemPickerViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.visibleSize.width
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = Item.dummy[indexPath.item]
        itemPick.send(item.usdzURL)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
    }
}

extension ItemPickerViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Item.dummy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.identifier, for: indexPath) as? ItemCell
        
        let item = Item.dummy[indexPath.item]
        cell?.setCell(from: item)
        return cell ?? UICollectionViewCell()
    }
}
