//
//  ItemCell.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import UIKit

final class ItemCell: UICollectionViewCell {
    static let identifier = "ItemCell"

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOffset = .init(width: 10.0, height: 10.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        label.showsExpansionTextWhenTruncated = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        [imageView, nameLabel].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0)
        ])
    }

    func setCell(from item: Item) {
        imageView.load(url: URL(string: item.img)!)
        nameLabel.text = item.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
