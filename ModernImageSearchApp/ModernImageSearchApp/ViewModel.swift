//
//  ViewModel.swift
//  ModernImageSearchApp
//
//  Created by Wellington Moreno on 1/13/26.
//

import Combine
import Foundation
import SwiftUI


@MainActor
final class ViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var items: [ImageItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repo: ImageSearchRepository
    private var page: Int = 1
    private var nextPage: Int? = 1
    
    init(repo: ImageSearchRepository) {
        self.repo = repo
    }
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        page = 1
        nextPage = 1
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await repo.search(
                query: query,
                page: page
            )
            items = result.items
            nextPage = result.nextPage
        } catch {
            errorMessage = String(describing: error)
        }
    }
    
    func loadMoreIfNeeded(currentItem: ImageItem) async {
        guard let next = nextPage else { return }
        guard currentItem.id == items.last?.id else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let result = try await repo.search(
                query: query,
                page: next
            )
            items += result.items
            nextPage = result.nextPage
        } catch {
            errorMessage = String(describing: error)
        }
    }
}
