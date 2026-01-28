//
//  ImageViewerVC.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/27/26.
//

import Foundation
import UIKit

final class ImageViewerVC: UIViewController {
    
    private let imageLoader = ImageLoader.shared
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private var imageLoadTask: Task<Void, Never>?
    
    var model: Model?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAndArrangeViews()
        applyModel()
    }
}

//======================================
// MARK: Model
//======================================
extension ImageViewerVC {
    struct Model {
        var image: Image
    }
    
    private func applyModel() {
        guard let model else {
            imageView.image = nil
            return
        }
        let imageURL = model.image.fullSizeURL
        
        imageLoadTask?.cancel()
        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            guard self.imageLoadTask?.isCancelled != true else { return }
            do {
                let image = try await self.imageLoader.getImage(
                    url: imageURL
                )
                guard self.imageLoadTask?.isCancelled != true else { return }
                self.imageView.image = image
            } catch {
                print("Failed to load image \(imageURL): \(error)")
            }
        }
    }
}

//======================================
// MARK: View Setup
//======================================
private extension ImageViewerVC {
    func setupAndArrangeViews() {
        arrangeViews()
        applyStyles()
        setupConstraints()
    }
    
    func arrangeViews() {
        view.addAutolayoutSubview(scrollView)
        scrollView.addAutolayoutSubview(imageView)
    }
    
    func applyStyles() {
        view.backgroundColor = .white
        apply(scrollView) {
            $0.delegate = self
            $0.bounces = true
            $0.showsVerticalScrollIndicator = true
            $0.showsHorizontalScrollIndicator = true
            $0.decelerationRate = .fast
        }
        
        apply(imageView) {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = true
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate(
            scrollView.constraintsPinningTo(view, safeArea: false)
        )
    }
}

//======================================
// MARK: Scroll View
//======================================
extension ImageViewerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
