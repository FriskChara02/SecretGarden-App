//
//  MockSeriesRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 10/8/26.
//

// Mock implementation for unit testing (ViewModel tests will
// reuse this pattern rather than copy-pasting). It allows for "pre-programming"
// the desired return values ​​or errors to verify that the ViewModel reacts correctly.

import CoreArchitecture
import CoreModels
@testable import Repositories

final class MockSeriesRepository: SeriesRepositoryProtocol {

    // MARK: - The result can be "pre-programmed" from outside the test case.

    var seriesDetailResult: Result<Series, AppError> = .failure(.unknown("chưa cấu hình mock"))
    var chaptersResult: Result<[Chapter], AppError> = .success([])
    var relatedSeriesResult: Result<[Series], AppError> = .success([])
    var toggleFavoriteResult: Result<Void, AppError> = .success(())

    // MARK: - Record the call (call tracking) to verify that the correct parameters are passed.

    private(set) var fetchSeriesDetailCallCount = 0
    private(set) var lastToggleFavoriteSeriesId: String?
    private(set) var lastToggleFavoriteIsFavorited: Bool?

    func fetchSeriesDetail(id: String) async throws -> Series {
        fetchSeriesDetailCallCount += 1
        return try seriesDetailResult.get()
    }

    func fetchChapters(seriesId: String) async throws -> [Chapter] {
        try chaptersResult.get()
    }

    func fetchRelatedSeries(seriesId: String) async throws -> [Series] {
        try relatedSeriesResult.get()
    }

    func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        lastToggleFavoriteSeriesId = seriesId
        lastToggleFavoriteIsFavorited = isFavorited
        try toggleFavoriteResult.get()
    }
}
