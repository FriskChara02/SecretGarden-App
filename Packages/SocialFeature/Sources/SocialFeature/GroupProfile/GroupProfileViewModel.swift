//
//  GroupProfileViewModel.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 12/9/26.
//

// ViewModel for Group Profile. 3 independent LoadableStates:
// - detailState: CRITICAL (group info + follow/notify) — errors trigger a full-screen error view
// - membersState, seriesState: SECONDARY — errors appear only within the respective section
// (following the critical/secondary pattern used in SeriesDetailViewModel)
//
// Follow/Notify uses optimistic updates — BUSINESS RULE: Unfollowing must also
// toggle off the notification status (consistent with AuthorRepositoryMock/GroupRepositoryMock logic).
// NO separate toast for rollback errors — actionErrorMessage is sufficient.

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class GroupProfileViewModel: BaseViewModel {

    private let groupId: String
    private let groupRepository: GroupRepositoryProtocol

    @Published public private(set) var detailState: LoadableState<TranslationGroup> = .idle
    @Published public private(set) var membersState: LoadableState<[GroupMember]> = .idle
    @Published public private(set) var seriesState: LoadableState<[Series]> = .idle

    @Published public private(set) var isTogglingFollow = false
    @Published public private(set) var isTogglingNotify = false
    @Published public var actionErrorMessage: String?
    /// DSSuccessToastModifier — This field is shared by Follow, Unfollow, and Toggle Notifications actions.
    @Published public var successMessage: String?

    private var membersTask: Task<Void, Never>?
    private var seriesTask: Task<Void, Never>?

    public init(groupId: String, groupRepository: GroupRepositoryProtocol) {
        self.groupId = groupId
        self.groupRepository = groupRepository
        super.init()
    }

    public func onAppear() {
        loadDetail()
        loadMembers()
        loadSeries()
    }

    // MARK: - Critical load

    public func loadDetail() {
        detailState = .loading
        runTask({ [weak self] in
            guard let self else { return }
            let detail = try await self.groupRepository.fetchGroupDetail(id: self.groupId)
            self.detailState = .loaded(detail)
        }, onError: { [weak self] error in
            self?.detailState = .failed(error)
        })
    }

    // MARK: - Secondary load (independent, without using runTask)

    public func loadMembers() {
        membersTask?.cancel()
        membersState = .loading
        membersTask = Task { [weak self] in
            guard let self else { return }
            do {
                let members = try await self.groupRepository.fetchGroupMembers(groupId: self.groupId)
                guard !Task.isCancelled else { return }
                self.membersState = .loaded(members)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.membersState = .failed(self.mapToAppError(error))
            }
        }
    }

    public func loadSeries() {
        seriesTask?.cancel()
        seriesState = .loading
        seriesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let series = try await self.groupRepository.fetchGroupSeries(groupId: self.groupId, page: 1)
                guard !Task.isCancelled else { return }
                self.seriesState = .loaded(series)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                self.seriesState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Follow (optimistic + toast)

    public func toggleFollow() {
        guard let current = detailState.value, !isTogglingFollow else { return }
        let previous = current
        var updated = current
        let willFollow = !updated.isFollowedByMe
        updated.isFollowedByMe = willFollow
        updated.followerCount += willFollow ? 1 : -1
        if !willFollow {
            updated.isNotifyEnabled = false // Business rule: Unfollow -> automatically disable notifications.
        }
        detailState = .loaded(updated)
        isTogglingFollow = true

        Task { [weak self] in
            guard let self else { return }
            defer { Task { @MainActor in self.isTogglingFollow = false } }
            do {
                try await self.groupRepository.toggleFollow(groupId: previous.id, isFollowing: willFollow)
                self.successMessage = willFollow ? "Đã theo dõi nhóm" : "Đã hủy theo dõi nhóm"
            } catch {
                self.detailState = .loaded(previous)
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    // MARK: - Notify (optimistic + toast, valid only if you follow)

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
                try await self.groupRepository.toggleNotify(groupId: previous.id, enabled: updated.isNotifyEnabled)
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
        membersTask?.cancel()
        seriesTask?.cancel()
    }
}
