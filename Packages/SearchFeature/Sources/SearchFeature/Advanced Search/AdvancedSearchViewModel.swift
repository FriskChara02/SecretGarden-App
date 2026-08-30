//
//  AdvancedSearchViewModel.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 30/8/26.
//

// ViewModel for the Advanced Search screen — INDEPENDENT of SearchViewModel (Search tab)
// even though both call repository.searchAdvanced(...). Key business logic difference: this screen
// does NOT feature debounce/search-as-you-type — it only performs the search when the user
// explicitly taps "Search" after selecting filters via AdvancedFilterView.

import CoreArchitecture
import CoreModels
import Combine
import Foundation
import Repositories

@MainActor
public final class AdvancedSearchViewModel: BaseViewModel {

    private let repository: SearchRepositoryProtocol

    /// Current filter — updated by AdvancedFilterView via binding.
    @Published public var currentFilter: AdvancedFilterRequest = AdvancedFilterRequest()

    @Published public private(set) var resultsState: LoadableState<[Series]> = .loaded([])
    @Published public var isFilterSheetPresented = false

    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    /// true if the user has selected at least one filter criterion – used to display the "!" badge on the "Filter" button;
    /// calculated directly from currentFilter instead of storing a separate boolean variable (to avoid state inconsistency).
    public var hasActiveFilter: Bool {
        !currentFilter.includeTags.isEmpty || !currentFilter.excludeTags.isEmpty ||
        !currentFilter.includeAuthors.isEmpty || !currentFilter.excludeAuthors.isEmpty ||
        !currentFilter.includeArtists.isEmpty || !currentFilter.excludeArtists.isEmpty ||
        !currentFilter.includePairings.isEmpty || !currentFilter.excludePairings.isEmpty ||
        !currentFilter.includeGroups.isEmpty || !currentFilter.excludeGroups.isEmpty ||
        currentFilter.status != nil ||
        (currentFilter.minChapterCount ?? 0) > 0
    }

    public func openFilterSheet() {
        isFilterSheetPresented = true
    }

    /// Called by AdvancedFilterView when "Apply" is clicked – closes the sheet and performs the search immediately.
    public func applyFilter(_ filter: AdvancedFilterRequest) {
        currentFilter = filter
        isFilterSheetPresented = false
        search()
    }

    public func resetFilter() {
        currentFilter = AdvancedFilterRequest()
        resultsState = .idle
    }

    public func search() {
        resultsState = .loading
        runTask { [weak self] in
            guard let self else { return }
            let items = try await self.repository.searchAdvanced(filter: self.currentFilter, page: 1)
            self.resultsState = .loaded(items)
        } onError: { [weak self] appError in
            self?.resultsState = .failed(appError)
        }
    }
}
