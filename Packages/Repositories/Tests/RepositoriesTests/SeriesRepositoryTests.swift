//
//  SeriesRepositoryTests.swift
//  Repositories
//
//  Created by Loi Nguyen on 10/8/26.
//

// Test for BOTH: (1) MockSeriesRepository behaves exactly as "programmed"
// (2) Real SeriesRepository (stub) throws the correct AppError as expected.

import XCTest
import CoreArchitecture
import CoreModels
@testable import Repositories

final class SeriesRepositoryTests: XCTestCase {

    // MARK: - MockSeriesRepository

    func test_mock_fetchSeriesDetail_returnsConfiguredResult() async throws {
        // Given
        let mock = MockSeriesRepository()
        let expectedSeries = Series(
            id: "s1",
            title: "Test Series",
            type: .manga,
            coverURL: URL(string: "https://example.com/cover.jpg")!,
            description: "desc",
            status: .ongoing,
            updatedAt: Date(timeIntervalSince1970: 0)
        )
        mock.seriesDetailResult = .success(expectedSeries)

        // When
        let result = try await mock.fetchSeriesDetail(id: "s1")

        // Then
        XCTAssertEqual(result, expectedSeries)
        XCTAssertEqual(mock.fetchSeriesDetailCallCount, 1)
    }

    func test_mock_fetchSeriesDetail_throwsConfiguredError() async {
        // Given
        let mock = MockSeriesRepository()
        mock.seriesDetailResult = .failure(.notFound)

        // When / Then
        do {
            _ = try await mock.fetchSeriesDetail(id: "not-exist")
            XCTFail("Phải throw lỗi, không được thành công")
        } catch let error as AppError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Sai kiểu lỗi, phải là AppError")
        }
    }

    func test_mock_toggleFavorite_recordsCorrectParameters() async throws {
        // Given
        let mock = MockSeriesRepository()

        // When
        try await mock.toggleFavorite(seriesId: "s1", isFavorited: true)

        // Then
        XCTAssertEqual(mock.lastToggleFavoriteSeriesId, "s1")
        XCTAssertEqual(mock.lastToggleFavoriteIsFavorited, true)
    }

    // MARK: - SeriesRepository (real stub)

    func test_realRepository_fetchSeriesDetail_throwsNotImplementedError() async {
        // Given
        let repository = SeriesRepository()

        // When / Then — Verify that the stub throws the correct AppError, does not crash, does not return fake data.
        do {
            _ = try await repository.fetchSeriesDetail(id: "s1")
            XCTFail("Repository thật chưa implement, phải throw lỗi")
        } catch is AppError {
            // pass — Just as my expected hêhheh
        } catch {
            XCTFail("Sai kiểu lỗi, phải là AppError")
        }
    }
}
