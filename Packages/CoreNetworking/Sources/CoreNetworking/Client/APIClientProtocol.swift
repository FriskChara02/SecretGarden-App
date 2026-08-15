//
//  APIClientProtocol.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// Protocol that the Repository depends on (decoupled from a specific APIClient) -> easy to mock during testing.

import CoreArchitecture
import Foundation

public protocol APIClientProtocol: Sendable {
    /// Sends a request to the endpoint, decodes the response into type T.
    /// - Throws: Always throws an `AppError` (mapped from `NetworkError`), never throws raw URLError/DecodingError.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T

    /// Used for endpoints with no response body (e.g., DELETE returning 204 No Content).
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws
}
