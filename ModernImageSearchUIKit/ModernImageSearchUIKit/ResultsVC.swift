//
//  ResultsVC.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Foundation
import UIKit

class ResultsVC: UIViewController    {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, ImageID>?
    private var orderedIDs: [ImageID] = []
    private var imageLookup: [ImageID: Image] = [:]
    
    var actionHandler: ActionHandler?
    var model = Model() {
        didSet {
            applyModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAndArrangeViews()
        setupConstraints()
        applyModel()
    }
    
}

//======================================
// MARK: View Setup
//======================================
private extension ResultsVC {
    func setupAndArrangeViews() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.minimumLineSpacing = Spacing.space8
        layout.minimumInteritemSpacing = Spacing.space8
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: ImageCell.reusedID
        )
        
        let dataSource = UICollectionViewDiffableDataSource<Section, ImageID>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, id in
            let emptyCell = UICollectionViewCell()
            guard let self else { return nil }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCell.reusedID,
                for: indexPath
            ) as? ImageCell else {
                return emptyCell
            }
            
            if let image = self.imageLookup[id] {
                cell.setupWith(image: image)
            }
            
            return cell
        }
        collectionView.dataSource = dataSource
        self.dataSource = dataSource
        view.addAutolayoutSubview(collectionView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate(
            collectionView.constraintsPinningTo(
                view,
                safeArea: true,
                offset: Spacing.space16
            )
        )
    }
}

//======================================
// MARK: Actions
//======================================
extension ResultsVC {
    typealias ActionHandler = (Action) -> Void
    
    enum Action: Equatable {
        case didSelectImage(Image)
    }
}
//======================================
// MARK: Model
//======================================
extension ResultsVC {
    struct Model: Equatable {
        var images: [Image] = []
        var errorMessage: String? = nil
    }
    
    private func applyModel() {
        orderedIDs = model.images.map(\.id)
        imageLookup = [:]
        for image in model.images {
            imageLookup[image.id] = image
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ImageID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(orderedIDs)
        dataSource?.apply(
            snapshot,
            animatingDifferences: true
        )
    }
}

//======================================
// MARK: Collection View Methods
//======================================
extension ResultsVC: UICollectionViewDelegate {
    enum Section: Int, CaseIterable {
        case main
    }
    typealias ImageID = String
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let dataSource else { return }
        guard let imageId = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let image = imageLookup[imageId] else { return }
        actionHandler?(.didSelectImage(image))
    }
}

//======================================
// MARK: Image Cell
//======================================
extension ResultsVC {
    class ImageCell: UICollectionViewCell {
        static let reusedID: String = "ImageCell"
        
        private let imageView = UIImageView()
        private var image: Image?
        private var loadTask: Task<Void, Never>?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupAndArrangeViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupAndArrangeViews() {
            contentView.addAutolayoutSubview(imageView)
            imageView.image = nil
            imageView.contentMode = .scaleAspectFill
            contentView.clipsToBounds = true
            NSLayoutConstraint.activate(
                imageView.constraintsPinningTo(contentView)
            )
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.image = nil
            loadTask?.cancel()
            loadTask = nil
            image = nil
        }
        
        func setupWith(image: Image) {
            self.image = image
            
            // Load thumbnail
            loadTask = Task { [weak self] in
                guard let self, let image = self.image else { return }
                let thumbnailURL = image.thumbnailURL
                
                do {
                    let binaryImage = try await ImageLoader.shared.getImage(
                        url: thumbnailURL
                    )
                    guard !Task.isCancelled else { return }
                    
                    await MainActor.run { [weak self] in
                        self?.imageView.image = binaryImage
                    }
                } catch {
                    print("Failed to load image: \(error)")
                }
            }
        }
    }
}

//======================================
// MARK: Layout
//======================================
extension ResultsVC: UICollectionViewDelegateFlowLayout {
    enum Layout {
        static let columns = 3
        static let spacing = Spacing.space8
        static let inset = UIEdgeInsets(
            top: Spacing.space16,
            left: Spacing.space16,
            bottom: Spacing.space16,
            right: Spacing.space16
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Layout.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Layout.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        Layout.inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = CGFloat(Layout.columns - 1)
            * Layout.spacing
            + (Layout.inset.left + Layout.inset.right)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / CGFloat(Layout.columns))
        
        // Square
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
