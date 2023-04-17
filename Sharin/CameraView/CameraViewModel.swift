//
//  CameraViewModel.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import Foundation
import Combine

final class CameraViewModel {
    private var cancellables = Set<AnyCancellable>()
    let item: AnyPublisher<Item?, Never>
    let itemPickerViewModel = ItemPickerViewModel()
    let isActivate: AnyPublisher<Bool, Never>
    let cancelAction = PassthroughSubject<Void, Never>()
    
    init() {
        self.item = itemPickerViewModel
                .itemPick
                .eraseToAnyPublisher()
        
        let isItemPicked = item
            .map { $0 != nil }
            .eraseToAnyPublisher()
        
        let isCancel = cancelAction
            .map { false }
            .eraseToAnyPublisher()
        
        
        self.isActivate = isItemPicked
            .merge(with: isCancel)
            .eraseToAnyPublisher()
        
        cancelAction
            .sink { [weak self] in self?.itemPickerViewModel.itemPick.send(nil) }
            .store(in: &cancellables)
    }
}
