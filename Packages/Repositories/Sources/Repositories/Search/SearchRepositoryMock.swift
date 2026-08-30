//
//  SearchRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

// Mock the entire Repository (both search and history) - use ONLY for SwiftUI Previews and Unit Tests

import CoreModels
import Foundation

public final class SearchRepositoryMock: SearchRepositoryProtocol {
    private var mockHistory: [SearchHistoryItem]

    public init(mockHistory: [SearchHistoryItem] = SearchRepositoryMock.sampleHistory) {
        self.mockHistory = mockHistory
    }

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        []
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        []
    }

    public func fetchHistory() async throws -> [SearchHistoryItem] {
        mockHistory.sorted { $0.searchedAt > $1.searchedAt }
    }

    public func addHistory(query: String) async throws {
        mockHistory.append(SearchHistoryItem(query: query))
    }

    public func removeHistory(id: String) async throws {
        mockHistory.removeAll { $0.id == id }
    }

    public func clearHistory() async throws {
        mockHistory.removeAll()
    }

    public static var sampleHistory: [SearchHistoryItem] {
        [
            SearchHistoryItem(query: "Đồ ăn của ta trông thật đáng yêu", searchedAt: Date().addingTimeInterval(-3600)),
            SearchHistoryItem(query: "Saki", searchedAt: Date().addingTimeInterval(-7200))
        ]
    }
    
    public func fetchFilterOptions() async throws -> AdvancedFilterOptions {
        AdvancedFilterOptions()
    }
}
