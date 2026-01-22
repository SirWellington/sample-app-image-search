//
//  ImageLoader.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Foundation
import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    
    private var cache: [URL: UIImage] = [:]
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func clear() {
        cache = [:]
    }
    
    func getImage(url: URL) async throws -> UIImage {
        if let cached = cache[url] {
            print("Found \(url) in cache.")
            return cached
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode,
              let image = UIImage(data: data)
        else {
            throw URLError(.badServerResponse)
        }
        print("Loaded \(url), storing in cache.")
        
        // Store in cache, then return
        cache[url] = image
        return image
    }
}
