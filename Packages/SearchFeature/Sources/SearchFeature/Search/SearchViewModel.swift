//
//  SearchViewModel.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 29/8/26.
//

// ViewModel for the Search screen — manages two COMPLETELY INDEPENDENT data streams:
// (1) basic search results (search-as-you-type, with debouncing), and
// (2) search history (loaded upon screen opening, recorded on submission and supports deleting individual items or clearing all).
// Separates the two tasks (searchTask/historyTask) — does not share the runTask inherited from BaseViewModel.

import CoreArchitecture
import CoreModels
import Combine
import Foundation
import Repositories

@MainActor
public final class SearchViewModel: BaseViewModel {

    private let repository: SearchRepositoryProtocol

    /// Search query content – ​​two-way binding with the TextField in the SearchView.
    /// The view calls `handleQueryChange(_:)` via `.onChange(of:)` when this value changes
    /// (DO NOT use `didSet` directly on this property – see the explanation in `handleQueryChange`).
    @Published public var queryText: String = ""

    @Published public private(set) var resultsState: LoadableState<[Series]> = .idle
    @Published public private(set) var historyState: LoadableState<[SearchHistoryItem]> = .idle

    /// Dedicated task for search — includes debouncing, cancelled and recreated with every new keystroke.
    private var searchTask: Task<Void, Never>?
    /// Dedicated task for history — NO debouncing, completely independent of searchTask.
    private var historyTask: Task<Void, Never>?

    /// The delay after stopping typing before the API is actually called - 350ms.
    private let debounceNanoseconds: UInt64 = 350_000_000
    /// Minimum number of characters to automatically trigger the search - 1 character.
    private let minimumQueryLength = 1

    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    // MARK: - Lifecycle

    /// Called when the SearchView first appears — load history only, NOT perform any automatic search.
    public func onAppear() {
        loadHistory()
    }

    // MARK: - Search-as-you-type (debounced, NO history logging)

    /// The view calls this function whenever `queryText` changes (via `.onChange(of: viewModel.queryText)`).
    /// An explicit function is used instead of a `didSet` observer on `queryText` to avoid hard-to-control loops:
    /// `submitSearch` also needs to update `queryText` (e.g., when tapping a history item), using
    /// `didSet` would inadvertently re-trigger the debounce operation unnecessarily.
    public func handleQueryChange(_ newValue: String) {
        searchTask?.cancel()

        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumQueryLength else {
            // Search box is empty or lacks the minimum number of characters – revert to idle state,
            // NOT .failed (this is not an error, there is simply nothing to search for yet).
            resultsState = .idle
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.debounceNanoseconds)
            guard !Task.isCancelled else { return }
            // Debounce trigger = confirming the user has "stopped typing" — search-as-you-type does NOT record history
            // (history is only recorded upon an explicit submission).
            await self.performSearch(query: trimmed)
        }
    }

    // MARK: - Proactive Submit (Enter / Search button / tap a history item — record history, skip debounce)

    /// Called when the user explicitly confirms a search — performs the search immediately (bypassing debounce)
    /// and records it in the history. `query` is an optional parameter for cases
    /// taps directly on an existing history item (avoiding the need to re-type).
    public func submitSearch(query: String? = nil) {
        let finalQuery = (query ?? queryText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !finalQuery.isEmpty else { return }

        queryText = finalQuery
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            await self.performSearch(query: finalQuery)
            guard !Task.isCancelled else { return }
            await self.recordHistory(query: finalQuery)
        }
    }

    // MARK: - Core search function — shared by both debounce and submit

    private func performSearch(query: String) async {
        resultsState = .loading
        do {
            let items = try await repository.searchBasic(query: query, page: 1)
            guard !Task.isCancelled else { return }
            resultsState = .loaded(items)
        } catch is CancellationError {
            // Intentionally cancelled (user typed another character) — not an error, ignore silently.
        } catch {
            guard !Task.isCancelled else { return }
            resultsState = .failed(mapToAppError(error))
        }
    }

    /// Log history — "best-effort": if logging fails (a rare SwiftData issue),
    /// do NOT disrupt the search result display experience (which already succeeded in performSearch).
    private func recordHistory(query: String) async {
        do {
            try await repository.addHistory(query: query)
            await loadHistoryAsync()
        } catch {
            // Intentionally swallow the error — Log history is a secondary feature, an alert blocking the user
            // should not be shown just because of a logging error when the main search results have successfully displayed.
        }
    }

    // MARK: - Search history (completely independent of searchTask)

    public func loadHistory() {
        historyTask?.cancel()
        historyState = .loading
        historyTask = Task { [weak self] in
            await self?.loadHistoryAsync()
        }
    }

    private func loadHistoryAsync() async {
        do {
            let items = try await repository.fetchHistory()
            guard !Task.isCancelled else { return }
            historyState = .loaded(items)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            historyState = .failed(mapToAppError(error))
        }
    }

    public func removeHistoryItem(id: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.removeHistory(id: id)
                await self.loadHistoryAsync()
            } catch {
                // Best-effort, similar to recordHistory — does not block the UI due to a failure to delete a history item.
            }
        }
    }

    public func clearAllHistory() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.clearHistory()
                await self.loadHistoryAsync()
            } catch {
            }
        }
    }

    // MARK: - Reset search field ("X" button in TextField)

    public func clearQuery() {
        queryText = ""
        searchTask?.cancel()
        resultsState = .idle
    }

    deinit {
        searchTask?.cancel()
        historyTask?.cancel()
    }
}
