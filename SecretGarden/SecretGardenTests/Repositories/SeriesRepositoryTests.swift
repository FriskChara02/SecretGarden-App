//
//  SeriesRepositoryTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreModels
import CoreNetworking
import Repositories
import XCTest

final class SeriesRepositoryTests: XCTestCase {

    private func makeSUT(_ client: FakeAPIClient) -> SeriesRepository {
        SeriesRepository(apiClient: client)
    }

    // MARK: - Read endpoints (public, GET)

    func test_fetchChapters_returnsClientValueAndUsesPublicGet() async throws {
        let chapters = [
            Chapter(id: "c1", seriesId: "s1", chapterNumber: 1, releasedAt: Date()),
            Chapter(id: "c2", seriesId: "s1", chapterNumber: 2, releasedAt: Date())
        ]
        let client = FakeAPIClient(response: chapters)

        let result = try await makeSUT(client).fetchChapters(seriesId: "s1")

        XCTAssertEqual(result, chapters)
        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/series/s1/chapters")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertFalse(endpoint.requiresAuth) // Guest mode is read
    }

    func test_fetchChapterPages_returnsClientValueAndTargetsChapterPath() async throws {
        let url = try XCTUnwrap(URL(string: "https://test.example.com/p1.jpg"))
        let pages = [ChapterPage(id: "p1", pageNumber: 1, imageURL: url)]
        let client = FakeAPIClient(response: pages)

        let result = try await makeSUT(client).fetchChapterPages(chapterId: "c1")

        XCTAssertEqual(result, pages)
        let endpoints = await client.endpoints
        XCTAssertEqual(endpoints.first?.path, "/chapters/c1/pages")
    }

    func test_fetchSeriesDetail_whenClientFails_propagatesSameAppErrorAndTargetsDetailPath() async throws {
        let client = FakeAPIClient(failure: AppError.notFound)
        let sut = makeSUT(client)

        await assertThrowsAppError(.notFound) {
            _ = try await sut.fetchSeriesDetail(id: "s1")
        }

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/series/s1")
        XCTAssertEqual(endpoint.method, .get)
    }

    // MARK: - Mutations (require auth)

    func test_toggleFavorite_usesPOSTWhenFavoritingAndDELETEWhenUnfavoriting() async throws {
        let client = FakeAPIClient()
        let sut = makeSUT(client)

        try await sut.toggleFavorite(seriesId: "s1", isFavorited: true)
        try await sut.toggleFavorite(seriesId: "s1", isFavorited: false)

        let endpoints = await client.endpoints
        XCTAssertEqual(endpoints.count, 2)
        XCTAssertEqual(endpoints[0].method, .post)
        XCTAssertEqual(endpoints[1].method, .delete)
        XCTAssertEqual(endpoints[0].path, "/series/s1/favorite")
        XCTAssertEqual(endpoints[1].path, "/series/s1/favorite")
        XCTAssertTrue(endpoints.allSatisfy { $0.requiresAuth })
    }

    func test_toggleNotify_sendsPUTWithEnabledFlag() async throws {
        let client = FakeAPIClient()

        try await makeSUT(client).toggleNotify(seriesId: "s1", enabled: true)

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/series/s1/notify")
        XCTAssertEqual(endpoint.method, .put)
        XCTAssertEqual(try jsonBody(of: endpoint)["enabled"] as? Bool, true)
    }

    func test_updateReadingStatus_sendsPUTWithStatusAndNotifyFlag() async throws {
        let client = FakeAPIClient()

        try await makeSUT(client).updateReadingStatus(seriesId: "s1", status: .reading, notifyNewChapter: true)

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/users/me/reading-status/s1")
        XCTAssertEqual(endpoint.method, .put)
        let json = try jsonBody(of: endpoint)
        XCTAssertEqual(json["status"] as? String, ReadingStatus.reading.rawValue)
        XCTAssertEqual(json["notify_new_chapter"] as? Bool, true)
    }

    func test_removeReadingStatus_sendsDELETEWithoutBody() async throws {
        let client = FakeAPIClient()

        try await makeSUT(client).removeReadingStatus(seriesId: "s1")

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/users/me/reading-status/s1")
        XCTAssertEqual(endpoint.method, .delete)
        XCTAssertNil(endpoint.body)
    }

    func test_recordReadingProgress_sendsPOSTToChapterWithPage() async throws {
        let client = FakeAPIClient()

        try await makeSUT(client).recordReadingProgress(seriesId: "s1", chapterId: "c1", page: 7)

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/chapters/c1/read")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(try jsonBody(of: endpoint)["page"] as? Int, 7)
        XCTAssertTrue(endpoint.requiresAuth)
    }
}
