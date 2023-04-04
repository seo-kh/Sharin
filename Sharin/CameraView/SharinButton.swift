//
//  SharinButton.swift
//  Sharin
//
//  Created by james seo on 2023/03/29.
//

import UIKit

final class SharinButton: UIButton {
    let systemName: String
    let action: () -> Void
    
    init(systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
        super.init(frame: .zero)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.setImage(UIImage(systemName: systemName), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.addBlurEffect(style: .systemThickMaterial, cornerRadius: 16.0, padding: 3.0)
        self.addAction(.init(handler: { [weak self] _ in self?.action() }), for: .touchUpInside)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 32.0),
            self.heightAnchor.constraint(equalToConstant: 32.0),
            self.imageView!.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.imageView!.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
    }
    
}
