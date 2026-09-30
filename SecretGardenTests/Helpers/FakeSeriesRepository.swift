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

    enum Mutation: Hashable { case favorite, notify, readingStatus, removeStatus }

    struct Behavior {
        var delay: TimeInterval = 0
        var failure: Error?
    }

    private let detail: Result<Series, Error>
    private let chapters: Result<[Chapter], Error>
    private let related: Result<[Series], Error>
    private let pages: Result<[ChapterPage], Error>
    private let pagesDelay: TimeInterval
    private let mutationFailure: Error?
    private let mutationDelay: TimeInterval
    private let behaviors: [Mutation: Behavior]

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
        pagesDelay: TimeInterval = 0,
        mutationFailure: Error? = nil,
        mutationDelay: TimeInterval = 0,
        behaviors: [Mutation: Behavior] = [:]
    ) {
        self.detail = detail
        self.chapters = chapters
        self.related = related
        self.pages = pages
        self.pagesDelay = pagesDelay
        self.mutationFailure = mutationFailure
        self.mutationDelay = mutationDelay
        self.behaviors = behaviors
    }

    // MARK: - Reads

    func fetchSeriesDetail(id: String) async throws -> Series { try detail.get() }
    func fetchChapters(seriesId: String) async throws -> [Chapter] { try chapters.get() }
    func fetchRelatedSeries(seriesId: String) async throws -> [Series] { try related.get() }
    func fetchChapterPages(chapterId: String) async throws -> [ChapterPage] {
        if pagesDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(pagesDelay * 1_000_000_000))
        }
        return try pages.get()
    }

    // MARK: - Mutations

    func toggleFavorite(seriesId: String, isFavorited: Bool) async throws {
        favoriteCalls.append(FavoriteCall(seriesId: seriesId, isFavorited: isFavorited))
        try await performMutation(.favorite)
    }

    func toggleNotify(seriesId: String, enabled: Bool) async throws {
        notifyCalls.append(NotifyCall(seriesId: seriesId, enabled: enabled))
        try await performMutation(.notify)
    }

    func updateReadingStatus(seriesId: String, status: ReadingStatus, notifyNewChapter: Bool) async throws {
        readingStatusCalls.append(
            ReadingStatusCall(seriesId: seriesId, status: status, notifyNewChapter: notifyNewChapter)
        )
        try await performMutation(.readingStatus)
    }

    func removeReadingStatus(seriesId: String) async throws {
        removeStatusCalls.append(seriesId)
        try await performMutation(.removeStatus)
    }

    func recordReadingProgress(seriesId: String, chapterId: String, page: Int) async throws {
        progressCalls.append(ProgressCall(seriesId: seriesId, chapterId: chapterId, page: page))
    }

    func submitReport(_ request: ReportRequest) async throws {}

    // MARK: - Private

    /// Record the call *before* waiting, so that "in-flight" calls are also counted in the test.
    private func performMutation(_ mutation: Mutation) async throws {
        // Use the specific configuration for an action if available, otherwise, use the general default.
        let behavior = behaviors[mutation] ?? Behavior(delay: mutationDelay, failure: mutationFailure)
        if behavior.delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(behavior.delay * 1_000_000_000))
        }
        if let failure = behavior.failure { throw failure }
    }
}

/// Mock repository implementation
actor FakeCommentRepository: CommentRepositoryProtocol {

    struct LikeCall: Equatable { let commentId: String; let isLiked: Bool }
    struct ReplyCall: Equatable { let parentCommentId: String; let content: String }

    private let seriesComments: Result<[Comment], Error>
    private let chapterComments: Result<[Comment], Error>
    private let postResult: Result<Comment, Error>
    private let likeFailure: Error?
    private let replyResult: Result<Comment, Error>

    private(set) var postSeriesCalls: [String] = []
    private(set) var postChapterCalls: [String] = []
    private(set) var likeCalls: [LikeCall] = []
    private(set) var replyCalls: [ReplyCall] = []

    init(
        seriesComments: Result<[Comment], Error> = .success([]),
        chapterComments: Result<[Comment], Error> = .success([]),
        postResult: Result<Comment, Error> = .success(TestFixtures.comment()),
        likeFailure: Error? = nil,
        replyResult: Result<Comment, Error> = .success(TestFixtures.comment(id: "reply1", content: "Trả lời"))
    ) {
        self.seriesComments = seriesComments
        self.chapterComments = chapterComments
        self.postResult = postResult
        self.likeFailure = likeFailure
        self.replyResult = replyResult
    }

    func fetchSeriesComments(seriesId: String, page: Int) async throws -> [Comment] { try seriesComments.get() }
    func fetchChapterComments(chapterId: String, page: Int) async throws -> [Comment] { try chapterComments.get() }

    func postSeriesComment(seriesId: String, content: String) async throws -> Comment {
        postSeriesCalls.append(content)
        return try postResult.get()
    }

    func postChapterComment(chapterId: String, content: String) async throws -> Comment {
        postChapterCalls.append(content)
        return try postResult.get()
    }

    func toggleLike(commentId: String, isLiked: Bool) async throws {
        likeCalls.append(LikeCall(commentId: commentId, isLiked: isLiked))
        if let likeFailure { throw likeFailure }
    }

    func postReply(parentCommentId: String, content: String) async throws -> Comment {
        replyCalls.append(ReplyCall(parentCommentId: parentCommentId, content: content))
        return try replyResult.get()
    }
}
