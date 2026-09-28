//
//  FakeSeriesRepository.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

/// Mock Repository Series: returns predefined data, logs all mutation calls,
/// and can simulate errors and latency for optimistic actions.
actor FakeSeriesRepository: SeriesRepositoryProtocol {

    struct FavoriteCall: Equatable { let seriesId: String; let isFavorited: Bool }
    struct NotifyCall: Equatable { let seriesId: String; let enabled: Bool }
    struct ReadingStatusCall: Equatable {
        let seriesId: String
        let status: ReadingStatus
        let notifyNewChapter: Bool
    }
    struct ProgressCall: Equatable { let seriesId: String; let chapterId: String; let page: Int }

    private let detail: Result<Series, Error>
    private let chapters: Result<[Chapter], Error>
    private let related: Result<[Series], Error>
    private let pages: Result<[ChapterPage], Error>
    private let mutationFailure: Error?
    private let mutationDelay: TimeInterval

    private(set) var favoriteCalls: [FavoriteCall] = []
    private(set) var notifyCalls: [NotifyCall] = []
    private(set) var readingStatusCalls: [ReadingStatusCall] = []
    private(set) var removeStatusCalls: [String] = []
    private(set) var progressCalls: [ProgressCall] = []

    init(
        detail: Result<Series, Error> = .success(TestFixtures.series()),
        chapters: Result<[Chapter], Error> = .success([]),
        related: Result<[Series], Error> = .success([]),
        pages: Result<[ChapterPage], Error> = .success([]),
        mutationFailure: Error? = nil,
        mutationDelay: TimeInterval = 0
    ) {
        self.detail = detail
        self.chapters = chapters
        self.related = related
        self.pages = pages
        self.mutationFailure = mutationFailure
        self.mutationDelay = mutationDelay
    }

    // MARK: - Reads

    func fetchSeriesDetail(id: String) async throws -> Series { try detail.get() }
    func fetchChapters(seriesId: String) async throws -> [Chapter] { try chapters.get() }
    func fetchRelatedSeries(seriesId: String) async throws -> [Series] { try related.get() }
    func fetchChapterPages(chapterId: String) async throws -> [ChapterPage] { try pages.get() }

    // MARK: - Mutations

    func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        favoriteCalls.append(FavoriteCall(seriesId: seriesId, isFavorited: isFavorited))
        try await performMutation()
    }

    func toggleNotify(seriesId: String, enabled: Bool) async throws {
        notifyCalls.append(NotifyCall(seriesId: seriesId, enabled: enabled))
        try await performMutation()
    }

    func updateReadingStatus(seriesId: String, status: ReadingStatus, notifyNewChapter: Bool) async throws {
        readingStatusCalls.append(
            ReadingStatusCall(seriesId: seriesId, status: status, notifyNewChapter: notifyNewChapter)
        )
        try await performMutation()
    }

    func removeReadingStatus(seriesId: String) async throws {
        removeStatusCalls.append(seriesId)
        try await performMutation()
    }

    func recordReadingProgress(seriesId: String, chapterId: String, page: Int) async throws {
        progressCalls.append(ProgressCall(seriesId: seriesId, chapterId: chapterId, page: page))
    }

    func submitReport(_ request: ReportRequest) async throws {}

    // MARK: - Private

    /// Record the call *before* waiting, so that "in-flight" calls are also counted in the test.
    private func performMutation() async throws {
        if mutationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mutationDelay * 1_000_000_000))
        }
        if let mutationFailure { throw mutationFailure }
    }
}

/// Mock repository implementation
actor FakeCommentRepository: CommentRepositoryProtocol {

    private let seriesComments: Result<[Comment], Error>
    private let chapterComments: Result<[Comment], Error>

    init(
        seriesComments: Result<[Comment], Error> = .success([]),
        chapterComments: Result<[Comment], Error> = .success([])
    ) {
        self.seriesComments = seriesComments
        self.chapterComments = chapterComments
    }

    func fetchSeriesComments(seriesId: String, page: Int) async throws -> [Comment] { try seriesComments.get() }
    func fetchChapterComments(chapterId: String, page: Int) async throws -> [Comment] { try chapterComments.get() }

    func postSeriesComment(seriesId: String, content: String) async throws -> Comment {
        throw AppError.unknown("FakeCommentRepository: postSeriesComment chưa được stub")
    }

    func postChapterComment(chapterId: String, content: String) async throws -> Comment {
        throw AppError.unknown("FakeCommentRepository: postChapterComment chưa được stub")
    }

    func toggleLike(commentId: String, isLiked: Bool) async throws {}

    func postReply(parentCommentId: String, content: String) async throws -> Comment {
        throw AppError.unknown("FakeCommentRepository: postReply chưa được stub")
    }
}
