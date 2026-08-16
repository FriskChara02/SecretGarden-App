//
//  AuthRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

// The mock allows configuring return values ​​or thrown errors — used for AuthViewModel unit tests.
// Defined as public in the main target (not the test target) so that AuthFeatureTests can import it.

import CoreModels

public final class AuthRepositoryMock: AuthRepositoryProtocol, @unchecked Sendable {

    // MARK: - Configurable results

    public var loginResult: Result<AuthResponse, Error> = .failure(MockError.notConfigured)
    public var registerResult: Result<AuthResponse, Error> = .failure(MockError.notConfigured)
    public var loginWithGoogleResult: Result<AuthResponse, Error> = .failure(MockError.notConfigured)
    public var forgotPasswordResult: Result<Void, Error> = .success(())
    public var resetPasswordResult: Result<Void, Error> = .success(())
    public var changePasswordResult: Result<Void, Error> = .success(())
    public var logoutResult: Result<Void, Error> = .success(())

    // MARK: - Call tracking (to assert in the test: "was this function called exactly once with the correct arguments")

    public private(set) var loginCallCount = 0
    public private(set) var lastLoginRequest: LoginRequest?
    public private(set) var registerCallCount = 0
    public private(set) var lastRegisterRequest: RegisterRequest?
    public private(set) var forgotPasswordCallCount = 0
    public private(set) var lastForgotPasswordRequest: ForgotPasswordRequest?

    public init() {}

    public func login(_ request: LoginRequest) async throws -> AuthResponse {
        loginCallCount += 1
        lastLoginRequest = request
        return try loginResult.get()
    }

    public func register(_ request: RegisterRequest) async throws -> AuthResponse {
        registerCallCount += 1
        lastRegisterRequest = request
        return try registerResult.get()
    }

    public func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
        try loginWithGoogleResult.get()
    }

    public func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        forgotPasswordCallCount += 1
        lastForgotPasswordRequest = request
        try forgotPasswordResult.get()
    }

    public func resetPassword(_ request: ResetPasswordRequest) async throws {
        try resetPasswordResult.get()
    }

    public func changePassword(_ request: ChangePasswordRequest) async throws {
        try changePasswordResult.get()
    }

    public func logout() async throws {
        try logoutResult.get()
    }
}

public enum MockError: Error {
    case notConfigured
}
