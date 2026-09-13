//
//  GroupRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

// Repository for Translation Group — differs from AuthorRepository in that a Group is an ORGANIZATION
// (with members, an aggregate follower count and its own "Group Highlights"), not an individual.

import CoreModels
import Foundation

public protocol GroupRepositoryProtocol {
    /// Group details - `GET /groups/{id}`.
    func fetchGroupDetail(id: String) async throws -> TranslationGroup

    /// Group's list of stories - `GET /groups/{id}/series?page=`.
    func fetchGroupSeries(groupId: String, page: Int) async throws -> [Series]

    /// Team members - `GET /groups/{id}/members`.
    func fetchGroupMembers(groupId: String) async throws -> [GroupMember]

    /// "Group highlight" - scoped by groupId
    func fetchGroupHighlights(
        groupId: String,
        sortBy: RankingSortBy,
        range: RankingRange
    ) async throws -> [Series]

    /// Follow/Unfollow group - `POST /groups/{id}/follow` / `DELETE`.
    func toggleFollow(groupId: String, isFollowing: Bool) async throws

    /// Toggle individual notifications for the group - `PUT /groups/{id}/notify`.
    func toggleNotify(groupId: String, enabled: Bool) async throws

    /// Explore groups - `GET /groups/discover?q=&sort=&page=`.
    func discoverGroups(query: String, sort: GroupDiscoverSort, page: Int) async throws -> [TranslationGroup]
    
    /// Followed Groups
    func fetchFollowedGroups() async throws -> [TranslationGroup]
}

/// Sorting for Discover Groups - 4 dropdown options.
public enum GroupDiscoverSort: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case mostFollowed
    case alphabetical

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .newest: return "Mới nhất"
        case .oldest: return "Cũ nhất"
        case .mostFollowed: return "Theo dõi nhiều nhất"
        case .alphabetical: return "A-Z"
        }
    }
}
