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
    
    func constraintsPinningTo(
        _ view: UIView,
        safeArea: Bool = false,
        offset: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        if safeArea {
            return [
                topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: offset
                ),
                leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: offset
                ),
                trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -offset
                ),
                bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -offset
                )
            ]
        } else {
            return [
                topAnchor.constraint(
                    equalTo: view.topAnchor,
                    constant: offset
                ),
                leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: offset
                ),
                trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -offset
                ),
                bottomAnchor.constraint(
                    equalTo: view.bottomAnchor,
                    constant: -offset
                )
            ]
        }
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


protocol ViewControllerSetup where Self: UIViewController {
    func arrangeViews()
    func applyStyles()
    func applyConstraints()
}

extension ViewControllerSetup {
    func setupView() {
        arrangeViews()
        applyStyles()
        applyConstraints()
    }
}


func apply<T>(_ elements: T..., closure: (T) -> Void) {
    for element in elements {
        closure(element)
    }
}
