//
//  HomeRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 21/8/26.
//

// Mock implementation of HomeRepositoryProtocol for Debug/Preview builds,
// used to avoid "-1003 DNS" errors when the actual backend is not yet available.
// Returns data using the ACTUAL domain structs (Series, Comment, User, ...)
// rather than custom mock structs—preventing data contract mismatches with the real HomeRepository.

import CoreModels
import Foundation

public final class HomeRepositoryMock: HomeRepositoryProtocol {

    public init() {}

    // MARK: - Fixed sample data (shared by all methods below)

    // swiftlint:disable force_unwrapping
    // Reason for disabling: the URLs below are hardcoded literals for mock data,
    // not dynamic inputs from the network or user — there is no actual risk of a runtime crash.
    private static let sampleCoverURL1 = URL(string: "https://picsum.photos/seed/series1/400/560")!
    private static let sampleCoverURL2 = URL(string: "https://picsum.photos/seed/series2/400/560")!
    private static let sampleCoverURL3 = URL(string: "https://picsum.photos/seed/series3/400/560")!
    private static let sampleAvatarURL = URL(string: "https://picsum.photos/seed/user1/100/100")!
    // swiftlint:enable force_unwrapping

    private static let sampleUser = User(
        id: "user_mock_01",
        username: "yuri_fan_92",
        email: "yurifan92@example.com",
        avatarURL: sampleAvatarURL,
        joinedAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 200)
    )

    private static func makeSeries(index: Int, coverURL: URL, title: String) -> Series {
        Series(
            id: "series_mock_\(index)",
            title: title,
            type: .manga,
            coverURL: coverURL,
            description: "Mô tả giả lập cho truyện số \(index), dùng để dựng UI Home trước khi có backend thật.",
            status: index.isMultiple(of: 2) ? .ongoing : .completed,
            genres: [Genre(id: "genre_yuri", name: "Yuri"), Genre(id: "genre_slice_of_life", name: "Slice of Life")],
            viewCount: 1200 * index,
            favoriteCount: 340 * index,
            updatedAt: Date(timeIntervalSinceNow: -Double(index) * 3600)
        )
    }

    private static func makeChapter(index: Int, seriesId: String) -> Chapter {
        Chapter(
            id: "chapter_mock_\(seriesId)_\(index)",
            seriesId: seriesId,
            chapterNumber: Double(index),
            title: "Chương \(index)",
            releasedAt: Date(timeIntervalSinceNow: -Double(index) * 86_400),
            viewCount: 500 * index
        )
    }

    // MARK: - HomeRepositoryProtocol

    public func fetchContinueReading() async throws -> [ContinueReadingItem] {
        try await simulateNetworkDelay()

        let series1 = Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em")
        let chapter1 = Self.makeChapter(index: 12, seriesId: series1.id)

        let series2 = Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ")
        let chapter2 = Self.makeChapter(index: 5, seriesId: series2.id)

        return [
            ContinueReadingItem(
                id: "continue_mock_1",
                series: series1,
                chapter: chapter1,
                lastPageRead: 14,
                totalPages: 22
            ),
            ContinueReadingItem(
                id: "continue_mock_2",
                series: series2,
                chapter: chapter2,
                lastPageRead: 3,
                totalPages: 18
            )
        ]
    }

    public func fetchLatestUpdates(page: Int) async throws -> [Series] {
        try await simulateNetworkDelay()

        guard page == 1 else { return [] } // Mock containing only a single page of dummy data

        return [
            Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em"),
            Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ"),
            Self.makeSeries(index: 3, coverURL: Self.sampleCoverURL3, title: "Lời Hứa Dưới Giàn Hoa Tím")
        ]
    }

    public func fetchRanking(range: RankingRange, page: Int) async throws -> [Series] {
        try await simulateNetworkDelay()

        guard page == 1 else { return [] }

        // Slightly reorder items based on the range so the UI changes are clearly visible when applying the filter.
        let base = [
            Self.makeSeries(index: 3, coverURL: Self.sampleCoverURL3, title: "Lời Hứa Dưới Giàn Hoa Tím"),
            Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em"),
            Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ")
        ]
        return range == .all ? base.reversed() : base
    }

    public func fetchRandomComments() async throws -> [Comment] {
        try await simulateNetworkDelay()

        return [
            Comment(
                id: "comment_mock_1",
                user: Self.sampleUser,
                content: "Chương này cảm động quá, đọc mà rưng rưng luôn 🥹",
                likeCount: 24,
                createdAt: Date(timeIntervalSinceNow: -1800)
            ),
            Comment(
                id: "comment_mock_2",
                user: Self.sampleUser,
                content: "Nhóm dịch làm việc chăm chỉ ghê, cảm ơn nhóm nhiều!",
                likeCount: 9,
                createdAt: Date(timeIntervalSinceNow: -7200)
            )
        ]
    }

    // MARK: - Helper

    /// Simulate a slight network delay (300ms) to give `LoadableState` a chance
    /// to display the `.loading` state before switching to `.loaded` - avoiding
    /// the scenario where the Preview/Debug UI "jumps straight" to the data,
    /// preventing you from verifying whether the loading UI looks right.
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
