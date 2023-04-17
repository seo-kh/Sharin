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

    let vm = CameraViewModel()
    let coachingOverlay = ARCoachingOverlayView()
//    var arView: ARView!
    var arView: FocusARView!
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = FocusARView(frame: .zero)
        arView.session.delegate = self
        view = arView
        
        setAttributesAndLayouts()
        setupCoachingOverlay()
        bind()
    }
    
    private let checkButton = SharinButton(systemName: "checkmark")
    private let cancelButton = SharinButton(systemName: "xmark")
    private let deleteButton = SharinButton(systemName: "trash")
    private let alertLabel = UILabel()
    private let generator = UINotificationFeedbackGenerator()
    
    private func bind() {
        
        vm.isActivate
            .sink { [weak self] isEnabled in
                self?.arView.focusEntity?.isEnabled = isEnabled
                self?.checkButton.isHidden = !isEnabled
                self?.checkButton.isEnabled = isEnabled
                self?.cancelButton.isHidden = !isEnabled
                self?.cancelButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        arView.session.run(config)
        
        // place any object
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didSelect))
        arView.addGestureRecognizer(recognizer)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        arView.session.pause()
        cancellables.removeAll()
        super.viewWillDisappear(animated)
    }
    
    @objc private func didSelect(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: arView)
        
        if let entity = arView.entity(at: position) as? ModelEntity {
            generator.notificationOccurred(.success)
            
            if let controller = vm.animationController {
                controller.stop()
                let animation = vm.defineAnimation(relativeTo: entity, isBack: true)
                vm.animationController = entity.playAnimation(animation)
                vm.animationController = nil
            } else {
                let animation = vm.defineAnimation(relativeTo: entity)
                vm.animationController = entity.playAnimation(animation)
            }
            
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
            vm.modelTranslator.send(entity)
                
        } else {
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
        }
    
    }
    
    private func didTap() {
        let position = arView.center
        let results = arView.raycast(from: position, allowing: .estimatedPlane, alignment: .any)
        
        // 해당 위치에 entity가 있으면 그 entity 선택
        if let _ = arView.entity(at: position) as? ModelEntity {
            generator.notificationOccurred(.error)
            alertLabel.isEnabled = true
            alertLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.alertLabel.isEnabled = false
                self?.alertLabel.isHidden = true
            }
            
            vm.animationController?.stop()
            vm.animationController = nil
            
        // 해당 위치에 entity가 없으면 새로운 anchor추가
        } else if let first = results.first {
            let anchor = ARAnchor(name: "anchor", transform: first.worldTransform)
            arView.session.add(anchor: anchor)
        }
    }
    
}

extension CameraViewController {
    func resetTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func loadEntity(for anchor: ARAnchor) {
        let anchorEntity = AnchorEntity(anchor: anchor)
        
        vm.item
            .compactMap { $0 }
            .flatMap({ item -> LoadRequest<ModelEntity> in
                return Entity.loadModelAsync(named: item.usdzURL)
            })
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
            }
            .store(in: &cancellables)
    }
    
    func setAttributesAndLayouts() {
        // UI
        let hStack = UIStackView(axis: .horizontal, alignment: .center, spacing: 24.0)
        hStack.tag = 1
        let selectButton = SharinButton(systemName: Option.find.systemName)
        selectButton.layer.name = Option.find.systemName
        let memoryButton = SharinButton(systemName: Option.store.systemName)
        memoryButton.layer.name = Option.store.systemName
        
        checkButton.tag = 2
        checkButton.isEnabled = false
        checkButton.isHidden = true
        
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.text = "해당 위치에는 소품을 놓을 수 없어요!"
        alertLabel.font = .preferredFont(forTextStyle: .title3)
        alertLabel.backgroundColor = .sharinTertiary
        alertLabel.isEnabled = false
        alertLabel.isHidden = true
        
        cancelButton.tag = 3
        cancelButton.isEnabled = false
        cancelButton.isHidden = true
        
        deleteButton.tag = 4
        deleteButton.isEnabled = false
        deleteButton.isHidden = true
        
        // view hierarchy
        hStack.addArrangedSubview(selectButton)
        hStack.addArrangedSubview(memoryButton)
        arView.addSubview(hStack)
        arView.addSubview(checkButton)
        arView.addSubview(alertLabel)
        arView.addSubview(cancelButton)
        arView.addSubview(deleteButton)
        
        // layout
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            hStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -12.0),
            checkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0),
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelButton.topAnchor.constraint(equalTo: hStack.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 12.0),
            deleteButton.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 40.0),
            deleteButton.bottomAnchor.constraint(equalTo: checkButton.bottomAnchor)
        ])
        
        // function
        selectButton.tapPublisher
            .sink { [weak self] in
                let vc = ItemPickerViewContrller()
                vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
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
        
        checkButton.tapPublisher
            .sink(receiveValue: {[weak self] in self?.didTap() })
            .store(in: &cancellables)
        
        cancelButton.tapPublisher
            .subscribe(vm.cancelAction)
            .store(in: &cancellables)
        
        deleteButton.tapPublisher
            .sink(receiveValue: { [weak self]  in
                if let model = self?.vm.modelTranslator.value {
                    model.parent?.removeFromParent()
                }
                
                self?.deleteButton.isEnabled = false
                self?.deleteButton.isHidden = true
                self?.vm.modelTranslator.send(nil)
            })
            .store(in: &cancellables)
    
    }
}
