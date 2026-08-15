//
//  APIClient.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// The actual implementation — the *only* place in the entire app that calls URLSession directly.

import CoreArchitecture
import Foundation

public final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    /// Current Access Token provider — to be properly implemented in (AuthInterceptor).
    /// Temporarily accepts a closure to avoid blocking and the need to rewrite APIClient.
    private let accessTokenProvider: @Sendable () async -> String?
    /// If nil, the APIClient does not automatically retry on a 401 response (used for public/test endpoints).
    private let authInterceptor: AuthInterceptor?

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        accessTokenProvider: @escaping @Sendable () async -> String? = { nil },
        authInterceptor: AuthInterceptor? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.accessTokenProvider = accessTokenProvider
        self.authInterceptor = authInterceptor

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await performRequest(endpoint, isRetry: false)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error).asAppError()
        }
    }

    public func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        _ = try await performRequest(endpoint, isRetry: false)
    }

    // MARK: - Private

    private func performRequest(_ endpoint: APIEndpoint, isRetry: Bool = false) async throws -> Data {
        var request: URLRequest
        do {
            request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)
        } catch {
            throw NetworkError.invalidURL.asAppError()
        }

        // Attach Access Token if the endpoint requires it (endpoint.requiresAuth defaults to true)
        if endpoint.requiresAuth, let token = await accessTokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse.asAppError()
        }
        
        // Handle 401 specifically: if an AuthInterceptor is present and this is the first attempt (no retry yet), try refreshing the token and retrying exactly once.
        if httpResponse.statusCode == 401, let interceptor = authInterceptor, endpoint.requiresAuth, !isRetry {
            _ = try await interceptor.refreshAccessToken() // Throw AppError.unauthorized if refresh fails -> stop immediately, do not retry.
            return try await performRequest(endpoint, isRetry: true) // retry exactly once with the new token
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, errorResponse: errorResponse).asAppError()
        }

        return data
    }
}
