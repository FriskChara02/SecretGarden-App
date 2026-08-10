//
//  LoadableViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// A specialized base class for screens that follow the "fetch a block of content and display it" pattern
// (e.g., Series Detail, Author Profile, Group Profile). Future ViewModels
// simply need to inherit from this class; there is no need to manually implement the idle->loading->loaded/failed state machine.
//
// Real-world usage example (illustration):
//
//   final class SeriesDetailViewModel: LoadableViewModel<Series> {
//       private let repository: SeriesRepositoryProtocol
//       private let seriesId: String
//
//       init(seriesId: String, repository: SeriesRepositoryProtocol) {
//           self.seriesId = seriesId
//           self.repository = repository
//           super.init()
//       }
//
//       func fetchDetail() {
//           load { [repository, seriesId] in
//               try await repository.fetchSeriesDetail(id: seriesId)
//           }
//       }
//   }

import Combine
import Foundation

@MainActor
open class LoadableViewModel<Content: Equatable>: BaseViewModel {
    @Published public private(set) var state: LoadableState<Content> = .idle

    override public init() {
        super.init()
    }

    /// Call `fetch` and update `state` according to the correct lifecycle: `.loading` immediately,
    /// followed by `.loaded(result)` or `.failed(error)` when `fetch` completes.
    public func load(_ fetch: @escaping () async throws -> Content) {
        state = .loading
        runTask(
            { [weak self] in
                let result = try await fetch()
                self?.state = .loaded(result)
            },
            onError: { [weak self] appError in
                self?.state = .failed(appError)
            }
        )
    }
}
