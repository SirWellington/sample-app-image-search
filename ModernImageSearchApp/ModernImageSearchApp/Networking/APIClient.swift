//
//  APIClient.swift
//  ModernImageSearchApp
//
//  Created by Wellington Moreno on 1/13/26.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
}

struct SearchImagesRequest: Equatable {
    let text: String
}
struct SearchImagesResponse: Equatable, Codable {
    let reslts: [Result]

    struct Result: Equatable, Codable {
        let id: String
        let fullUrl: String
        let thumbnailUrl: String?
    }
}

protocol APIClientProtocol {
    func searchImages(
        _ request: SearchImagesRequest
    ) async throws -> SearchImagesResponse
}
