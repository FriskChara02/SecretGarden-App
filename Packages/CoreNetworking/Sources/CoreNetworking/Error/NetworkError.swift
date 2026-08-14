//
//  NetworkError.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

// INTERNAL error of the CoreNetworking layer — must not be exposed outside the package in its raw form.
// Conform to AppErrorConvertible (CoreArchitecture) to enforce translation into AppError
// before exposure — implementing a proper Error Translation Layer.

import CoreArchitecture
import Foundation

public enum NetworkError: Error, Sendable {
    /// No network connection (URLError.notConnectedToInternet, .networkConnectionLost...)
    case noConnection

    /// Request timed out (URLError.timedOut)
    case timeout

    /// Invalid URL when building the request (programming/configuration error, not a user error)
    case invalidURL

    /// Server returned a response that is not an HTTPURLResponse (rare occurrence)
    case invalidResponse

    /// Server returned an error with a specific status code, including the decoded ErrorResponse (if decoding succeeded)
    case serverError(statusCode: Int, errorResponse: ErrorResponse?)

    /// Failed to decode the JSON response into the expected model
    case decodingFailed(underlying: Error)

    /// Access Token expired AND refresh failed -> requires logout
    case unauthorized

    /// Other errors not covered by the cases above (unusual network issues, rare URLSession errors)
    case unknown(underlying: Error)
}

// MARK: - Initialize NetworkError from URLError (transport layer error)

extension NetworkError {
    /// Map URLError (thrown by URLSession upon network loss, timeout, ...) to the appropriate NetworkError.
    static func from(urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .noConnection
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        default:
            return .unknown(underlying: urlError)
        }
    }
}
