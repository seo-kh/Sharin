//
//  CameraViewModel.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import Foundation
import Combine
import RealityKit
import ARKit

final class CameraViewModel {
    private var cancellables = Set<AnyCancellable>()
    let item: AnyPublisher<Item?, Never>
    let itemPickerViewModel = ItemPickerViewModel()
    let isActivate: AnyPublisher<Bool, Never>
    let cancelAction = PassthroughSubject<Void, Never>()
    let modelTranslator = CurrentValueSubject<ModelEntity?, Never>(nil)
    var animationController: AnimationPlaybackController?
    
    let select = PassthroughSubject<CameraViewController, Never>()
    let check = PassthroughSubject<CameraViewController, Never>()
    
    init() {
        
        
        self.item = itemPickerViewModel
                .itemPick
                .eraseToAnyPublisher()
        
        self.isActivate = itemPickerViewModel
            .itemPick
            .map { $0 != nil }
            .eraseToAnyPublisher()

        cancelAction
            .sink { [weak self] in self?.itemPickerViewModel.itemPick.send(nil) }
            .store(in: &cancellables)
        
        select
            .sink { [weak self] cvc in
                guard let self = self else { return }
                let vc = ItemPickerViewContrller()
                vc.modalPresentationStyle = .overFullScreen
                vc.bind(to: self.itemPickerViewModel)
                cvc.present(vc, animated: true)
            }
            .store(in: &cancellables)
        
        check
            .sink { [weak self] in self?.didTap($0) }
            .store(in: &cancellables)
        
    }
    
    func didTap(_ cvc: CameraViewController) {
        let position = cvc.arView.center
        let results = cvc.arView.raycast(from: position, allowing: .estimatedPlane, alignment: .any)
        
        // 해당 위치에 entity가 있으면 그 entity 선택
        if let _ = cvc.arView.entity(at: position) as? ModelEntity {
            cvc.generator.notificationOccurred(.error)
            cvc.alertLabel.isEnabled = true
            cvc.alertLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak cvc] in
                cvc?.alertLabel.isEnabled = false
                cvc?.alertLabel.isHidden = true
            }
            
            animationController?.stop()
            animationController = nil
            
        // 해당 위치에 entity가 없으면 새로운 anchor추가
        } else if let first = results.first {
            let anchor = ARAnchor(name: "anchor", transform: first.worldTransform)
            cvc.arView.session.add(anchor: anchor)
        }
    }
    
    func defineAnimation(relativeTo referenceEntity: Entity, isBack: Bool = false) -> AnimationResource {
        var from: Transform = referenceEntity.transform
        var to: Transform = referenceEntity.transform
        var animationDefinition: AnimationDefinition
        
        switch isBack {
        case false:
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
                repeatMode: .none
            )
        case true:
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
