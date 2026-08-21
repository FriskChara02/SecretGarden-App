//
//  HomeRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 21/8/26.
//


// Actual implementation of HomeRepositoryProtocol, used for Production/Staging builds.
// Constructor Injection APIClientProtocol - identical to the SeriesRepository pattern.

import CoreArchitecture
import CoreModels
import CoreNetworking
import Foundation

public final class HomeRepository: HomeRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchContinueReading() async throws -> [ContinueReadingItem] {
        try await apiClient.request(HomeEndpoint.continueReading)
    }

    public func fetchLatestUpdates(page: Int) async throws -> [Series] {
        try await apiClient.request(HomeEndpoint.latestUpdates(page: page))
    }

    public func fetchRanking(range: RankingRange, page: Int) async throws -> [Series] {
        try await apiClient.request(HomeEndpoint.ranking(range: range, page: page))
    }

    public func fetchRandomComments() async throws -> [Comment] {
        try await apiClient.request(HomeEndpoint.randomComments)
    }
}
