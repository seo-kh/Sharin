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
    let itemStore = ItemStore()
    let networkManager = NetworkManager()
    
    private var cancellables = Set<AnyCancellable>()
    let itemPickerViewModel = ItemPickerViewModel()
    let modelTranslator = CurrentValueSubject<ModelEntity?, Never>(nil)
    let isActivate: AnyPublisher<Bool, Never>
    var animationController: AnimationPlaybackController?
    
    let cancel = PassthroughSubject<Void, Never>()
    let item = PassthroughSubject<CameraViewController, Never>()
    let check = PassthroughSubject<CameraViewController, Never>()
    let select = PassthroughSubject<(UITapGestureRecognizer, CameraViewController), Never>()
    let delete = PassthroughSubject<Void, Never>()
    let isLoading: AnyPublisher<Bool, Never>
    
    init() {
        self.isActivate = itemPickerViewModel
            .itemPick
            .map { $0 != nil }
            .eraseToAnyPublisher()
        
        self.isLoading = networkManager
            .isLoading
            .eraseToAnyPublisher()
        
        itemStore
            .items
            .assign(to: \.items, on: itemPickerViewModel)
            .store(in: &cancellables)
        
        itemPickerViewModel
            .itemPick
            .compactMap { $0 }
            .sink(receiveValue: {
                [weak self] in
                self?.networkManager.startDownloading(item: $0)
            })
            .store(in: &cancellables)
        
        itemPickerViewModel
            .refresh
            .sink { [weak self] in
                self?.itemStore.fetchAllItems()
            }
            .store(in: &cancellables)
        
        cancel
            .sink { [weak self] in
                self?.itemPickerViewModel.itemPick.send(nil)
                self?.modelTranslator.send(nil)
                self?.stopAndDiscardAnimation()
            }
            .store(in: &cancellables)
        
        item
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
        
        select
            .sink { [weak self] gesture, cvc in
                self?.didSelect(gesture, cvc: cvc)
            }
            .store(in: &cancellables)
        
        delete
            .sink { [weak self] in
                if let model = self?.modelTranslator.value {
                    model.parent?.removeFromParent()
                }
                self?.modelTranslator.send(nil)
                self?.stopAndDiscardAnimation()
            }
            .store(in: &cancellables)
    }
    
    private func stopAndDiscardAnimation() {
        animationController?.stop()
        animationController = nil
    }
    
    private func didSelect(_ sender: UITapGestureRecognizer, cvc: CameraViewController) {
        let position = sender.location(in: cvc.arView)
        
        if let entity = cvc.arView.entity(at: position) as? ModelEntity {
            cvc.generator.notificationOccurred(.success)
            
            if let controller = animationController {
                DispatchQueue.main.async { [weak self] in
                    self?.modelTranslator.send(nil)
                    controller.stop()
                    let animation = self?.defineAnimation(relativeTo: entity, isBack: true)
                    self?.animationController = entity.playAnimation(animation!)
                    self?.animationController = nil
                }
            } else {
                let animation = defineAnimation(relativeTo: entity)
                animationController = entity.playAnimation(animation)
            }
            
            self.modelTranslator.send(entity)
            let item = self.itemPickerViewModel.getItem(fromId: entity.name)
            self.itemPickerViewModel.itemPick.send(item)
        } else {
            self.modelTranslator.send(nil)
        }
        
    }
    
    private func didTap(_ cvc: CameraViewController) {
        cvc.generator.notificationOccurred(.success)
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
            
            stopAndDiscardAnimation()
            
            // 해당 위치에 entity가 없으면 새로운 anchor추가
        } else if let first = results.first {
            let anchor = ARAnchor(name: "anchor", transform: first.worldTransform)
            cvc.arView.session.add(anchor: anchor)
        }
    }
    
    func makeHighlightPalte(id: String) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: 0.20, depth: 0.20, cornerRadius: 0.10)
        let material = SimpleMaterial(color: .sharinQuaternary, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = id
        entity.isEnabled = false
        return entity
    }
    
    func loadEntity(for anchor: ARAnchor, cvc: CameraViewController) {
        let anchorEntity = AnchorEntity(world: anchor.transform)

        guard let item = itemPickerViewModel.itemPick.value,
              let url = networkManager.target else { return }

        Entity.loadModelAsync(contentsOf: url)
            .sink { _ in
                //
            } receiveValue: { entity in
                entity.generateCollisionShapes(recursive: false)
                entity.name = item.id
                anchorEntity.addChild(entity)
                cvc.arView.scene.addAnchor(anchorEntity)
                cvc.arView.installGestures(.all, for: entity)
            }
            .store(in: &cancellables)
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
                duration: 0.5,
                timing: .easeInOut,
                bindTarget: .transform,
                repeatMode: .autoReverse
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
