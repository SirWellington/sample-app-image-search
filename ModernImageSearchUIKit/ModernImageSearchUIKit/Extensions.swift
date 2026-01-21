//
//  Extensions.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/20/26.
//

import Foundation
import UIKit

extension UIView {
    func addAutolayoutSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
}
extension UIStackView {
    convenience init(
        axis: NSLayoutConstraint.Axis,
        distribution: Distribution = .fill,
        spacing: CGFloat = Spacing.space8,
        alignment: Alignment = .fill
    ) {
        self.init()
        self.axis = axis
        self.distribution = distribution
        self.spacing = spacing
        self.alignment = alignment
    }
    
    func addArrangeSubviews(_ views: UIView...) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}

extension UILabel {
    convenience init(
        text: String? = nil,
        textAlignment: NSTextAlignment = .natural
    ) {
        self.init()
        self.text = text
        self.textAlignment = textAlignment
    }
}

enum Spacing {
    static let space8: CGFloat = 8
    static let space16: CGFloat = 16
}

extension NSLayoutConstraint {
    static func activate(_ constraints: NSLayoutConstraint...) {
        NSLayoutConstraint.activate(Array(constraints))
    }
}
