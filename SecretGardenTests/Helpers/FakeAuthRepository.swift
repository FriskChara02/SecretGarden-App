//
//  FakeAuthRepository.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import AuthFeature
import CoreModels
import Foundation
import Repositories

enum TestFixtures {
    static func authResponse() -> AuthResponse {
        AuthResponse(
            accessToken: "srv-access",
            refreshToken: "srv-refresh",
            user: User(
                id: "u1",
                username: "frisk",
                displayName: "Frisk",
                email: "frisk@example.com",
                authProvider: .email,
                joinedAt: Date()
            )
        )
    }
}

/// Mock repository: records received requests and either succeeds or throws a predefined error.
actor FakeAuthRepository: AuthRepositoryProtocol {

    private let response: AuthResponse
    private let failure: Error?

    private(set) var loginRequests: [LoginRequest] = []
    private(set) var registerRequests: [RegisterRequest] = []
    private(set) var googleRequests: [GoogleLoginRequest] = []
    private(set) var forgotPasswordRequests: [ForgotPasswordRequest] = []

    init(response: AuthResponse = TestFixtures.authResponse(), failure: Error? = nil) {
        self.response = response
        self.failure = failure
    }

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        loginRequests.append(request)
        if let failure { throw failure }
        return response
    }

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        registerRequests.append(request)
        if let failure { throw failure }
        return response
    }

    func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
        googleRequests.append(request)
        if let failure { throw failure }
        return response
    }

    func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        forgotPasswordRequests.append(request)
        if let failure { throw failure }
    }

    func resetPassword(_ request: ResetPasswordRequest) async throws {
        if let failure { throw failure }
    }

    func changePassword(_ request: ChangePasswordRequest) async throws {
        if let failure { throw failure }
    }

    func logout() async throws {}
}

/// Mock Google service: returns a predefined idToken or a predefined error.
final class FakeGoogleAuthService: GoogleAuthServicing, @unchecked Sendable {
    var result: Result<String, Error> = .success("fake-id-token")

    @MainActor
    func signIn() async throws -> String {
        try result.get()
    }
}
