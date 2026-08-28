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

    private static let authors: [AuthorGroupCommon] = [
        AuthorGroupCommon(id: "author_1", name: "Chise, Ciweimao"),
        AuthorGroupCommon(id: "author_2", name: "Kanno Fumi"),
        AuthorGroupCommon(id: "author_3", name: "Radish")
    ]

    private static let groups: [TranslationGroup] = [
        TranslationGroup(id: "group_1", name: "Knights of Yuri"),
        TranslationGroup(id: "group_2", name: "Knights of Yuri"),
        TranslationGroup(id: "group_3", name: "Yune Projekt")
    ]

    private static func makeSeries(index: Int, coverURL: URL, title: String) -> Series {
        Series(
            id: "series_mock_\(index)",
            title: title,
            type: .manga,
            coverURL: coverURL,
            description: "Mô tả giả lập cho truyện số \(index), dùng để dựng UI Home trước khi có backend thật.",
            status: index.isMultiple(of: 2) ? .ongoing : .completed,
            author: authors[(index - 1) % authors.count],
            group: groups[(index - 1) % groups.count],
            genres: [
                Genre(id: "genre_1", name: "Yuri"),
                Genre(id: "genre_2", name: "Slice of Life"),
                Genre(id: "genre_3", name: "Comedy"),
                Genre(id: "genre_4", name: "School Life"),
                Genre(id: "genre_5", name: "Drama"),
                Genre(id: "genre_6", name: "Fantasy")
            ],
            viewCount: 1200 * index,
            favoriteCount: 340 * index,
            updatedAt: Date(timeIntervalSinceNow: -Double(index) * 3600),
            latestChapterLabel: "Chương \(index * 42): Vì Cậu Mà Tớ Làm Tất Cả"
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
            ContinueReadingItem(id: "continue_mock_1", series: series1, chapter: chapter1, lastPageRead: 14, totalPages: 22),
            ContinueReadingItem(id: "continue_mock_2", series: series2, chapter: chapter2, lastPageRead: 3, totalPages: 18)
        ]
    }

    public func fetchLatestUpdates(page: Int) async throws -> [Series] {
        try await simulateNetworkDelay()
        guard page == 1 else { return [] }

        return [
            Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em"),
            Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ"),
            Self.makeSeries(index: 3, coverURL: Self.sampleCoverURL3, title: "Lời Hứa Dưới Giàn Hoa Tím")
        ]
    }

    public func fetchRanking(range: RankingRange, sortBy: RankingSortBy, page: Int) async throws -> [Series] {
        try await simulateNetworkDelay()

        guard page == 1 else { return [] }

        let pool = [
            Self.makeSeries(index: 3, coverURL: Self.sampleCoverURL3, title: "Lời Hứa Dưới Giàn Hoa Tím"),
            Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em"),
            Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ")
        ]
        switch sortBy {
        case .views: return pool.sorted { $0.viewCount > $1.viewCount }
        case .favorites: return pool.sorted { $0.favoriteCount > $1.favoriteCount }
        }
    }

    public func fetchRandomComments() async throws -> [Comment] {
        try await simulateNetworkDelay()

        // Pool of 15 comments — for each fetch (including the auto-loop after 4 pages), randomly select 12
        // (exactly 4 pages × 3 comments)
        let pool: [(content: String, days: Int, seriesIndex: Int)] = [
            ("Ê tui muốn xem tiếp cặp chị em này 🔥", 8, 0),
            ("Đang cảm xúc nhìn quả ảnh cười điên =))", 14, 1),
            ("Như này vẫn chưa đủ, cần uốn nắn thêm nữa :)) 🔥", 13, 2),
            ("Ai biểu bạn tìm mà bạn hăng hái thế 🔥", 9, 0),
            ("Ây t đọc được 101 chương 1 ngày, new PB =)))", 4, 1),
            ("Chị tôi bị familyzone mina ạ :<", 8, 2),
            ("Cặp này ngọt xỉu, đọc xong tim đập loạn nhịp", 2, 0),
            ("Nhóm dịch làm việc chăm chỉ ghê, cảm ơn nhiều!", 6, 1),
            ("Chương này twist quá trời, không đoán được luôn", 11, 2),
            ("Ước gì có mùa 2 sớm sớm", 3, 0),
            ("Đọc lại lần thứ 5 rồi mà vẫn thấy hay", 15, 1),
            ("Bạn nữ chính dễ thương ghê á", 5, 2),
            ("Cốt truyện chậm mà cuốn phết", 7, 0),
            ("Ai cũng nên đọc bộ này ít nhất 1 lần", 10, 1),
            ("Cảm ơn tác giả vì bộ truyện tuyệt vời này", 1, 2)
        ]

        let series = [
            (id: "series_mock_1", title: "Ánh Trăng Bên Em"),
            (id: "series_mock_2", title: "Hoa Anh Đào Mùa Hạ"),
            (id: "series_mock_3", title: "Lời Hứa Dưới Giàn Hoa Tím")
        ]

        let allComments = pool.enumerated().map { index, item -> Comment in
            let s = series[item.seriesIndex]
            return Comment(
                id: "comment_mock_\(index + 1)",
                user: Self.sampleUser,
                content: item.content,
                likeCount: Int.random(in: 3...40),
                createdAt: Date(timeIntervalSinceNow: -Double(item.days) * 86_400),
                seriesId: s.id,
                seriesTitle: s.title
            )
        }

        return Array(allComments.shuffled().prefix(12))
    }

    public func fetchRandomYuri(type: SeriesType) async throws -> [Series] {
        try await simulateNetworkDelay()
        let pool = [
            Self.makeSeries(index: 1, coverURL: Self.sampleCoverURL1, title: "Ánh Trăng Bên Em"),
            Self.makeSeries(index: 2, coverURL: Self.sampleCoverURL2, title: "Hoa Anh Đào Mùa Hạ"),
            Self.makeSeries(index: 3, coverURL: Self.sampleCoverURL3, title: "Lời Hứa Dưới Giàn Hoa Tím")
        ]
        return pool.shuffled()
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
