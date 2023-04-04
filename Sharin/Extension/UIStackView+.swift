//
//  UIStackView+.swift
//  Sharin
//
//  Created by james seo on 2023/04/04.
//

import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, spacing: CGFloat) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.distribution = .equalSpacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
