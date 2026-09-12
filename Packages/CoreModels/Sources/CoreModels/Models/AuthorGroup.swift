//
//  AuthorGroup.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for AUTHORS, GROUPS, GROUP_MEMBERS

import Foundation

public struct AuthorGroupCommon: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var avatarURL: URL?
    public var socialLink: String?
    public var bio: String?
    public var isFollowedByMe: Bool
    public var isNotifyEnabled: Bool

    public init(
        id: String,
        name: String,
        avatarURL: URL? = nil,
        socialLink: String? = nil,
        bio: String? = nil,
        isFollowedByMe: Bool = false,
        isNotifyEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.socialLink = socialLink
        self.bio = bio
        self.isFollowedByMe = isFollowedByMe
        self.isNotifyEnabled = isNotifyEnabled
    }
}

public struct TranslationGroup: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var avatarURL: URL?
    public var description: String?
    public var socialLinks: [String: String]?
    public var followerCount: Int
    public var members: [GroupMember]?
    public var isFollowedByMe: Bool
    public var isNotifyEnabled: Bool

    public init(
        id: String,
        name: String,
        avatarURL: URL? = nil,
        description: String? = nil,
        socialLinks: [String: String]? = nil,
        followerCount: Int = 0,
        members: [GroupMember]? = nil,
        isFollowedByMe: Bool = false,
        isNotifyEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.description = description
        self.socialLinks = socialLinks
        self.followerCount = followerCount
        self.members = members
        self.isFollowedByMe = isFollowedByMe
        self.isNotifyEnabled = isNotifyEnabled
    }
}

public struct GroupMember: Codable, Identifiable, Equatable {
    public let id: String
    public var user: User
    /// "leader" / "admin" / "member"
    public var role: String

    public init(id: String, user: User, role: String) {
        self.id = id
        self.user = user
        self.role = role
    }
}
