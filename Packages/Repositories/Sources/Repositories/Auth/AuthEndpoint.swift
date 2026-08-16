//
//  AuthEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

// Endpoint dedicated to AuthRepository — following the convention established in SeriesEndpoint.swift:
// Placed in the Repositories package (not CoreNetworking) because this is a business-specific detail
// of the Auth domain, CoreNetworking only needs to know "what an APIEndpoint is," not
// how many business domains the app has.

import CoreNetworking
import CoreModels
import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(LoginRequest)
    case register(RegisterRequest)
    case loginWithGoogle(GoogleLoginRequest)
    case forgotPassword(ForgotPasswordRequest)
    case resetPassword(ResetPasswordRequest)
    case changePassword(ChangePasswordRequest)
    case logout

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .loginWithGoogle:
            return "/auth/login/google"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .resetPassword:
            return "/auth/reset-password"
        case .changePassword:
            return "/auth/change-password"
        case .logout:
            return "/auth/logout"
        }
    }

    // All endpoints in the Auth group are POST requests — no switch statement needed.
    var method: HTTPMethod { .post }

    var body: Data? {
        switch self {
        case .login(let request):
            return Self.encode(request)
        case .register(let request):
            return Self.encode(request)
        case .loginWithGoogle(let request):
            return Self.encode(request)
        case .forgotPassword(let request):
            return Self.encode(request)
        case .resetPassword(let request):
            return Self.encode(request)
        case .changePassword(let request):
            return Self.encode(request)
        case .logout:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .register, .loginWithGoogle, .forgotPassword, .resetPassword:
            // Public — the user does not yet have a token at these stages, truly reflecting the "not logged in" state.
            return false
        case .changePassword, .logout:
            // Requires authentication (changing a password requires knowing whose password is being changed; logging out requires a token so the server can revoke the correct session)
            return true
        }
    }

    // MARK: - Private

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    /// Encode a Codable request into Data.
    /// Use `try!` intentionally: LoginRequest/RegisterRequest/... are simple Codable structs.
    /// (String, Bool) — encode fail here means a programming error (not a runtime/network error).
    /// It's better to "crash early and loudly" when debugging/testing than to silently send an empty body to the server.
    /// (similar to the fatalError philosophy used in AppConfig.swift).
    private static func encode<T: Encodable>(_ value: T) -> Data {
        try! encoder.encode(value)
    }
}
