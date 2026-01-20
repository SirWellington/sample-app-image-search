//
//  ImageItem.swift
//  ModernImageSearchApp
//
//  Created by Wellington Moreno on 1/13/26.
//

import Foundation

struct ImageItem: Identifiable, Hashable {
    let id: String
    let thumbnailUrl: URL
    let fullUrl: URL
}

protocol ImageSearchRepository {
    func search(query: String, page: Int) async throws -> (
        items: [ImageItem],
        nextPage: Int?
    )
}
