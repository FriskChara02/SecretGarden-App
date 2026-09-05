//
//  ChapterReaderViewModel.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 4/9/26.
//

// ViewModel for the Chapter Reader. Accepts ONLY seriesId and initialChapterId — fetches the full Series data
// (chapters, favorite status, notifications, reading status) itself, rather than receiving them as parameters from SeriesDetailView.

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class ChapterReaderViewModel: BaseViewModel {

    private let seriesId: String
    private let initialChapterId: String
    private let seriesRepository: SeriesRepositoryProtocol
    private let commentRepository: CommentRepositoryProtocol

    /// Critical: The full Series is required before rendering anything (title, chapters, favorites...).
    @Published public private(set) var seriesState: LoadableState<Series> = .idle
    @Published public private(set) var pagesState: LoadableState<[ChapterPage]> = .idle
    @Published public private(set) var commentsState: LoadableState<[Comment]> = .idle
    /// Secondary - "Group's other works" at the end of the chapter. Reuse `fetchRelatedSeries` (no
    /// dedicated endpoint for "series by the same scanlation group" yet - requires GroupRepository).
    @Published public private(set) var groupOtherSeriesState: LoadableState<[Series]> = .idle

    private var sortedChapters: [Chapter] = []
    @Published public private(set) var currentChapter: Chapter = Chapter(
        id: "", seriesId: "", chapterNumber: 0, releasedAt: Date()
    )

    @Published public private(set) var isFavoritedByMe = false
    @Published public private(set) var isNotifyEnabled = false
    @Published public private(set) var readingStatus: ReadingStatus?
    @Published public private(set) var isTogglingFavorite = false
    @Published public private(set) var isTogglingNotify = false
    @Published public private(set) var isUpdatingReadingStatus = false
    @Published public var actionErrorMessage: String?

    // MARK: - Overlay / Menu presentation state (Purely UI-focused, the View will bind directly.)

    @Published public var isMenuPresented = false
    @Published public var isCommentsOverlayPresented = false
    @Published public var isChapterPickerPresented = false

    private var pagesTask: Task<Void, Never>?
    private var commentsTask: Task<Void, Never>?
    private var groupOtherSeriesTask: Task<Void, Never>?
    /// Task to record reading progress - debounced based on the current page - that is NOT cancelled
    /// when switching chapters mid-process (ensuring the final record for the old chapter is sent before the user leaves).
    private var progressTask: Task<Void, Never>?

    private let progressDebounceNanoseconds: UInt64 = 500_000_000 // 500ms

    public init(
        seriesId: String,
        initialChapterId: String,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol
    ) {
        self.seriesId = seriesId
        self.initialChapterId = initialChapterId
        self.seriesRepository = seriesRepository
        self.commentRepository = commentRepository
        super.init()
    }

    // MARK: - Lifecycle

    public func onAppear() {
        loadSeries()
    }

    /// Show full series - only after obtaining `chapters` can `currentChapter` be determined and the pages/comments downloaded.
    private func loadSeries() {
        seriesState = .loading
        runTask({ [weak self] in
            guard let self else { return }
            let series = try await self.seriesRepository.fetchSeriesDetail(id: self.seriesId)
            let chapters = try await self.seriesRepository.fetchChapters(seriesId: self.seriesId)

            self.sortedChapters = chapters.sorted { $0.chapterNumber < $1.chapterNumber }
            self.currentChapter = self.sortedChapters.first(where: { $0.id == self.initialChapterId })
                ?? self.sortedChapters.last
                ?? self.currentChapter
            self.isFavoritedByMe = series.isFavoritedByMe
            self.isNotifyEnabled = series.isNotifyEnabled
            self.readingStatus = series.readingStatus
            self.seriesState = .loaded(series)

            self.loadPages()
            self.loadComments()
            self.loadGroupOtherSeries()
        }, onError: { [weak self] error in
            self?.seriesState = .failed(error)
        })
    }

    // MARK: - Navigation state

    public var currentChapterIndex: Int {
        sortedChapters.firstIndex(where: { $0.id == currentChapter.id }) ?? 0
    }

    public var hasPreviousChapter: Bool { currentChapterIndex > 0 }
    public var hasNextChapter: Bool { currentChapterIndex < sortedChapters.count - 1 }

    /// Dropdown list - LATEST first (reversed `sortedChapters`)
    public var chapterPickerItems: [Chapter] {
        sortedChapters.reversed()
    }

    // MARK: - Chapter navigation

    public func goToPreviousChapter() {
        guard hasPreviousChapter else { return }
        switchChapter(to: sortedChapters[currentChapterIndex - 1])
    }

    public func goToNextChapter() {
        guard hasNextChapter else { return }
        switchChapter(to: sortedChapters[currentChapterIndex + 1])
    }

    public func selectChapter(_ chapter: Chapter) {
        switchChapter(to: chapter)
        isChapterPickerPresented = false
    }

    private func switchChapter(to chapter: Chapter) {
        guard chapter.id != currentChapter.id else { return }
        currentChapter = chapter
        pagesState = .idle
        commentsState = .idle
        loadPages()
        loadComments()
        // Do NOT cancel progressTask here — to allow the final progress write for the old chapter a chance to complete.
    }

    // MARK: - Pages (critical, according to currentChapter)

    public func loadPages() {
        pagesState = .loading
        pagesTask?.cancel()
        pagesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let pages = try await self.seriesRepository.fetchChapterPages(chapterId: self.currentChapter.id)
                guard !Task.isCancelled else { return }
                self.pagesState = .loaded(pages)
                self.recordProgress(page: 1) // Just opened the chapter -> treat it as being on page 1.
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.pagesState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Reading progress (independent, debounced based on the current page)

    /// The view calls this function whenever a new page "becomes the primary visible page" during scrolling
    /// (via the `.onAppear` modifier of each image page or by tracking the ScrollView's position).
    public func recordProgress(page: Int) {
        progressTask?.cancel()
        let seriesId = self.seriesId
        let chapterId = currentChapter.id
        progressTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.progressDebounceNanoseconds ?? 500_000_000)
            guard !Task.isCancelled, let self else { return }
            // Best-effort: Logging reading progress should not interrupt the reading experience.
            try? await self.seriesRepository.recordReadingProgress(seriesId: seriesId, chapterId: chapterId, page: page)
        }
    }

    // MARK: - Comments (secondary, according to currentChapter)

    public func loadComments() {
        commentsTask?.cancel()
        commentsState = .loading
        commentsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.commentRepository.fetchChapterComments(chapterId: self.currentChapter.id, page: 1)
                guard !Task.isCancelled else { return }
                self.commentsState = .loaded(items)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.commentsState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - "Group-specific" (secondary, loaded once when opening the Reader, does not change by chapter)

    public func loadGroupOtherSeries() {
        groupOtherSeriesTask?.cancel()
        groupOtherSeriesState = .loading
        groupOtherSeriesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.seriesRepository.fetchRelatedSeries(seriesId: self.seriesId)
                guard !Task.isCancelled else { return }
                self.groupOtherSeriesState = .loaded(items)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.groupOtherSeriesState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Favorite / Notify / Reading Status (optimistic)

    public func toggleFavorite() {
        guard !isTogglingFavorite else { return }
        let previous = isFavoritedByMe
        isFavoritedByMe.toggle()
        isTogglingFavorite = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingFavorite = false } }
            do {
                try await self.seriesRepository.toggleFavorite(seriesId: self.seriesId, isFavorited: self.isFavoritedByMe)
            } catch {
                self.isFavoritedByMe = previous
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func toggleNotify() {
        guard !isTogglingNotify else { return }
        let previous = isNotifyEnabled
        isNotifyEnabled.toggle()
        isTogglingNotify = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingNotify = false } }
            do {
                try await self.seriesRepository.toggleNotify(seriesId: self.seriesId, enabled: self.isNotifyEnabled)
            } catch {
                self.isNotifyEnabled = previous
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func updateReadingStatus(to newStatus: ReadingStatus) {
        guard !isUpdatingReadingStatus else { return }
        let previous = readingStatus
        readingStatus = newStatus
        isUpdatingReadingStatus = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isUpdatingReadingStatus = false } }
            do {
                try await self.seriesRepository.updateReadingStatus(
                    seriesId: self.seriesId, status: newStatus, notifyNewChapter: self.isNotifyEnabled
                )
            } catch {
                self.readingStatus = previous
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func removeFromReadingList() {
        guard !isUpdatingReadingStatus else { return }
        let previous = readingStatus
        readingStatus = nil
        isUpdatingReadingStatus = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isUpdatingReadingStatus = false } }
            do {
                try await self.seriesRepository.removeReadingStatus(seriesId: self.seriesId)
            } catch {
                self.readingStatus = previous
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func dismissActionError() {
        actionErrorMessage = nil
    }

    deinit {
        pagesTask?.cancel()
        commentsTask?.cancel()
        groupOtherSeriesTask?.cancel()
        progressTask?.cancel()
    }
}
