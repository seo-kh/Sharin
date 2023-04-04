//
//  CameraViewController.swift
//  Sharin
//
//  Created by james seo on 2023/03/29.
//

import UIKit
import Combine
import CombineCocoa
import RealityKit
import ARKit

final class CameraViewController: UIViewController {
    
    enum Option: CaseIterable {
        case find
        case store
        
        var systemName: String {
            switch self {
            case .find: return "magnifyingglass"
            case .store: return "square.and.arrow.down"
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()
    let vm = CameraViewModel()
    var arView: ARView!

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.session.delegate = self
        view = arView
        
        setButtonGroup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        arView.session.run(config)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        arView.addGestureRecognizer(recognizer)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        arView.session.pause()
        cancellables.removeAll()
        super.viewWillDisappear(animated)
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: arView)
        let results = arView.raycast(from: position, allowing: .estimatedPlane, alignment: .any)
        
        // 해당 위치에 entity가 있으면 그 entity 선택
        if let entity = arView.entity(at: position) as? ModelEntity {
            print("찾았다. ", entity.name)
        // 해당 위치에 entity가 없으면 새로운 anchor추가
        } else if let first = results.first {
            let anchor = ARAnchor(name: "anchor", transform: first.worldTransform)
            arView.session.add(anchor: anchor)
        }
    }
    
    private func loadEntity(for anchor: ARAnchor) {
        let anchorEntity = AnchorEntity(anchor: anchor)
        
        guard let asset = vm.asset else { return }
        
        Entity.loadModelAsync(named: asset)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] entity in
                entity.generateCollisionShapes(recursive: true)
                anchorEntity.addChild(entity)
                self?.arView.scene.addAnchor(anchorEntity)
                self?.arView.installGestures(.all, for: entity)
                print("in loadEntity: ", asset)
            }
            .store(in: &cancellables)
    }
}

extension CameraViewController {
    func setButtonGroup() {
        // UI
        let hStack = UIStackView(axis: .horizontal, alignment: .center, spacing: 24.0)
        let selectButton = SharinButton(systemName: Option.find.systemName)
        selectButton.layer.name = Option.find.systemName
        let memoryButton = SharinButton(systemName: Option.store.systemName)
        memoryButton.layer.name = Option.store.systemName
        
        // view hierarchy
        hStack.addArrangedSubview(selectButton)
        hStack.addArrangedSubview(memoryButton)
        view.addSubview(hStack)
        
        // layout
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            hStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -12.0)
        ])
        
        // function
        selectButton.tapPublisher
            .sink { [weak self] in
                let vc = ItemPickerViewContrller()
                vc.bind(to: (self?.vm.itemPickerViewModel)!)
                self?.present(vc, animated: true)
            }
            .store(in: &cancellables)
        
        // TODO: - memory button
        memoryButton.tapPublisher
            .sink {
                print("구현 예정")
            }
            .store(in: &cancellables)
    }
}

extension CameraViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "anchor" {
                loadEntity(for: anchor)
            }
        }
    }
}
