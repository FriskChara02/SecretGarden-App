//
//  SeriesRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 10/8/26.
//

// Actual implementation of SeriesRepositoryProtocol.
// Networking — receive APIClientProtocol via constructor injection,
// do NOT instantiate APIClient() internally (makes testing difficult, violates Dependency Inversion).

import CoreArchitecture
import CoreModels
import CoreNetworking
import CoreStorage
import Foundation

public final class SeriesRepository: SeriesRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchSeriesDetail(id: String) async throws -> Series {
        try await apiClient.request(SeriesEndpoint.seriesDetail(id: id))
    }

    public func fetchChapters(seriesId: String) async throws -> [Chapter] {
        try await apiClient.request(SeriesEndpoint.chapters(seriesId: seriesId))
    }

    public func fetchRelatedSeries(seriesId: String) async throws -> [Series] {
        try await apiClient.request(SeriesEndpoint.relatedSeries(seriesId: seriesId))
    }

    public func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        try await apiClient.requestWithoutResponse(
            SeriesEndpoint.favorite(seriesId: seriesId, isFavorited: isFavorited)
        )
    }
}
