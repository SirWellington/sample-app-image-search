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
    private var imageSearchAPI: ImageSearchAPI!
    private var searchTask: Task<Void, Never>?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        mainVC = MainVC()
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
        imageSearchAPI = PexelsAPI()
        
        let request = ImageSearchRequest(query: "Zelda")
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await self.imageSearchAPI.searchImages(
                    request: request
                )
                print("Found \(response.totalResults) total results for \(request.query)")
            } catch {
                print("API error: \(error)")
            }
        }
    }
    
    func finish() {
        window.rootViewController = nil
        mainVC = nil
        searchTask?.cancel()
        searchTask = nil
    }
}
