//
//  AuthRepositoryDebugMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 21/9/26.
//

// Used for Debug/Staging environments when a real backend is unavailable—distinct from AuthRepositoryMock
// (which is strictly for Unit Tests and does not interact with the Keychain). This file accurately
// simulates the behavior of the actual AuthRepository: it immediately "succeeds" at login/register
// and stores a real token, enabling testing of the entire session flow (AppRootViewModel,
// MainTabView avatar, etc.) without requiring a server.

import CoreModels
import CoreStorage
import Foundation

public final class AuthRepositoryDebugMock: AuthRepositoryProtocol, @unchecked Sendable {

    private let keychainManager: KeychainManager

    public init(keychainManager: KeychainManager) {
        self.keychainManager = keychainManager
    }

    public func login(_ request: LoginRequest) async throws -> AuthResponse {
        let response = Self.makeResponse(email: request.email)
        try await saveTokens(from: response)
        return response
    }

    public func register(_ request: RegisterRequest) async throws -> AuthResponse {
        let response = Self.makeResponse(email: request.email, username: request.username)
        try await saveTokens(from: response)
        return response
    }

    public func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
        let response = Self.makeResponse(email: "debug.google@example.com")
        try await saveTokens(from: response)
        return response
    }

    public func forgotPassword(_ request: ForgotPasswordRequest) async throws {}
    public func resetPassword(_ request: ResetPasswordRequest) async throws {}
    public func changePassword(_ request: ChangePasswordRequest) async throws {}

    public func logout() async throws {
        try await keychainManager.clearTokens()
    }

    // MARK: - Private

    private func saveTokens(from response: AuthResponse) async throws {
        try await keychainManager.saveAccessToken(response.accessToken)
        try await keychainManager.saveRefreshToken(response.refreshToken)
    }

    private static func makeResponse(email: String, username: String = "Frisk(Chara)") -> AuthResponse {
        AuthResponse(
            accessToken: "debug-access-token",
            refreshToken: "debug-refresh-token",
            user: User(
                id: "debug-user-1",
                username: username,
                displayName: "FriskChara",
                email: email,
                authProvider: .email,
                joinedAt: Date()
            )
        )
    }
}
