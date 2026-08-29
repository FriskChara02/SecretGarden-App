//
//  SearchRemoteDataSource.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

// Separate the "search API call" logic from SearchRepository so that the Container (App target)
// can choose between Mock and Real implementations without SearchRepository having a reverse dependency on AppConfig.

import CoreModels
import Foundation
import CoreNetworking

public protocol SearchRemoteDataSource: Sendable {
    func searchBasic(query: String, page: Int) async throws -> [Series]
    func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series]
}

// MARK: - Production version, calling APIClient

public final class SearchRemoteAPIDataSource: SearchRemoteDataSource {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        try await apiClient.request(SearchEndpoint.basicSearch(query: query, page: page))
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        try await apiClient.request(SearchEndpoint.advancedSearch(filter: filter, page: page))
    }
}

// MARK: - Mock version, used for debugging (to avoid DNS errors since the actual backend does not yet exist).

public final class SearchRemoteMockDataSource: SearchRemoteDataSource {
    public init() {}

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        []
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        []
    }
}
