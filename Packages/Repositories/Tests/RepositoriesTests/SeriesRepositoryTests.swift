//
//  SeriesRepositoryTests.swift
//  Repositories
//
//  Created by Loi Nguyen on 10/8/26.
//

import CoreArchitecture
import CoreModels
import CoreNetworking
import XCTest
@testable import Repositories

// MARK: - Test Helpers / Fixtures

extension Series {
    static func mock(
        id: String = "s1",
        title: String = "Test Series",
        type: SeriesType = .manga,
        coverURL: URL = URL(string: "https://example.com/cover.jpg")!,
        description: String = "Test description",
        status: SeriesStatus = .ongoing,
        updatedAt: Date = Date(timeIntervalSince1970: 0)
    ) -> Series {
        Series(
            id: id,
            title: title,
            type: type,
            coverURL: coverURL,
            description: description,
            status: status,
            updatedAt: updatedAt
        )
    }
}

// MARK: - MockAPIClient

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var stubbedResult: Result<Any, AppError> = .failure(.unknown("Chưa stub kết quả"))
    private(set) var requestedEndpoints: [APIEndpoint] = []

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stubbedResult {
        case .success(let value):
            guard let typed = value as? T else {
                fatalError("MockAPIClient: kiểu stub không khớp kiểu mong đợi (\(T.self))")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }

    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        requestedEndpoints.append(endpoint)
        if case .failure(let error) = stubbedResult {
            throw error
        }
    }
}

// MARK: - SeriesRepositoryTests

final class SeriesRepositoryTests: XCTestCase {

    private var mockClient: MockAPIClient!
    private var sut: SeriesRepository!

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient()
        sut = SeriesRepository(apiClient: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        sut = nil
        super.tearDown()
    }

    func test_fetchSeriesDetail_callsCorrectEndpoint_andReturnsDecodedSeries() async throws {
        // Given
        let fakeSeries = Series.mock(id: "s1", title: "Test Series")
        mockClient.stubbedResult = .success(fakeSeries)

        // When
        let result = try await sut.fetchSeriesDetail(id: "s1")

        // Then
        XCTAssertEqual(result.id, "s1")
        XCTAssertEqual(mockClient.requestedEndpoints.count, 1)
        guard let endpoint = mockClient.requestedEndpoints.first as? SeriesEndpoint else {
            return XCTFail("Endpoint sai kiểu")
        }
        XCTAssertEqual(endpoint.path, "/series/s1")
        XCTAssertEqual(endpoint.method, .get)
    }

    func test_toggleFavorite_true_usesPostMethod() async throws {
        // Given
        mockClient.stubbedResult = .success(())

        // When
        try await sut.toggleFavorite(seriesId: "s1", isFavorited: true)

        // Then
        guard let endpoint = mockClient.requestedEndpoints.first as? SeriesEndpoint else {
            return XCTFail("Endpoint sai kiểu")
        }
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.path, "/series/s1/favorite")
    }

    func test_toggleFavorite_false_usesDeleteMethod() async throws {
        // Given
        mockClient.stubbedResult = .success(())

        // When
        try await sut.toggleFavorite(seriesId: "s1", isFavorited: false)

        // Then
        guard let endpoint = mockClient.requestedEndpoints.first as? SeriesEndpoint else {
            return XCTFail("Endpoint sai kiểu")
        }
        XCTAssertEqual(endpoint.method, .delete)
    }

    func test_fetchSeriesDetail_apiClientThrows_propagatesAppErrorDirectly() async {
        // Given
        mockClient.stubbedResult = .failure(.notFound)

        // When / Then
        do {
            _ = try await sut.fetchSeriesDetail(id: "not-exist")
            XCTFail("Phải throw lỗi")
        } catch let error as AppError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Sai kiểu lỗi: \(error)")
        }
    }
}
