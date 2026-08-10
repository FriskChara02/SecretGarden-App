//
//  Auth.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Request/Response model for the Auth group

import Foundation

public struct LoginRequest: Codable, Equatable {
    public var email: String
    public var password: String
    public var rememberMe: Bool

    public init(email: String, password: String, rememberMe: Bool = false) {
        self.email = email
        self.password = password
        self.rememberMe = rememberMe
    }
}

public struct RegisterRequest: Codable, Equatable {
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

public struct ForgotPasswordRequest: Codable, Equatable {
    public var email: String

    public init(email: String) {
        self.email = email
    }
}

public struct ResetPasswordRequest: Codable, Equatable {
    public var token: String
    public var newPassword: String

    public init(token: String, newPassword: String) {
        self.token = token
        self.newPassword = newPassword
    }
}

public struct AuthResponse: Codable, Equatable {
    public var accessToken: String
    public var refreshToken: String
    public var user: User

    public init(accessToken: String, refreshToken: String, user: User) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}
