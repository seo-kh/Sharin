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
    
    var animationController: AnimationPlaybackController?
    
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
    
    func defineAnimation(relativeTo referenceEntity: Entity, isBack: Bool = false) -> AnimationResource {
        var from: Transform = referenceEntity.transform
        var to: Transform = referenceEntity.transform
        var animationDefinition: AnimationDefinition
        let referenceTranslation = referenceEntity.transform.translation
        
        switch isBack {
        case true:
            // +y (위방향) 1cm이동
            from.translation.y += 0.01
            // +y (위방향) 5cm까지 이동
            to .translation.y += 0.05
            animationDefinition = FromToByAnimation(
                name: "up-and-down",
                from: from,
                to: to,
                duration: 2.0,
                timing: .easeOut,
                bindTarget: .transform,
                repeatMode: .autoReverse
            )
        case false:
            // -y (아래방향) 0 cm까지 이동
            to.translation.y = 0.0
            animationDefinition = FromToByAnimation(
                name: "identity",
                from: from,
                to: to,
                duration: 0.2,
                timing: .easeOut,
                bindTarget: .transform,
                repeatMode: .none
            )
        }
        
        return try! AnimationResource.generate(with: animationDefinition)
        
    }
}
