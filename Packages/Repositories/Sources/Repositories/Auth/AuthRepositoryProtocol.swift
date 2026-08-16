//
//  AuthRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

// Contract for all authentication-related behavior.
// AuthFeature (and any other feature requiring login status) must only
// depend on this protocol, never directly on AuthRepository (the implementation).

import CoreModels

public protocol AuthRepositoryProtocol: Sendable {

    /// POST /auth/login
    func login(_ request: LoginRequest) async throws -> AuthResponse

    /// POST /auth/register
    func register(_ request: RegisterRequest) async throws -> AuthResponse

    /// POST /auth/login/google
    func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse

    /// POST /auth/forgot-password
    func forgotPassword(_ request: ForgotPasswordRequest) async throws

    /// POST /auth/reset-password
    func resetPassword(_ request: ResetPasswordRequest) async throws

    /// POST /auth/change-password (login required)
    func changePassword(_ request: ChangePasswordRequest) async throws

    /// POST /auth/logout
    func logout() async throws
}
