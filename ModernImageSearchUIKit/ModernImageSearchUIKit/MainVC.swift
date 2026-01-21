//
//  MainVC.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/20/26.
//

import UIKit

class MainVC: UIViewController {
    private let stackView = UIStackView(
        axis: .vertical,
        distribution: .fill,
        spacing: Spacing.space8,
        alignment: .center
    )
    private let icon = UIImageView()
    private let titleLabel = UILabel(
        text: Text.title,
        textAlignment: .center
    )
    private let subtitleLabel = UILabel(
        text: Text.subtitle,
        textAlignment: .center
    )
    private var searchBar = UISearchBar()

    var actionHandler: ActionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        arrangeViews()
        applyConstraints()
    }
}

//======================================
// MARK: View Setup
//======================================
private extension MainVC {
    func arrangeViews() {
        view.addAutolayoutSubview(stackView)
        stackView.addArrangeSubviews(
            icon,
            titleLabel,
            subtitleLabel,
            searchBar
        )
        
        searchBar.delegate = self
    }
    
    func applyStyle() {
        view.backgroundColor = UIColor(
            red: 240,
            green: 240,
            blue: 240,
            alpha: 1
        )
        titleLabel.font = .preferredFont(forTextStyle: .title1)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate(
            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Spacing.space16
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Spacing.space16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Spacing.space16
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            searchBar.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                constant: -Spacing.space16 * 2
            )
        )
    }
}

//======================================
// MARK: Actions
//======================================
extension MainVC: UISearchBarDelegate {
    typealias ActionHandler = (Action) -> ()
    
    enum Action {
        case didEditSearchBar(text: String?)
        case didTapSearch(text: String?)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        actionHandler?(
            .didEditSearchBar(text: searchText)
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        actionHandler?(
            .didEditSearchBar(
                text: searchBar.text
            )
        )
    }
}
//======================================
// MARK: Text
//======================================
extension MainVC {
    enum Text {
        static let title = "Image Search"
        static let subtitle = "Type something to beging searching for images."
    }
}
