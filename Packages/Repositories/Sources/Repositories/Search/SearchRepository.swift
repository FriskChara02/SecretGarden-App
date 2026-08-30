//
//  SearchRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

// SearchRepository is always a single, genuine instance—there is no separate "SearchRepositoryMock"
// for the repository itself. Search history (SwiftData) always operates using the real implementation regardless of the environment,
// only remoteDataSource (handling search API calls) is selected as either Mock or Real by the Container (see Container+Repositories.swift).

import CoreModels
import CoreStorage
import Foundation

public final class SearchRepository: SearchRepositoryProtocol {
    private let remoteDataSource: SearchRemoteDataSource
    private let localHistoryStore: SearchHistoryLocalStore

    public init(remoteDataSource: SearchRemoteDataSource, localHistoryStore: SearchHistoryLocalStore) {
        self.remoteDataSource = remoteDataSource
        self.localHistoryStore = localHistoryStore
    }

    // MARK: - Search (delegated to remoteDataSource - Mock or Real, determined by the Container)

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        try await remoteDataSource.searchBasic(query: query, page: page)
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        try await remoteDataSource.searchAdvanced(filter: filter, page: page)
    }

    // MARK: - History (Always local via SwiftData — environment-agnostic)
    // TODO(server): If switching to server-side storage, add a "SearchHistoryRemoteDataSource"
    // following the SearchRemoteDataSource pattern above, then update the 4 lines below — the function signatures.
    // SearchRepositoryProtocol itself does NOT need changing; the ViewModel remains unaffected.

    public func fetchHistory() async throws -> [SearchHistoryItem] {
        try await localHistoryStore.fetchAll()
    }

    public func addHistory(query: String) async throws {
        try await localHistoryStore.add(query: query)
    }

    public func removeHistory(id: String) async throws {
        try await localHistoryStore.remove(id: id)
    }

    public func clearHistory() async throws {
        try await localHistoryStore.clearAll()
    }
    
    public func fetchFilterOptions() async throws -> AdvancedFilterOptions {
        try await remoteDataSource.fetchFilterOptions()
    }
}
