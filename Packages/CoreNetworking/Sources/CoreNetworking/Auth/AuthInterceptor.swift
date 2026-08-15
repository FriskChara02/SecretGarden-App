//
//  AuthInterceptor.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// Coordinator actor: attaches the token to requests, automatically refreshes it upon receiving a 401 error, and ensures only one refresh operation occurs at a time.

import CoreArchitecture
import CoreStorage
import Foundation

public actor AuthInterceptor {

    private let keychain: KeychainManager
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    /// The refresh task currently in progress (if any) — multiple simultaneous 401 requests will SHARE this task
    /// instead of each request triggering its own refresh. This is a classic actor-based approach to handling race conditions.
    private var refreshTask: Task<String, Error>?

    public init(keychain: KeychainManager = .shared, baseURL: URL, session: URLSession = .shared) {
        self.keychain = keychain
        self.baseURL = baseURL
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    /// Used as the `accessTokenProvider` to be injected into the APIClient.
    public func currentAccessToken() async -> String? {
        await keychain.readAccessToken()
    }

    /// Called when APIClient receives a 401 response for a request for the first time. Returns a NEW Access Token if the refresh is successful.
    /// - Throws: `AppError.unauthorized` if the refresh fails (e.g., the refresh token has expired or been revoked)—at this point, the host app needs to listen for this event and navigate to the Login.
    public func refreshAccessToken() async throws -> String {
        // If a refresh is already in progress -> wait for its result; do NOT call the API a second time.
        if let existingTask = refreshTask {
            return try await existingTask.value
        }

        let task = Task<String, Error> {
            try await performRefresh()
        }
        refreshTask = task

        do {
            let newAccessToken = try await task.value
            refreshTask = nil
            return newAccessToken
        } catch {
            refreshTask = nil
            throw error
        }
    }

    // MARK: - Private

    private func performRefresh() async throws -> String {
        guard let refreshToken = await keychain.readRefreshToken() else {
            throw AppError.unauthorized
        }

        let endpoint = RefreshTokenEndpoint(refreshToken: refreshToken)
        var request: URLRequest
        do {
            request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)
        } catch {
            throw NetworkError.invalidURL.asAppError()
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.from(urlError: urlError).asAppError()
        } catch {
            throw NetworkError.unknown(underlying: error).asAppError()
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // The refresh token is no longer valid either -> clear the Keychain and force a logout.
            try? await keychain.clearTokens()
            throw AppError.unauthorized
        }

        guard let decoded = try? decoder.decode(RefreshTokenResponse.self, from: data) else {
            try? await keychain.clearTokens()
            throw AppError.unauthorized
        }

        try await keychain.saveAccessToken(decoded.accessToken)
        try await keychain.saveRefreshToken(decoded.refreshToken)

        return decoded.accessToken
    }
}
