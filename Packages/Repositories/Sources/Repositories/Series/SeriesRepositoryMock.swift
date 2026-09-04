//
//  SeriesRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 3/9/26.
//

// Production-grade mock for Debug/Staging (selected when AppConfig.isDebugEnvironment == true)
// — similar in role to HomeRepositoryMock/SearchRepositoryMock, unrelated to MockSeriesRepository
// (a test-only file in the Tests directory using @testable import, intended solely for Unit Testing).
//
// Implemented as an actor (not a final class) because this is the project's first mock requiring state mutation
// (toggling Favorites/Notifications/Yuri list requires persisting the new value after interaction) — the actor ensures
// thread safety during concurrent access by multiple Tasks, adhering to concurrency best practices.

import CoreModels
import CoreArchitecture
import Foundation

public actor SeriesRepositoryMock: SeriesRepositoryProtocol {

    private var series: Series
    private let chapters: [Chapter]
    private var pagesByChapterId: [String: [ChapterPage]] = [:]

    public init() {
        let group = TranslationGroup(id: "group-1", name: "Yune Projekt", followerCount: 3_200)
        let author = AuthorGroupCommon(id: "author-1", name: "Radish")
        let artist = AuthorGroupCommon(id: "artist-1", name: "Radish")

        // Split into an explicit `for` loop (instead of a single `.map` containing multiple nested operations)
        // to avoid the "compiler unable to type-check this expression in reasonable time" error —
        // this is a technical limitation of the type-checker (due to overly complex nested expressions),
        // NOT a logic error, breaking down the expression resolves the issue completely.
        var builtChapters: [Chapter] = []
        for number in (183...190).reversed() {
            let daysAgo: Int = 190 - number
            let releasedAt: Date = Date().addingTimeInterval(-Double(daysAgo) * 86_400)
            let chapter = Chapter(
                id: "chapter-\(number)",
                seriesId: "series-1",
                chapterNumber: Double(number),
                releasedAt: releasedAt,
                viewCount: 1_200,
                isRead: number < 190,
                pageCount: 50
            )
            builtChapters.append(chapter)
        }
        self.chapters = builtChapters

        self.series = Series(
            id: "series-1",
            title: "Đồ Ăn Của Ta Trông Thật Đáng Yêu",
            originalTitle: "My Food Seems to Be Very Cute; 我的食物看起来很可爱",
            type: .manga,
            coverURL: URL(string: "https://picsum.photos/seed/series-1-cover/600/900")!,
            description: "Suốt gần hai thế kỷ, nàng ma cà rồng Maria đã chìm sâu trong giấc ngủ bên trong cỗ quan tài của mình — cho đến khi một cô gái nhân lang bất ngờ đánh thức nàng dậy.",
            status: .ongoing,
            author: author,
            group: group,
            genres: [
                Genre(id: "g1", name: "Age Gap"), Genre(id: "g2", name: "Animal Ears"),
                Genre(id: "g3", name: "Fantasy"), Genre(id: "g4", name: "Full Color"),
                Genre(id: "g5", name: "Manhua"), Genre(id: "g6", name: "Monster Girl"),
                Genre(id: "g7", name: "Romance"), Genre(id: "g8", name: "Vampire"),
                Genre(id: "g9", name: "Witch"), Genre(id: "g10", name: "Yuri")
            ],
            viewCount: 1_547_895,
            favoriteCount: 1_159,
            updatedAt: Date(),
            chapters: builtChapters,
            latestChapterLabel: "Chương 190",
            isFavoritedByMe: true,
            isNotifyEnabled: true,
            readingStatus: .planToRead,
            artist: artist
        )

        for chapter in builtChapters {
            pagesByChapterId[chapter.id] = (1...chapter.pageCount).map { pageNumber in
                ChapterPage(
                    id: "\(chapter.id)-page-\(pageNumber)",
                    pageNumber: pageNumber,
                    imageURL: URL(string: "https://picsum.photos/seed/\(chapter.id)-\(pageNumber)/800/1200")!
                )
            }
        }
    }

    public func fetchSeriesDetail(id: String) async throws -> Series {
        series
    }

    public func fetchChapters(seriesId: String) async throws -> [Chapter] {
        chapters
    }

    public func fetchRelatedSeries(seriesId: String) async throws -> [Series] {
        [] // TODO (write "You might also like"): add a few more sample series when reaching the appropriate step.
    }

    public func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        series.isFavoritedByMe = isFavorited
        series.favoriteCount += isFavorited ? 1 : -1
    }

    public func fetchChapterPages(chapterId: String) async throws -> [ChapterPage] {
        pagesByChapterId[chapterId] ?? []
    }

    public func recordReadingProgress(seriesId: String, chapterId: String, page: Int) async throws {
        // No-op in the mock — the real backend will save to READING_HISTORY.
    }

    public func updateReadingStatus(seriesId: String, status: ReadingStatus, notifyNewChapter: Bool) async throws {
        series.readingStatus = status
        series.isNotifyEnabled = notifyNewChapter
    }

    public func toggleNotify(seriesId: String, enabled: Bool) async throws {
        series.isNotifyEnabled = enabled
    }

    public func submitReport(_ request: ReportRequest) async throws {
        // No-op — always "succeeds" so the UI displays the "report sent successfully" notification.
    }

    public func removeReadingStatus(seriesId: String) async throws {
        series.readingStatus = nil
    }
}
