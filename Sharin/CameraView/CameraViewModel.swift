//
//  CameraViewModel.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import Foundation
import Combine
import RealityKit

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
    
    func defineAnimation(relativeTo referenceEntity: Entity) -> AnimationResource {
        // 원래 위치에서 +y 방향으로 1cm 이동
        var from = referenceEntity.transform
        from.translation += [0.0, 0.01, 0.0]
        // +y 방향으로 10cm 이동
        var to = referenceEntity.transform
        to.translation += [0.0, 0.10, 0.0]
        
        let upAndDownDefinition = FromToByAnimation(
            name: "Up-and-Down",
            from: from,
            to: to,
            duration: 2.0,
            timing: .easeOut,
            bindTarget: .transform,
            repeatMode: .autoReverse
        )
        
        return try! AnimationResource.generate(with: upAndDownDefinition)
        
    }
}
