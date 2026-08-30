//
//  SearchRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

import CoreModels
import Foundation

public protocol SearchRepositoryProtocol {
    // MARK: - Search (always calls the real API)

    func searchBasic(query: String, page: Int) async throws -> [Series]
    func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series]
    func fetchFilterOptions() async throws -> AdvancedFilterOptions

    // MARK: - Search history (local data source via SwiftData)
    // The ViewModel calls these functions without needing to know whether the underlying
    // implementation is local or remote — this is the value of the Repository Pattern:
    // if you want to switch to a server-side solution later (for multi-device
    // synchronization), you only need to change the implementation in SearchRepository,
    // with NO need to modify SearchViewModel or SearchView.

    func fetchHistory() async throws -> [SearchHistoryItem]
    func addHistory(query: String) async throws
    func removeHistory(id: String) async throws
    func clearHistory() async throws
}
