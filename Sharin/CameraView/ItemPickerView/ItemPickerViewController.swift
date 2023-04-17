//
//  ItemPickerViewController.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import UIKit
import Combine
import CombineCocoa

final class ItemPickerViewContrller: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "둘러보기"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    private lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .sharinSecondary
        return label
    }()
    
    private lazy var seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.identifier)
        return collectionView
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        layout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
    }
    
    func bind(to viewModel: ItemPickerViewModel) {
        viewModel.ipvc.send(self)
        
        dismissButton.tapPublisher
            .subscribe(viewModel.dismiss)
            .store(in: &cancellables)
        
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
    }
    
    private func layout() {
        [ titleLabel, itemLabel, seperator, collectionView, dismissButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        dismissButton.imageView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30.0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
        ])
        
        NSLayoutConstraint.activate([
            itemLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            itemLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
        ])
        
        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 12.0),
            seperator.widthAnchor.constraint(equalTo: view.widthAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: seperator.topAnchor, constant: 0.5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
            dismissButton.widthAnchor.constraint(equalToConstant: 30.0),
            dismissButton.heightAnchor.constraint(equalToConstant: 30.0),
            dismissButton.imageView!.widthAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 1.0),
            dismissButton.imageView!.heightAnchor.constraint(equalTo: dismissButton.heightAnchor, multiplier: 1.0),
        ])
        
    }
}


