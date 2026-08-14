//
//  APIEndpoint.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

// This protocol represents an "API call" — each Feature will have its own enum conforming to this protocol.

import Foundation

public protocol APIEndpoint: Sendable {
    /// Relative path, excluding the base URL. Example: "/auth/login"
    var path: String { get }

    var method: HTTPMethod { get }

    /// Query parameters, used for GET requests (e.g., ?page=1&q=keyword). nil if none.
    var queryItems: [URLQueryItem]? { get }

    /// Request body, pre-encoded as Data. nil if none (e.g., GET/DELETE requests typically lack a body).
    var body: Data? { get }

    /// Additional headers specific to this endpoint (e.g., a specific Content-Type).
    /// Common headers (Authorization, Accept, etc.) are handled by the AuthInterceptor and should not be declared here.
    var headers: [String: String]? { get }

    /// true if this endpoint requires an attached Access Token (e.g., most /users/me/... endpoints).
    /// false for public endpoints (e.g., /auth/login, /home/latest-updates).
    var requiresAuth: Bool { get }
}

// MARK: - Default implementation covers common cases, features only need to override when different behavior is required.

public extension APIEndpoint {
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var headers: [String: String]? { nil }
    var requiresAuth: Bool { true } // Authentication is required by default—prioritizing security (secure by default)-meaning features must explicitly declare `false` for public access.
}

// MARK: - Helper build URLRequest from APIEndpoint + base URL

public enum APIEndpointBuilder {

    /// Constructs a complete URLRequest from an APIEndpoint and a base URL.
    /// - Throws: `URLError(.badURL)` if the path or query is invalid.
    public static func buildRequest(for endpoint: APIEndpoint, baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Default header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Endpoint-specific headers (if any, override defaults)
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
