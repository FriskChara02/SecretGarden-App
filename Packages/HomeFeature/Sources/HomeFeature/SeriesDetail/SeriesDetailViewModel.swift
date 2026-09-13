//
//  SeriesDetailViewModel.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 4/9/26.
//

// ViewModel for the Series Detail screen — loads 4 data sources in parallel with specific UX for errors.
// Hierarchy: detail + chapters are CRITICAL (error -> full-screen error); related + comments are
// SECONDARY (error -> error indicator within that section only, without blocking the rest).
//
// 4 actions (favorite/notify/reading-status) use optimistic updates: UI updates immediately,
// with a rollback if the API fails — they do NOT use the inherited `runTask` (runTask is
// reserved for the main loading flow; sharing it would inadvertently cancel the page-load
// Task if the user clicked a button while loading was in progress).

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class SeriesDetailViewModel: BaseViewModel {

    private let seriesId: String
    private let seriesRepository: SeriesRepositoryProtocol
    private let commentRepository: CommentRepositoryProtocol

    // MARK: - Critical state (details + chapters — load together, fail together)

    @Published public private(set) var detailState: LoadableState<Series> = .idle
    @Published public private(set) var chaptersState: LoadableState<[Chapter]> = .idle

    // MARK: - Secondary state (independent of each other and the section above)

    @Published public private(set) var relatedState: LoadableState<[Series]> = .idle
    @Published public private(set) var commentsState: LoadableState<[Comment]> = .idle

    // MARK: - Chapter list UI state (client-side, no network call required)

    @Published public var chaptersSortDescending: Bool = true
    @Published public private(set) var visibleChapterCount: Int = 5

    // MARK: - Comment
    
    @Published public var commentDraft: String = ""
    @Published public private(set) var isPostingComment = false
    @Published public private(set) var replyingToCommentId: String?
    @Published public var replyDraft: String = ""
    @Published public private(set) var isPostingReply = false

    /// List of chapters sorted and sliced ​​according to `visibleChapterCount` - The view simply renders the list directly without performing its own sorting.
    public var visibleSortedChapters: [Chapter] {
        guard let chapters = chaptersState.value else { return [] }
        let sorted = chaptersSortDescending
            ? chapters.sorted { $0.chapterNumber > $1.chapterNumber }
            : chapters.sorted { $0.chapterNumber < $1.chapterNumber }
        return Array(sorted.prefix(visibleChapterCount))
    }

    public var hasMoreChapters: Bool {
        (chaptersState.value?.count ?? 0) > visibleChapterCount
    }

    // MARK: - Action state (Favorite / Notify / Reading Status)

    @Published public private(set) var isTogglingFavorite = false
    @Published public private(set) var isTogglingNotify = false
    @Published public private(set) var isUpdatingReadingStatus = false
    /// Brief error notification (toast style) when an optimistic action is rolled back – the view decides how to display it.
    @Published public var actionErrorMessage: String?

    private var relatedTask: Task<Void, Never>?
    private var commentsTask: Task<Void, Never>?

    public init(
        seriesId: String,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol
    ) {
        self.seriesId = seriesId
        self.seriesRepository = seriesRepository
        self.commentRepository = commentRepository
        super.init()
    }

    // MARK: - Lifecycle

    public func onAppear() {
        loadDetailAndChapters()
        loadRelated()
        loadComments()
    }

    // MARK: - Critical load (async let — both must complete to be considered loaded)

    public func loadDetailAndChapters() {
        detailState = .loading
        chaptersState = .loading
        runTask({ [weak self] in
            guard let self else { return }
            async let detail = self.seriesRepository.fetchSeriesDetail(id: self.seriesId)
            async let chapters = self.seriesRepository.fetchChapters(seriesId: self.seriesId)
            let (loadedDetail, loadedChapters) = try await (detail, chapters)
            self.detailState = .loaded(loadedDetail)
            self.chaptersState = .loaded(loadedChapters)
        }, onError: { [weak self] error in
            self?.detailState = .failed(error)
            self?.chaptersState = .failed(error)
        })
    }

    // MARK: - Secondary load (independent — do NOT use runTask to avoid mutual cancellation)

    public func loadRelated() {
        relatedTask?.cancel()
        relatedState = .loading
        relatedTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.seriesRepository.fetchRelatedSeries(seriesId: self.seriesId)
                guard !Task.isCancelled else { return }
                self.relatedState = .loaded(items)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.relatedState = .failed(self.mapToAppError(error))
            }
        }
    }

    public func loadComments() {
        commentsTask?.cancel()
        commentsState = .loading
        commentsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.commentRepository.fetchSeriesComments(seriesId: self.seriesId, page: 1)
                guard !Task.isCancelled else { return }
                self.commentsState = .loaded(items)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.commentsState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Chapter list UI actions (client-side, no network calls)

    public func toggleChaptersSortOrder() {
        chaptersSortDescending.toggle()
    }

    /// Explicit setter (distinct from `toggleChaptersSortOrder`) - for use with separate icons
    /// for ascending/descending order as shown in the mockup, avoiding the need to click a second time if the wrong icon is pressed.
    public func setChaptersSortDescending(_ descending: Bool) {
        chaptersSortDescending = descending
    }

    public func showMoreChapters() {
        visibleChapterCount += 5
    }

    // MARK: - Favorite (optimistic)

    public func toggleFavorite() {
        guard let current = detailState.value, !isTogglingFavorite else { return }
        let previous = current
        var updated = current
        updated.isFavoritedByMe.toggle()
        updated.favoriteCount += updated.isFavoritedByMe ? 1 : -1
        detailState = .loaded(updated)
        isTogglingFavorite = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingFavorite = false } }
            do {
                try await self.seriesRepository.toggleFavorite(seriesId: previous.id, isFavorited: updated.isFavoritedByMe)
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    // MARK: - Notify toggle (optimistic)

    public func toggleNotify() {
        guard let current = detailState.value, !isTogglingNotify else { return }
        let previous = current
        var updated = current
        updated.isNotifyEnabled.toggle()
        detailState = .loaded(updated)
        isTogglingNotify = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingNotify = false } }
            do {
                try await self.seriesRepository.toggleNotify(seriesId: previous.id, enabled: updated.isNotifyEnabled)
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    // MARK: - Reading Status ("Yuri list" dropdown, optimistic)

    public func updateReadingStatus(to newStatus: ReadingStatus) {
        guard let current = detailState.value, !isUpdatingReadingStatus else { return }
        let previous = current
        var updated = current
        updated.readingStatus = newStatus
        detailState = .loaded(updated)
        isUpdatingReadingStatus = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isUpdatingReadingStatus = false } }
            do {
                try await self.seriesRepository.updateReadingStatus(
                    seriesId: previous.id,
                    status: newStatus,
                    notifyNewChapter: updated.isNotifyEnabled
                )
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    /// "Remove from list" — a separate option in red at the bottom of the Yuri list dropdown.
    public func removeFromReadingList() {
        guard let current = detailState.value, !isUpdatingReadingStatus else { return }
        let previous = current
        var updated = current
        updated.readingStatus = nil
        detailState = .loaded(updated)
        isUpdatingReadingStatus = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isUpdatingReadingStatus = false } }
            do {
                try await self.seriesRepository.removeReadingStatus(seriesId: previous.id)
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func postComment() {
        let trimmed = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isPostingComment else { return }
        isPostingComment = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isPostingComment = false } }
            do {
                let newComment = try await self.commentRepository.postSeriesComment(
                    seriesId: self.seriesId, content: trimmed
                )
                if var current = self.commentsState.value {
                    current.insert(newComment, at: 0)
                    self.commentsState = .loaded(current)
                } else {
                    self.commentsState = .loaded([newComment])
                }
                self.commentDraft = ""
            } catch {
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func toggleCommentLike(commentId: String) {
        guard var comments = commentsState.value,
              let index = findCommentIndex(commentId: commentId, in: comments) else { return }

        let willLike: Bool
        switch index {
        case .topLevel(let i):
            willLike = !comments[i].isLikedByMe
            comments[i].isLikedByMe = willLike
            comments[i].likeCount += willLike ? 1 : -1
        case .reply(let parentIndex, let replyIndex):
            willLike = !(comments[parentIndex].replies?[replyIndex].isLikedByMe ?? false)
            comments[parentIndex].replies?[replyIndex].isLikedByMe = willLike
            comments[parentIndex].replies?[replyIndex].likeCount += willLike ? 1 : -1
        }
        let previous = commentsState.value
        commentsState = .loaded(comments)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.commentRepository.toggleLike(commentId: commentId, isLiked: willLike)
            } catch {
                if let previous {
                    self.commentsState = .loaded(previous)
                }
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func startReplying(to commentId: String) {
        replyingToCommentId = commentId
        replyDraft = ""
    }

    public func cancelReplying() {
        replyingToCommentId = nil
        replyDraft = ""
    }

    public func submitReply() {
        guard let parentId = replyingToCommentId else { return }
        let trimmed = replyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isPostingReply else { return }
        isPostingReply = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isPostingReply = false } }
            do {
                let newReply = try await self.commentRepository.postReply(
                    parentCommentId: parentId, content: trimmed
                )
                if var comments = self.commentsState.value,
                   let parentIndex = comments.firstIndex(where: { $0.id == parentId }) {
                    var replies = comments[parentIndex].replies ?? []
                    replies.append(newReply)
                    comments[parentIndex].replies = replies
                    self.commentsState = .loaded(comments)
                }
                self.cancelReplying()
            } catch {
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    // MARK: - Private helper: Find the comment location (top-level or reply) - only supports a single level of replies.

    private enum CommentLocation {
        case topLevel(Int)
        case reply(parentIndex: Int, replyIndex: Int)
    }

    private func findCommentIndex(commentId: String, in comments: [Comment]) -> CommentLocation? {
        if let topIndex = comments.firstIndex(where: { $0.id == commentId }) {
            return .topLevel(topIndex)
        }
        for (parentIndex, comment) in comments.enumerated() {
            if let replyIndex = comment.replies?.firstIndex(where: { $0.id == commentId }) {
                return .reply(parentIndex: parentIndex, replyIndex: replyIndex)
            }
        }
        return nil
    }

    // MARK: - Dismiss action error toast

    public func dismissActionError() {
        actionErrorMessage = nil
    }

    deinit {
        relatedTask?.cancel()
        commentsTask?.cancel()
    }
}
