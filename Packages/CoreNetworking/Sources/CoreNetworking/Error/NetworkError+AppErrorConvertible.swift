//
//  NetworkError+AppErrorConvertible.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

// The ONLY place where NetworkError (network-layer technical details) is converted to AppError.
// APIClient will always catch NetworkError and call .asAppError() before re-throwing it to the Repository.

import CoreArchitecture
import Foundation

extension NetworkError: AppErrorConvertible {

    public func asAppError() -> AppError {
        switch self {
        case .noConnection:
            return .network(.noInternetConnection)

        case .timeout:
            return .network(.timeout)

        case .invalidURL:
            // Programming/config error (incorrect endpoint), not caused by the user.
            // Use .unknown to avoid misidentifying it as a standard network error,
            // while retaining the description for debugging/logging purposes.
            return .unknown("Invalid URL khi build request")

        case .invalidResponse:
            return .network(.invalidResponse)

        case .serverError(let statusCode, let errorResponse):
            // Prioritize handling 401 as .unauthorized, even if it passes through the serverError branch
            // (in case AuthInterceptor hasn't caught it yet).
            if statusCode == 401 {
                return .unauthorized
            }
            // If there is a message from the server (already localized per design) -> pass it through as-is via .other.
            // If there is no message -> use the default localizedMessage based on the statusCode (already available in AppError).
            if let serverMessage = errorResponse?.message {
                return .network(.other(serverMessage))
            }
            return .network(.serverError(statusCode: statusCode))

        case .decodingFailed:
            // It is always a programming error or an API contract mismatch (the backend changed a field but the app hasn't updated yet),
            // do NOT display technical details (field names, data types) to the user.
            return .decodingFailed

        case .unauthorized:
            return .unauthorized

        case .unknown(let underlying):
            return .unknown(underlying.localizedDescription)
        }
    }
}
