//
//  AuthRepositoryStub.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

import CoreArchitecture
import CoreModels

public final class AuthRepositoryStub: AuthRepositoryProtocol {

    public init() {}

    public func login(_ request: LoginRequest) async throws -> AuthResponse {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func register(_ request: RegisterRequest) async throws -> AuthResponse {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        throw AppError.unknown("AuthRepository chưa me được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func resetPassword(_ request: ResetPasswordRequest) async throws {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func changePassword(_ request: ChangePasswordRequest) async throws {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }

    public func logout() async throws {
        throw AppError.unknown("AuthRepository chưa được implement — xem TODO(Phase 6 Step 6.2)")
    }
}
