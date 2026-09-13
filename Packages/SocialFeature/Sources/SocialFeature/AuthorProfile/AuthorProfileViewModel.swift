//
//  AuthorProfileViewModel.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// ViewModel — shared by BOTH Author and Artist.
// Simpler than GroupProfileViewModel: no Members/Highlights, only Detail (critical) + paginated Series list (secondary).

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class AuthorProfileViewModel: BaseViewModel {

    private let authorId: String
    private let authorRepository: AuthorRepositoryProtocol

    @Published public private(set) var detailState: LoadableState<AuthorGroupCommon> = .idle
    @Published public private(set) var seriesState: LoadableState<[Series]> = .idle
    @Published public private(set) var currentPage: Int = 1
    /// Temporarily hardcoded to 1 — will be updated when the actual backend returns the total number of pages.
    @Published public private(set) var totalPages: Int = 1

    @Published public private(set) var isTogglingFollow = false
    @Published public private(set) var isTogglingNotify = false
    @Published public var actionErrorMessage: String?
    @Published public var successMessage: String?

    private var seriesTask: Task<Void, Never>?

    public init(authorId: String, authorRepository: AuthorRepositoryProtocol) {
        self.authorId = authorId
        self.authorRepository = authorRepository
        super.init()
    }

    public func onAppear() {
        loadDetail()
        loadSeries(page: 1)
    }

    public func loadDetail() {
        detailState = .loading
        runTask({ [weak self] in
            guard let self else { return }
            let detail = try await self.authorRepository.fetchAuthorDetail(id: self.authorId)
            self.detailState = .loaded(detail)
        }, onError: { [weak self] error in
            self?.detailState = .failed(error)
        })
    }

    public func loadSeries(page: Int) {
        seriesTask?.cancel()
        seriesState = .loading
        currentPage = page
        seriesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.authorRepository.fetchAuthorSeries(authorId: self.authorId, page: page)
                guard !Task.isCancelled else { return }
                self.seriesState = .loaded(items)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.seriesState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Follow (optimistic + toast) — same pattern GroupProfileViewModel

    public func toggleFollow() {
        guard let current = detailState.value, !isTogglingFollow else { return }
        let previous = current
        var updated = current
        let willFollow = !updated.isFollowedByMe
        updated.isFollowedByMe = willFollow
        if !willFollow {
            updated.isNotifyEnabled = false
        }
        detailState = .loaded(updated)
        isTogglingFollow = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingFollow = false } }
            do {
                try await self.authorRepository.toggleFollow(authorId: previous.id, isFollowing: willFollow)
                self.successMessage = willFollow ? "Đã theo dõi" : "Đã hủy theo dõi"
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func toggleNotify() {
        guard let current = detailState.value, current.isFollowedByMe, !isTogglingNotify else { return }
        let previous = current
        var updated = current
        updated.isNotifyEnabled.toggle()
        detailState = .loaded(updated)
        isTogglingNotify = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingNotify = false } }
            do {
                try await self.authorRepository.toggleNotify(authorId: previous.id, enabled: updated.isNotifyEnabled)
                self.successMessage = updated.isNotifyEnabled ? "Đã bật thông báo" : "Đã tắt thông báo"
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    public func dismissActionError() {
        actionErrorMessage = nil
    }

    deinit {
        seriesTask?.cancel()
    }
}
