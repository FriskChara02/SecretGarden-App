//
//  SearchHistoryLocalStoreTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreModels
import CoreStorage
import XCTest

final class SearchHistoryLocalStoreTests: XCTestCase {

    private func makeSUT(maxItems: Int = 25) throws -> SearchHistoryLocalStore {
        try SearchHistoryLocalStore.makeInMemoryForTesting(maxItems: maxItems)
    }

    // MARK: - Add & fetch

    func test_fetchAll_whenEmpty_returnsEmptyArray() async throws {
        let sut = try makeSUT()

        let items = try await sut.fetchAll()

        XCTAssertTrue(items.isEmpty)
    }

    func test_add_thenFetchAll_returnsTheAddedQuery() async throws {
        let sut = try makeSUT()

        try await sut.add(query: "yuri manga")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.query, "yuri manga")
    }

    func test_add_trimsWhitespaceBeforeSaving() async throws {
        let sut = try makeSUT()

        try await sut.add(query: "  yuri manga  ")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.first?.query, "yuri manga")
    }

    func test_add_blankOrWhitespaceOnly_doesNotSave() async throws {
        let sut = try makeSUT()

        try await sut.add(query: "")
        try await sut.add(query: "   ")

        let items = try await sut.fetchAll()
        XCTAssertTrue(items.isEmpty)
    }

    func test_fetchAll_ordersNewestFirst() async throws {
        let sut = try makeSUT()

        try await sut.add(query: "first")
        try await Task.sleep(nanoseconds: 10_000_000) // ensure distinct timestamps
        try await sut.add(query: "second")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.map(\.query), ["second", "first"])
    }

    // MARK: - Duplicate query

    func test_add_sameQueryTwice_updatesTimestampInsteadOfDuplicating() async throws {
        let sut = try makeSUT()
        try await sut.add(query: "yuri manga")
        let firstTimestamp = try await sut.fetchAll().first?.searchedAt

        try await Task.sleep(nanoseconds: 1_100_000_000) // > 1s for a clear Date comparison, avoiding flaky due to rounding.
        try await sut.add(query: "yuri manga")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.count, 1, "Query trùng không được tạo bản ghi thứ 2")
        let secondTimestamp = try XCTUnwrap(items.first?.searchedAt)
        let first = try XCTUnwrap(firstTimestamp)
        XCTAssertGreaterThan(secondTimestamp, first, "Timestamp phải được cập nhật thành mới hơn")
    }

    func test_add_sameQueryAfterTrimming_isTreatedAsDuplicate() async throws {
        let sut = try makeSUT()
        try await sut.add(query: "yuri manga")

        try await sut.add(query: "  yuri manga  ")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.count, 1)
    }

    // MARK: - Remove

    func test_remove_deletesOnlyMatchingItem() async throws {
        let sut = try makeSUT()
        try await sut.add(query: "keep-me")
        try await sut.add(query: "delete-me")
        let items = try await sut.fetchAll()
        let idToDelete = try XCTUnwrap(items.first { $0.query == "delete-me" }?.id)

        try await sut.remove(id: idToDelete)

        let remaining = try await sut.fetchAll()
        XCTAssertEqual(remaining.map(\.query), ["keep-me"])
    }

    func test_remove_nonExistentId_doesNotThrow() async throws {
        let sut = try makeSUT()
        try await sut.add(query: "keep-me")

        try await sut.remove(id: "does-not-exist")

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.count, 1)
    }

    // MARK: - Clear all

    func test_clearAll_removesEveryItem() async throws {
        let sut = try makeSUT()
        try await sut.add(query: "a")
        try await sut.add(query: "b")
        try await sut.add(query: "c")

        try await sut.clearAll()

        let items = try await sut.fetchAll()
        XCTAssertTrue(items.isEmpty)
    }

    func test_clearAll_whenAlreadyEmpty_doesNotThrow() async throws {
        let sut = try makeSUT()

        try await sut.clearAll()

        let items = try await sut.fetchAll()
        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - maxItems trimming

    func test_add_beyondMaxItems_dropsOldestAndKeepsNewest() async throws {
        let sut = try makeSUT(maxItems: 3)

        for index in 1...5 {
            try await sut.add(query: "query-\(index)")
            try await Task.sleep(nanoseconds: 10_000_000) // Timestamps clearly separated by order of addition
        }

        let items = try await sut.fetchAll()
        XCTAssertEqual(items.count, 3, "Không được vượt quá maxItems")
        XCTAssertEqual(items.map(\.query), ["query-5", "query-4", "query-3"], "Phải giữ 3 mục MỚI nhất")
    }

    func test_fetchAll_alsoRespectsFetchLimitEvenWithoutAdding() async throws {
        let sut = try makeSUT(maxItems: 2)
        try await sut.add(query: "a")
        try await sut.add(query: "b")

        let items = try await sut.fetchAll()

        XCTAssertEqual(items.count, 2)
    }
}
