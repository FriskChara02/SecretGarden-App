//
//  User.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for USERS

import Foundation

public struct User: Codable, Identifiable, Equatable {
    public let id: String
    public var username: String
    public var email: String
    public var avatarURL: URL?
    public var bannerURL: URL?
    public var bio: String?
    public var birthday: Date?
    public var gender: String?
    public var address: String?
    public var interests: String?
    public var joinedAt: Date
    public var isDarkMode: Bool
    public var socialLinks: [String: String]?
    public var role: UserRole

    public init(
        id: String,
        username: String,
        email: String,
        avatarURL: URL? = nil,
        bannerURL: URL? = nil,
        bio: String? = nil,
        birthday: Date? = nil,
        gender: String? = nil,
        address: String? = nil,
        interests: String? = nil,
        joinedAt: Date,
        isDarkMode: Bool = false,
        socialLinks: [String: String]? = nil,
        role: UserRole = .user
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.avatarURL = avatarURL
        self.bannerURL = bannerURL
        self.bio = bio
        self.birthday = birthday
        self.gender = gender
        self.address = address
        self.interests = interests
        self.joinedAt = joinedAt
        self.isDarkMode = isDarkMode
        self.socialLinks = socialLinks
        self.role = role
    }
}

public enum UserRole: String, Codable {
    case user, translator, admin
}
