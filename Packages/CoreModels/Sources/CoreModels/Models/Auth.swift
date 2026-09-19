//
//  Auth.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Request/Response model for the Auth group

import Foundation

public struct LoginRequest: Codable, Equatable, Sendable {
    public var email: String
    public var password: String
    public var rememberMe: Bool

    public init(email: String, password: String, rememberMe: Bool = false) {
        self.email = email
        self.password = password
        self.rememberMe = rememberMe
    }
}

public struct RegisterRequest: Codable, Equatable, Sendable {
    public var username: String
    public var email: String
    public var password: String
    public var confirmPassword: String

    public init(username: String, email: String, password: String, confirmPassword: String) {
        self.username = username
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }
}

// MARK: - Profile Update

public struct UpdateProfileRequest: Codable, Sendable {
    public var displayName: String?
    public var bio: String?
    public var birthday: Date?
    public var gender: String?
    public var address: String?
    public var interests: String?
    public var socialLinks: [String: String]?

    public init(
        displayName: String? = nil,
        bio: String? = nil,
        birthday: Date? = nil,
        gender: String? = nil,
        address: String? = nil,
        interests: String? = nil,
        socialLinks: [String: String]? = nil
    ) {
        self.displayName = displayName
        self.bio = bio
        self.birthday = birthday
        self.gender = gender
        self.address = address
        self.interests = interests
        self.socialLinks = socialLinks
    }
}

public struct UpdateAccountRequest: Codable, Sendable {
    public var username: String
    public var email: String

    public init(username: String, email: String) {
        self.username = username
        self.email = email
    }
}

public struct ForgotPasswordRequest: Codable, Equatable, Sendable {
    public var email: String

    public init(email: String) {
        self.email = email
    }
}

public struct ResetPasswordRequest: Codable, Equatable, Sendable {
    public var token: String
    public var newPassword: String

    public init(token: String, newPassword: String) {
        self.token = token
        self.newPassword = newPassword
    }
}

public struct AuthResponse: Codable, Equatable, Sendable {
    public var accessToken: String
    public var refreshToken: String
    public var user: User

    public init(accessToken: String, refreshToken: String, user: User) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}

// MARK: - Change Password (Account Settings)

public struct ChangePasswordRequest: Codable, Equatable, Sendable {
    public var oldPassword: String
    public var newPassword: String

    public init(oldPassword: String, newPassword: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
}

// MARK: - Google OAuth

public struct GoogleLoginRequest: Codable, Equatable, Sendable {
    /// ID Token received from ASWebAuthenticationSession after the user authenticates with Google.
    public var idToken: String

    public init(idToken: String) {
        self.idToken = idToken
    }
}
