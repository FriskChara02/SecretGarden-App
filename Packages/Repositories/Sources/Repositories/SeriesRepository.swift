//
//  SeriesRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 10/8/26.
//

// SeriesRepository.swift
// Actual implementation of SeriesRepositoryProtocol.
//
// ⚠️ TEMPORARY STUB: CoreNetworking lacks a real APIClient,
// so all methods here currently throw an explicit AppError instead of returning fake data
// — to avoid the misconception that it is "fully functional" when network connectivity hasn't actually been established.

import CoreArchitecture
import CoreModels
import CoreNetworking
import CoreStorage
import Foundation

public final class SeriesRepository: SeriesRepositoryProtocol {

    public init() {
        // TODO: get real APIClient via initializer (constructor injection),
        // eg: public init(apiClient: APIClientProtocol) { self.apiClient = apiClient }
    }

    public func fetchSeriesDetail(id: String) async throws -> Series {
        // TODO: call apiClient.request(Endpoint.seriesDetail(id: id))
        throw AppError.unknown("SeriesRepository.fetchSeriesDetail chưa implement — hoàn thiện ở (Networking)")
    }

    public func fetchChapters(seriesId: String) async throws -> [Chapter] {
        // TODO: call apiClient.request(Endpoint.chapters(seriesId: seriesId))
        throw AppError.unknown("SeriesRepository.fetchChapters chưa implement — hoàn thiện ở (Networking)")
    }

    public func fetchRelatedSeries(seriesId: String) async throws -> [Series] {
        // TODO: call apiClient.request(Endpoint.relatedSeries(seriesId: seriesId))
        throw AppError.unknown("SeriesRepository.fetchRelatedSeries chưa implement — hoàn thiện ở (Networking)")
    }

    public func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        // TODO: call apiClient.request(Endpoint.favorite(seriesId:, isFavorited:))
        throw AppError.unknown("SeriesRepository.toggleFavorite chưa implement — hoàn thiện ở (Networking)")
    }
}
