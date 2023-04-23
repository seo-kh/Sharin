//
//  ItemCell.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import UIKit

final class ItemCell: UICollectionViewCell {
    static let identifier = "ItemCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        imageView.layer.cornerRadius = 12.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOffset = .init(width: 10.0, height: 10.0)
        imageView.layer.masksToBounds = false
        contentView.clipsToBounds = false
    }
    
    func setCell(from item: Item) {
        if let view = contentView.subviews.first as? UIImageView {
            view.image = UIImage(named: item.usdzURL)
            view.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.text = item.title
            label.font = .preferredFont(forTextStyle: .headline)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 1
            label.showsExpansionTextWhenTruncated = true
            
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
