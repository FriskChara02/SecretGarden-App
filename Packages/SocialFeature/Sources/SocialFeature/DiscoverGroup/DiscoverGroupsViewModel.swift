//
//  DiscoverGroupsViewModel.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// 350ms debounce — the same threshold used in SearchViewModel, ensuring a consistent real-time search-as-you-type experience across the app.

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class DiscoverGroupsViewModel: BaseViewModel {

    private let groupRepository: GroupRepositoryProtocol

    @Published public var searchQuery: String = "" {
        didSet { scheduleSearch() }
    }
    @Published public private(set) var selectedSort: GroupDiscoverSort = .mostFollowed
    @Published public private(set) var state: LoadableState<[TranslationGroup]> = .idle

    private var searchTask: Task<Void, Never>?

    public init(groupRepository: GroupRepositoryProtocol) {
        self.groupRepository = groupRepository
        super.init()
    }

    public func onAppear() {
        load()
    }

    public func changeSort(_ sort: GroupDiscoverSort) {
        selectedSort = sort
        load()
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await self?.performLoad()
        }
    }

    public func load() {
        searchTask?.cancel()
        Task { [weak self] in
            await self?.performLoad()
        }
    }

    private func performLoad() async {
        state = .loading
        do {
            let groups = try await groupRepository.discoverGroups(query: searchQuery, sort: selectedSort, page: 1)
            guard !Task.isCancelled else { return }
            state = .loaded(groups)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(mapToAppError(error))
        }
    }

    deinit {
        searchTask?.cancel()
    }
}
