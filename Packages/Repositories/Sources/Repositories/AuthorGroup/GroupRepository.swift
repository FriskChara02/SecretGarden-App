//
//  GroupRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

public final class GroupRepository: GroupRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchGroupDetail(id: String) async throws -> TranslationGroup {
        try await apiClient.request(GroupEndpoint.detail(id: id))
    }

    public func fetchGroupSeries(groupId: String, page: Int) async throws -> [Series] {
        try await apiClient.request(GroupEndpoint.series(groupId: groupId, page: page))
    }

    public func fetchGroupMembers(groupId: String) async throws -> [GroupMember] {
        try await apiClient.request(GroupEndpoint.members(groupId: groupId))
    }

    public func fetchGroupHighlights(
        groupId: String,
        sortBy: RankingSortBy,
        range: RankingRange
    ) async throws -> [Series] {
        try await apiClient.request(GroupEndpoint.highlights(groupId: groupId, sortBy: sortBy, range: range))
    }

    public func toggleFollow(groupId: String, isFollowing: Bool) async throws {
        let endpoint: GroupEndpoint = isFollowing ? .follow(groupId: groupId) : .unfollow(groupId: groupId)
        try await apiClient.requestWithoutResponse(endpoint)
    }

    public func toggleNotify(groupId: String, enabled: Bool) async throws {
        try await apiClient.requestWithoutResponse(GroupEndpoint.notify(groupId: groupId, enabled: enabled))
    }

    public func discoverGroups(query: String, sort: GroupDiscoverSort, page: Int) async throws -> [TranslationGroup] {
        try await apiClient.request(GroupEndpoint.discover(query: query, sort: sort, page: page))
    }

    public func fetchFollowedGroups() async throws -> [TranslationGroup] {
        try await apiClient.request(GroupEndpoint.followedGroups)
    }
}
