//
//  AdvancedFilterViewModel.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 30/8/26.
//

// ViewModel for the Filter modal — manages a draft state separate from the applied filter
// (AdvancedSearchViewModel.currentFilter). Changes within the sheet affect only the `draft`
// and are only committed when "Apply" is pressed — preventing the old filter from being
// altered mid-process if the user makes random selections and then closes the sheet.

import CoreArchitecture
import CoreModels
import Combine
import Foundation
import Repositories

public enum FilterTabMode {
    case include
    case exclude
}

@MainActor
public final class AdvancedFilterViewModel: BaseViewModel {

    private let repository: SearchRepositoryProtocol

    /// Draft currently being edited in the sheet - initialized from the currently applied filter.
    @Published public var draft: AdvancedFilterRequest
    @Published public var tabMode: FilterTabMode = .include
    @Published public private(set) var optionsState: LoadableState<AdvancedFilterOptions> = .idle

    public init(repository: SearchRepositoryProtocol, initialFilter: AdvancedFilterRequest) {
        self.repository = repository
        self.draft = initialFilter
        super.init()
    }

    public func loadOptions() {
        optionsState = .loading
        runTask { [weak self] in
            guard let self else { return }
            let options = try await self.repository.fetchFilterOptions()
            self.optionsState = .loaded(options)
        } onError: { [weak self] appError in
            self?.optionsState = .failed(appError)
        }
    }

    /// A shared toggle function for all 10 include/exclude arrays — avoiding the need to write 10 nearly identical functions.
    /// WritableKeyPath allows for precisely specifying which field within AdvancedFilterRequest needs to be modified.
    public func toggleSelection(id: String, at keyPath: WritableKeyPath<AdvancedFilterRequest, [String]>) {
        if draft[keyPath: keyPath].contains(id) {
            draft[keyPath: keyPath].removeAll { $0 == id }
        } else {
            draft[keyPath: keyPath].append(id)
        }
    }

    public func isSelected(id: String, at keyPath: KeyPath<AdvancedFilterRequest, [String]>) -> Bool {
        draft[keyPath: keyPath].contains(id)
    }

    public func resetDraft() {
        draft = AdvancedFilterRequest()
    }
}
