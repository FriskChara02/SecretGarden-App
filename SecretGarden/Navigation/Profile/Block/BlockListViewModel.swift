//
//  BlockListViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/9/26.
//

import CoreArchitecture
import CoreModels
import Foundation
import Repositories
import Combine

enum BlockListCategory: String, CaseIterable {
    case series = "Truyện"
    case tags = "Tags"
}

@MainActor
final class BlockListViewModel: BaseViewModel {

    private let repository: BlockListRepositoryProtocol
    private let searchRepository: SearchRepositoryProtocol

    @Published var selectedCategory: BlockListCategory = .series
    @Published private(set) var blockedSeriesState: LoadableState<[BlockedSeriesItem]> = .idle
    @Published private(set) var blockedTagsState: LoadableState<[BlockedTagItem]> = .idle
    @Published var actionErrorMessage: String?
    @Published var successMessage: String?
    @Published var seriesSearchQuery = ""
    @Published private(set) var seriesSearchState: LoadableState<[Series]> = .idle
    @Published var tagSearchQuery = ""
    @Published private(set) var tagOptionsState: LoadableState<[Tag]> = .idle

    private var searchTask: Task<Void, Never>?

    init(repository: BlockListRepositoryProtocol, searchRepository: SearchRepositoryProtocol) {
        self.repository = repository
        self.searchRepository = searchRepository
        super.init()
    }

    func onAppear() {
        if case .idle = blockedSeriesState { loadBlockedSeries() }
        if case .idle = blockedTagsState { loadBlockedTags() }
    }

    func loadBlockedSeries() {
        blockedSeriesState = .loading
        Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.repository.fetchBlockedSeries()
                self.blockedSeriesState = .loaded(items)
            } catch {
                self.blockedSeriesState = .failed(self.mapToAppError(error))
            }
        }
    }

    func loadBlockedTags() {
        blockedTagsState = .loading
        Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.repository.fetchBlockedTags()
                self.blockedTagsState = .loaded(items)
            } catch {
                self.blockedTagsState = .failed(self.mapToAppError(error))
            }
        }
    }

    func unblockSeries(_ seriesId: String) {
        guard case .loaded(var items) = blockedSeriesState else { return }
        let previous = items
        items.removeAll { $0.series.id == seriesId }
        blockedSeriesState = .loaded(items)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.unblockSeries(seriesId: seriesId)
                self.successMessage = "Đã bỏ chặn thành công"
            } catch {
                self.blockedSeriesState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    func unblockTag(_ tagId: String) {
        guard case .loaded(var items) = blockedTagsState else { return }
        let previous = items
        items.removeAll { $0.tag.id == tagId }
        blockedTagsState = .loaded(items)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.unblockTag(tagId: tagId)
                self.successMessage = "Đã bỏ chặn thành công"
            } catch {
                self.blockedTagsState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    func searchSeries(query: String) {
        seriesSearchQuery = query
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            seriesSearchState = .idle
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard let self, !Task.isCancelled else { return }
            self.seriesSearchState = .loading
            do {
                let results = try await self.searchRepository.searchBasic(query: query, page: 1)
                guard !Task.isCancelled else { return }
                self.seriesSearchState = .loaded(results)
            } catch {
                self.seriesSearchState = .failed(self.mapToAppError(error))
            }
        }
    }

    /// isSeriesBlocked(_:) is used to correctly display the "Blocked" button (green, disabled) in the search modal.
    func isSeriesBlocked(_ seriesId: String) -> Bool {
        guard case .loaded(let items) = blockedSeriesState else { return false }
        return items.contains { $0.series.id == seriesId }
    }

    func blockSeries(_ series: Series) {
        guard !isSeriesBlocked(series.id), case .loaded(let items) = blockedSeriesState else {
            // If blockedSeriesState is not yet .loaded (the initial fetch hasn't completed), initialize an empty array so items can still be added.
            if case .idle = blockedSeriesState {
                proceedBlockSeries(series, currentItems: [])
            }
            return
        }
        proceedBlockSeries(series, currentItems: items)
    }

    private func proceedBlockSeries(_ series: Series, currentItems: [BlockedSeriesItem]) {
        var items = currentItems
        items.append(BlockedSeriesItem(id: UUID().uuidString, series: series, blockedAt: Date()))
        blockedSeriesState = .loaded(items)
        successMessage = "Đã thêm vào danh sách chặn"

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.blockSeries(seriesId: series.id)
            } catch {
                // rollback: remove the item just optimistically added
                if case .loaded(var rollbackItems) = self.blockedSeriesState {
                    rollbackItems.removeAll { $0.series.id == series.id }
                    self.blockedSeriesState = .loaded(rollbackItems)
                }
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    // MARK: - Chặn Tags

    func loadTagOptions() {
        guard case .idle = tagOptionsState else { return }
        tagOptionsState = .loading
        Task { [weak self] in
            guard let self else { return }
            do {
                let options = try await self.searchRepository.fetchFilterOptions()
                self.tagOptionsState = .loaded(options.tags)
            } catch {
                self.tagOptionsState = .failed(self.mapToAppError(error))
            }
        }
    }

    var filteredTagOptions: [Tag] {
        guard case .loaded(let tags) = tagOptionsState else { return [] }
        guard !tagSearchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return tags }
        return tags.filter { $0.name.localizedCaseInsensitiveContains(tagSearchQuery) }
    }

    func isTagBlocked(_ tagId: String) -> Bool {
        guard case .loaded(let items) = blockedTagsState else { return false }
        return items.contains { $0.tag.id == tagId }
    }

    func blockTag(_ tag: Tag) {
        guard !isTagBlocked(tag.id) else { return }
        var items: [BlockedTagItem] = []
        if case .loaded(let current) = blockedTagsState { items = current }
        items.append(BlockedTagItem(id: UUID().uuidString, tag: tag, blockedAt: Date()))
        blockedTagsState = .loaded(items)
        successMessage = "Đã thêm vào danh sách chặn"

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repository.blockTag(tagId: tag.id)
            } catch {
                if case .loaded(var rollbackItems) = self.blockedTagsState {
                    rollbackItems.removeAll { $0.tag.id == tag.id }
                    self.blockedTagsState = .loaded(rollbackItems)
                }
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    func dismissActionError() {
        actionErrorMessage = nil
    }
}
