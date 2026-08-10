//
//  ModelCodableTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Verify the encoding/decoding of the most complex models (featuring nested structs, optional fields, and recursion)
// to ensure a correct round-trip—catching errors early if someone modifies a property later without updating it accordingly.

import XCTest
@testable import CoreModels

final class ModelCodableTests: XCTestCase {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func test_user_encodeDecode_roundTrip() throws {
        // Given
        let user = User(
            id: "u1",
            username: "chara",
            email: "chara@example.com",
            joinedAt: Date(timeIntervalSince1970: 0),
            role: .translator
        )

        // When
        let data = try encoder.encode(user)
        let decoded = try decoder.decode(User.self, from: data)

        // Then
        XCTAssertEqual(user, decoded)
    }

    func test_series_withNestedAuthorAndGenres_roundTrip() throws {
        // Given
        let author = AuthorGroupCommon(id: "a1", name: "Takemoto")
        let genre = Genre(id: "g1", name: "Slice of life")
        let series = Series(
            id: "s1",
            title: "Yuri no Hana",
            type: .manga,
            coverURL: URL(string: "https://example.com/cover.jpg")!,
            description: "Mô tả truyện",
            status: .ongoing,
            author: author,
            genres: [genre],
            updatedAt: Date(timeIntervalSince1970: 0)
        )

        // When
        let data = try encoder.encode(series)
        let decoded = try decoder.decode(Series.self, from: data)

        // Then
        XCTAssertEqual(series, decoded)
    }

    func test_comment_withNestedReplies_roundTrip() throws {
        // Given — Verify that self-referencing structs encode and decode correctly
        let replyAuthor = User(id: "u2", username: "reply_user", email: "r@example.com", joinedAt: Date(timeIntervalSince1970: 0))
        let reply = Comment(id: "c2", user: replyAuthor, content: "Reply nè", createdAt: Date(timeIntervalSince1970: 0))
        let rootAuthor = User(id: "u1", username: "root_user", email: "u@example.com", joinedAt: Date(timeIntervalSince1970: 0))
        let rootComment = Comment(
            id: "c1",
            user: rootAuthor,
            content: "Bình luận gốc",
            createdAt: Date(timeIntervalSince1970: 0),
            replies: [reply]
        )

        // When
        let data = try encoder.encode(rootComment)
        let decoded = try decoder.decode(Comment.self, from: data)

        // Then
        XCTAssertEqual(rootComment, decoded)
        XCTAssertEqual(decoded.replies?.first?.content, "Reply nè")
    }

    func test_readingStatus_allCases_encodeDecodeCorrectly() throws {
        // Given / When / Then — verify enum CaseIterable, all cases result in a correct round-trip
        for status in ReadingStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(ReadingStatus.self, from: data)
            XCTAssertEqual(status, decoded)
        }
    }

    func test_advancedFilterRequest_defaultValues() {
        // Given
        let filter = AdvancedFilterRequest()

        // Then
        XCTAssertTrue(filter.includeTags.isEmpty)
        XCTAssertEqual(filter.sort, "latest_update")
    }
}
