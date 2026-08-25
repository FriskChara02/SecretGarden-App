//
//  HomeViewModel.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 21/8/26.
//

// ViewModel for HomeView - loads four independent data sources in parallel
// (Continue Reading, Latest Updates, Ranking, Random Comments), each section
// has its own LoadableState so that a failure in one section does not crash the entire screen (partial failure).

import CoreArchitecture
import CoreModels
import Combine
import Foundation
import Repositories

@MainActor
public final class HomeViewModel: BaseViewModel {

    private let repository: HomeRepositoryProtocol

    // MARK: - Section states (completely independent of one another)

    @Published public private(set) var continueReadingState: LoadableState<[ContinueReadingItem]> = .idle
    @Published public private(set) var latestUpdatesState: LoadableState<[Series]> = .idle
    @Published public private(set) var rankingState: LoadableState<[Series]> = .idle
    @Published public private(set) var randomCommentsState: LoadableState<[Comment]> = .idle
    @Published public private(set) var randomYuriState: LoadableState<[Series]> = .idle

    @Published public private(set) var selectedRankingRange: RankingRange = .day
    @Published public private(set) var selectedRankingSortBy: RankingSortBy = .views

    /// Dedicated task for the Ranking section - separate from the `currentTask` inherited from `BaseViewModel`
    /// (which is used for `loadHome()`). Reason: `BaseViewModel.runTask` tracks only a single task,
    /// sharing it would mean that changing the Ranking filter would inadvertently cancel three other sections currently in the process of loading.
    private var rankingTask: Task<Void, Never>?
    private var randomYuriTask: Task<Void, Never>?

    public init(repository: HomeRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    // MARK: - Public actions

    /// Load all 4 sections in parallel. Called when HomeView first appears or upon pull-to-refresh.
    public func loadHome() {
        continueReadingState = .loading
        latestUpdatesState = .loading
        rankingState = .loading
        randomCommentsState = .loading
        randomYuriState = .loading

        runTask { [weak self] in
            guard let self else { return }
            // async let: fires off 5 network requests almost concurrently (with each function awaiting internally),
            // even though state updates occur sequentially on the MainActor - aligning with the "parallel network requests,
            // sequential state updates" pattern suitable for an @MainActor ViewModel.
            async let continueReading: Void = self.loadContinueReading()
            async let latestUpdates: Void = self.loadLatestUpdates()
            async let ranking: Void = self.loadRanking(range: self.selectedRankingRange, sortBy: self.selectedRankingSortBy)
            async let randomComments: Void = self.loadRandomComments()
            async let randomYuri: Void = self.loadRandomYuri(type: .manga)
            _ = await (continueReading, latestUpdates, ranking, randomComments, randomYuri)
        }
    }

    /// Reload the ranking based on both filter dimensions - called when the range OR sortBy changes.
    public func reloadRanking(range: RankingRange, sortBy: RankingSortBy) {
        selectedRankingRange = range
        selectedRankingSortBy = sortBy
        rankingTask?.cancel()
        rankingState = .loading
        rankingTask = Task { [weak self] in
            await self?.loadRanking(range: range, sortBy: sortBy)
        }
    }
    
    /// Reloads only Random Yuri — called when the refresh button is pressed OR when the Manga/Novel toggle changes.
    /// Do NOT use the inherited runTask, this avoids accidentally cancelling the other 4 sections (same reason as reloadRanking).
    public func refreshRandomYuri(type: SeriesType) {
            randomYuriTask?.cancel()
            randomYuriState = .loading
            randomYuriTask = Task { [weak self] in
                await self?.loadRandomYuri(type: type)
            }
        }

    // MARK: - Per-section loaders
    // Each function does NOT throw errors externally, it catches its own errors and manages the state of its specific section.
    // This mechanism ensures "partial failure" handling: a Ranking error not affect the "Continue Reading" section that already loaded.
    private func loadContinueReading() async {
        do {
            let items = try await repository.fetchContinueReading()
            guard !Task.isCancelled else { return }
            continueReadingState = .loaded(items)
        } catch is CancellationError {
            // Task intentionally cancelled (leaving the Home screen) - not an error, ignore silently.
        } catch {
            guard !Task.isCancelled else { return }
            continueReadingState = .failed(mapToAppError(error))
        }
    }

    private func loadLatestUpdates() async {
        do {
            let items = try await repository.fetchLatestUpdates(page: 1)
            guard !Task.isCancelled else { return }
            latestUpdatesState = .loaded(items)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            latestUpdatesState = .failed(mapToAppError(error))
        }
    }

    private func loadRanking(range: RankingRange, sortBy: RankingSortBy) async {
        do {
            let items = try await repository.fetchRanking(range: range, sortBy: sortBy, page: 1)
            guard !Task.isCancelled else { return }
            rankingState = .loaded(items)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            rankingState = .failed(mapToAppError(error))
        }
    }

    private func loadRandomComments() async {
        do {
            let items = try await repository.fetchRandomComments()
            guard !Task.isCancelled else { return }
            randomCommentsState = .loaded(items)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            randomCommentsState = .failed(mapToAppError(error))
        }
    }
    
    private func loadRandomYuri(type: SeriesType) async {
        do {
            let items = try await repository.fetchRandomYuri(type: type)
            guard !Task.isCancelled else { return }
            randomYuriState = .loaded(items)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            randomYuriState = .failed(mapToAppError(error))
        }
    }

    deinit {
        rankingTask?.cancel()
        randomYuriTask?.cancel()
    }
}
