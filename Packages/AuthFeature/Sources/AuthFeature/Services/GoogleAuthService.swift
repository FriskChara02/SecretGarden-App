//
//  GoogleAuthService.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 18/8/26.
//

// Wrap ASWebAuthenticationSession (OpenID Connect Implicit Flow) — Do NOT read AppConfig directly;
// receive clientID/redirectURIScheme via init.

import AuthenticationServices
import CoreArchitecture
import Foundation
import UIKit

public protocol GoogleAuthServicing: Sendable {
    /// Launches Google Sign-In and returns an idToken upon successful user authentication.
    @MainActor
    func signIn() async throws -> String
}

@MainActor
public final class GoogleAuthService: NSObject, GoogleAuthServicing {

    private let clientID: String
    private let redirectURIScheme: String

    public init(clientID: String, redirectURIScheme: String) {
        self.clientID = clientID
        self.redirectURIScheme = redirectURIScheme
    }

    public func signIn() async throws -> String {
        guard let authURL = Self.buildAuthorizationURL(clientID: clientID, redirectScheme: redirectURIScheme) else {
            throw AppError.unknown("Không thể tạo URL xác thực Google.")
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: redirectURIScheme
            ) { callbackURL, error in
                if let error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: AppError.validation("Bạn đã huỷ đăng nhập Google."))
                    } else {
                        continuation.resume(throwing: AppError.unknown(error.localizedDescription))
                    }
                    return
                }
                guard let callbackURL, let idToken = Self.extractIDToken(from: callbackURL) else {
                    continuation.resume(throwing: AppError.decodingFailed)
                    return
                }
                continuation.resume(returning: idToken)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    private static func buildAuthorizationURL(clientID: String, redirectScheme: String) -> URL? {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: "\(redirectScheme):/callback"),
            URLQueryItem(name: "response_type", value: "id_token"),
            URLQueryItem(name: "scope", value: "openid email profile"),
            URLQueryItem(name: "nonce", value: UUID().uuidString)
        ]
        return components?.url
    }

    /// Google returns the id_token in the URL fragment ("#id_token=..."), not the query string -
    /// URLComponents.queryItems does NOT automatically parse the fragment, it must be extracted manually.
    private static func extractIDToken(from url: URL) -> String? {
        guard let fragment = url.fragment else { return nil }
        for pair in fragment.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2, parts[0] == "id_token" {
                return String(parts[1])
            }
        }
        return nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GoogleAuthService: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return ASPresentationAnchor()
        }
        return window
    }
}

// MARK: - Mock (test & preview — internal to the module, no need to make public as it is used only within AuthFeature)

final class GoogleAuthServiceMock: GoogleAuthServicing, @unchecked Sendable {
    var result: Result<String, Error> = .success("fake-id-token")
    func signIn() async throws -> String {
        try result.get()
    }
}
