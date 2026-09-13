//
//  GroupRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreModels
import CoreArchitecture
import Foundation

public actor GroupRepositoryMock: GroupRepositoryProtocol {

    private var groups: [String: TranslationGroup]
    private let membersByGroupId: [String: [GroupMember]]

    public init() {
        let members: [GroupMember] = [
            GroupMember(
                id: "member-1",
                user: User(
                    id: "user-1", username: "YellowZDSh", email: "yellow@example.com",
                    joinedAt: Date(), isDarkMode: false, role: .translator
                ),
                role: "leader"
            ),
            GroupMember(
                id: "member-2",
                user: User(
                    id: "user-2", username: "Hành", email: "hanh@example.com",
                    joinedAt: Date(), isDarkMode: false, role: .translator
                ),
                role: "leader"
            )
        ]

        self.groups = [
            "group-1": TranslationGroup(
                id: "group-1",
                name: "Yune Projekt",
                avatarURL: URL(string: "https://picsum.photos/seed/group-1-avatar/200/200"),
                description: nil, // "No description yet"
                socialLinks: ["facebook": "https://facebook.com/yune.projekt"],
                followerCount: 290,
                members: members,
                isFollowedByMe: false,
                isNotifyEnabled: false
            )
        ]

        self.membersByGroupId = ["group-1": members]
    }

    public func fetchGroupDetail(id: String) async throws -> TranslationGroup {
        guard let group = groups[id] else { throw AppError.notFound }
        return group
    }

    public func fetchGroupSeries(groupId: String, page: Int) async throws -> [Series] {
        [] // TODO: Add a real mock Series when implementing GroupProfileView
    }

    public func fetchGroupMembers(groupId: String) async throws -> [GroupMember] {
        membersByGroupId[groupId] ?? []
    }

    public func fetchGroupHighlights(
        groupId: String,
        sortBy: RankingSortBy,
        range: RankingRange
    ) async throws -> [Series] {
        [] // TODO: Add a real mock Series when writing the "Group Highlights" section.
    }

    public func toggleFollow(groupId: String, isFollowing: Bool) async throws {
        groups[groupId]?.isFollowedByMe = isFollowing
        if !isFollowing {
            groups[groupId]?.isNotifyEnabled = false
        }
    }

    public func toggleNotify(groupId: String, enabled: Bool) async throws {
        groups[groupId]?.isNotifyEnabled = enabled
    }

    public func discoverGroups(query: String, sort: GroupDiscoverSort, page: Int) async throws -> [TranslationGroup] {
        let allGroups = Array(groups.values)
        guard !query.isEmpty else { return allGroups }
        return allGroups.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    public func fetchFollowedGroups() async throws -> [TranslationGroup] {
        groups.values.filter { $0.isFollowedByMe }
    }
}
