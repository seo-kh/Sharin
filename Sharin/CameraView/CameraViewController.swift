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

    // MARK: - PROPERTIES
    /// View Model
    let vm = CameraViewModel()
    /// Parent Views
    let coachingOverlay = ARCoachingOverlayView()
    var arView: FocusARView!
    /// SubViews
    let selectButton = SharinButton(systemName: Option.find.systemName)
    let memoryButton = SharinButton(systemName: Option.store.systemName)
    let checkButton = SharinButton(systemName: "checkmark")
    let cancelButton = SharinButton(systemName: "xmark")
    let deleteButton = SharinButton(systemName: "trash")
    let recognizer = UITapGestureRecognizer()
    let alertLabel = UILabel()
    let generator = UINotificationFeedbackGenerator()
    /// cancellables (Combine)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = FocusARView(frame: .zero)
        arView.session.delegate = self
        view = arView
        
        /// setting subviews
        attribute()
        layout()
        /// setting coachingOverlayView
        setupCoachingOverlay()
        /// binding between View and Viewmodel.
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        arView.session.run(config)
        arView.addGestureRecognizer(recognizer)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        arView.session.pause()
        cancellables.removeAll()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - BIND
    private func bind() {
        vm.isActivate
            .sink { [weak self] in
                self?.arView.focusEntity?.isEnabled = $0
                self?.cancelButton.isEnabled = $0
                self?.cancelButton.isHidden = !$0
                self?.checkButton.isEnabled = $0
                self?.checkButton.isHidden = !$0
            }
            .store(in: &cancellables)
        
        vm.modelTranslator
            .map { $0 != nil }
            .sink { [weak self] in
                self?.deleteButton.isHidden = !$0
                self?.deleteButton.isEnabled = $0
            }
            .store(in: &cancellables)
        
        selectButton.tapPublisher
            .map { self }
            .subscribe(vm.item)
            .store(in: &cancellables)
        
        // TODO: - memory button
        memoryButton.tapPublisher
            .sink {
                print("구현 예정")
            }
            .store(in: &cancellables)
        
        checkButton.tapPublisher
            .map { self }
            .subscribe(vm.check)
            .store(in: &cancellables)
        
        cancelButton.tapPublisher
            .subscribe(vm.cancel)
            .store(in: &cancellables)
        
        recognizer.tapPublisher
            .map { ($0, self) }
            .subscribe(vm.select)
            .store(in: &cancellables)
        
        deleteButton.tapPublisher
            .subscribe(vm.delete)
            .store(in: &cancellables)
    }
    
}

// MARK: - SETTING
extension CameraViewController {
    func resetTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    func attribute() {
        // UI
        
        selectButton.layer.name = Option.find.systemName
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
    }
    
    func layout() {
        // view hierarchy
        let hStack = UIStackView(axis: .horizontal, alignment: .center, spacing: 24.0)
        hStack.tag = 1
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
    }
}
