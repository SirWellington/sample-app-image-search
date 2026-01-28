//
//  Coordinator.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Combine
import Foundation
import UIKit


class Coordinator {
    private let window: UIWindow
    private var mainVC: MainVC!
    private var nav: UINavigationController!
    private var imageSearchAPI: ImageSearchAPI!
    private var resultsVC: ResultsVC?
    private var searchTask: Task<Void, Never>?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        mainVC = MainVC()
        mainVC.actionHandler = { [weak self] in
            self?.handle($0)
        }
        
        nav = UINavigationController(rootViewController: mainVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        imageSearchAPI = PexelsAPI()
    }
    
    func finish() {
        window.rootViewController = nil
        nav.popToRootViewController(animated: true)
        mainVC = nil
        searchTask?.cancel()
        searchTask = nil
        resultsVC = nil
        nav = nil
    }
}

//======================================
// MARK: Action Handling
//======================================
private extension Coordinator {
    func handle(_ action: MainVC.Action) {
        switch action {
        case .didTapSearch(let text):
            didTapSearch(text: text)
        default:
            break
        }
    }
    
    func handle(_ action: ResultsVC.Action) {
        switch action {
        case .didSelectImage(let image):
            showImage(image)
        }
    }
    
    func didTapSearch(text: String?) {
        guard let text, !text.isEmpty else { return }
        let request = ImageSearchRequest(query: text)
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await self.imageSearchAPI.searchImages(
                    request: request
                )
                print("Found \(response.totalResults) total results for \(request.query)")
                self.didLoadSearch(response)
            } catch {
                print("API error: \(error)")
            }
        }
    }
    
    func showImage(_ image: Image) {
        let imageViewerVC = ImageViewerVC()
        imageViewerVC.model = ImageViewerVC.Model(image: image)
        nav.pushViewController(imageViewerVC, animated: true)
    }
    
    @MainActor
    func didLoadSearch(_ response: ImageSearchResponse) {
        let resultsVC = ResultsVC()
        resultsVC.actionHandler = { [weak self] in
            self?.handle($0)
        }
        self.resultsVC = resultsVC
        nav.pushViewController(resultsVC, animated: true)
        
        resultsVC.model = ResultsVC.Model(
            images: response.images
        )
    }
}
