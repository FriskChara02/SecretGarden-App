//
//  AuthRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

import CoreModels
import CoreNetworking
import CoreStorage

public final class AuthRepository: AuthRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let keychainManager: KeychainManager

    public init(apiClient: APIClientProtocol, keychainManager: KeychainManager) {
        self.apiClient = apiClient
        self.keychainManager = keychainManager
    }

    public func login(_ request: LoginRequest) async throws -> AuthResponse {
        let response: AuthResponse = try await apiClient.request(AuthEndpoint.login(request))
        try await saveTokens(from: response)
        return response
    }

    public func register(_ request: RegisterRequest) async throws -> AuthResponse {
        let response: AuthResponse = try await apiClient.request(AuthEndpoint.register(request))
        try await saveTokens(from: response)
        return response
    }

    public func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
        let response: AuthResponse = try await apiClient.request(AuthEndpoint.loginWithGoogle(request))
        try await saveTokens(from: response)
        return response
    }

    public func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        try await apiClient.requestWithoutResponse(AuthEndpoint.forgotPassword(request))
    }

    public func resetPassword(_ request: ResetPasswordRequest) async throws {
        try await apiClient.requestWithoutResponse(AuthEndpoint.resetPassword(request))
    }

    public func changePassword(_ request: ChangePasswordRequest) async throws {
        try await apiClient.requestWithoutResponse(AuthEndpoint.changePassword(request))
    }

    /// An intentional exception within the Repository layer: this is the ONLY method that uses a do-catch block
    /// instead of the standard "single-line try-await" pattern used by other Repository methods.
    /// Reason: Even if the server logout fails (e.g., due to network loss or an expired token), the user's session
    /// must still be terminated IMMEDIATELY on the device when they tap "Log Out"—a network error cannot be allowed to block this action.
    /// `try?` here is intended to swallow the error from the server call, not a case of overlooking error handling.
    public func logout() async throws {
        try? await apiClient.requestWithoutResponse(AuthEndpoint.logout)
        try await keychainManager.clearTokens()
    }

    // MARK: - Private

    private func saveTokens(from response: AuthResponse) async throws {
        try await keychainManager.saveAccessToken(response.accessToken)
        try await keychainManager.saveRefreshToken(response.refreshToken)
    }
}
