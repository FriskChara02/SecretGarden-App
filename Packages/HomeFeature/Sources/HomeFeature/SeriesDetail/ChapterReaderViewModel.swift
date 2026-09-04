//
//  ChapterReaderViewModel.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 4/9/26.
//

// ViewModel for the Chapter Reader. Receives pre-loaded `chapters` from SeriesDetailViewModel
// (does NOT re-fetch the chapter list—avoiding redundant network calls), but fetches ChapterPages
// individually as needed. Favorite/Notify states are initialized from the Series loaded in the Detail view
// and managed via independent optimistic updates (there is NO two-way synchronization with SeriesDetailViewModel).

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class ChapterReaderViewModel: BaseViewModel {

    private let seriesId: String
    private let seriesRepository: SeriesRepositoryProtocol
    private let commentRepository: CommentRepositoryProtocol

    /// List of chapters sorted in ascending order (oldest → newest) - fixed for the lifetime of the Reader,
    /// used to calculate previous/next chapters and populate the quick-selection dropdown.
    private let sortedChapters: [Chapter]

    @Published public private(set) var currentChapter: Chapter
    @Published public private(set) var pagesState: LoadableState<[ChapterPage]> = .idle
    @Published public private(set) var commentsState: LoadableState<[Comment]> = .idle

    // MARK: - Favorite / Notify (optimistic, initialized from Detail — see note at the top of the file)

    @Published public private(set) var isFavoritedByMe: Bool
    @Published public private(set) var isNotifyEnabled: Bool
    @Published public private(set) var readingStatus: ReadingStatus?
    @Published public private(set) var isUpdatingReadingStatus = false
    @Published public private(set) var isTogglingFavorite = false
    @Published public private(set) var isTogglingNotify = false
    @Published public var actionErrorMessage: String?

    // MARK: - Overlay / Menu presentation state (Purely UI-focused, the View will bind directly.)

    @Published public var isMenuPresented = false
    @Published public var isCommentsOverlayPresented = false
    @Published public var isChapterPickerPresented = false

    private var pagesTask: Task<Void, Never>?
    private var commentsTask: Task<Void, Never>?
    /// Task to record reading progress - debounced based on the current page - that is NOT cancelled
    /// when switching chapters mid-process (ensuring the final record for the old chapter is sent before the user leaves).
    private var progressTask: Task<Void, Never>?

    private let progressDebounceNanoseconds: UInt64 = 500_000_000 // 500ms

    public init(
        seriesId: String,
        chapters: [Chapter],
        initialChapterId: String,
        isFavoritedByMe: Bool,
        isNotifyEnabled: Bool,
        readingStatus: ReadingStatus?,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol
    ) {
        self.seriesId = seriesId
        self.sortedChapters = chapters.sorted { $0.chapterNumber < $1.chapterNumber }
        self.currentChapter = sortedChapters.first(where: { $0.id == initialChapterId })
            ?? sortedChapters.last
            ?? Chapter(id: initialChapterId, seriesId: seriesId, chapterNumber: 0, releasedAt: Date())
        self.isFavoritedByMe = isFavoritedByMe
        self.isNotifyEnabled = isNotifyEnabled
        self.readingStatus = readingStatus
        self.seriesRepository = seriesRepository
        self.commentRepository = commentRepository
        super.init()
    }

    // MARK: - Lifecycle

    public func onAppear() {
        loadPages()
        loadComments()
    }

    // MARK: - Navigation state (computed — Read-only view, the index is not automatically calculated)

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

    // MARK: - Pages (critical)

    public func loadPages() {
        pagesState = .loading
        runTask({ [weak self] in
            guard let self else { return }
            let pages = try await self.seriesRepository.fetchChapterPages(chapterId: self.currentChapter.id)
            self.pagesState = .loaded(pages)
            self.recordProgress(page: 1) // Just opened the chapter -> treat it as being on page 1.
        }, onError: { [weak self] error in
            self?.pagesState = .failed(error)
        })
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

    // MARK: - Comments (secondary, by chapter)

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

    // MARK: - Favorite / Notify (optimistic — using the same SeriesDetailViewModel pattern)

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
        progressTask?.cancel()
    }
}
