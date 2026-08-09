//
//  AppError.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 9/8/26.
//

// A unified error type used consistently throughout the entire app
//
// Mandatory rules from this step onwards:
// - Repositories, ViewModels, and Views MUST NEVER handle URLError, DecodingError or NSError (CoreData/Keychain) directly; they only deal with AppError
// - Any error originating in lower layers (CoreNetworking, CoreStorage) MUST be "translated" (mapped) to AppError before propagating up to the ViewModel — see AppErrorConvertible.swift
//
// Design note: AppError does not store the `Error` protocol type directly as an associated value; instead, it stores the original description string (underlyingDescription)
// Reason: The `Error` protocol is not automatically `Equatable`. Storing it directly would prevent AppError from conforming to `Equatable`, making Unit Testing difficult (asserting equality between expected and actual errors). Trade-off: partial loss of original error details (specific stack trace/type), but significantly better testability — this is a deliberate design choice, not an oversight.

import Foundation

/// Unified error type for the entire app
public enum AppError: Error, Equatable {
    /// Network or API-related error
    case network(NetworkErrorReason)

    /// Local storage-related error (Keychain, SwiftData/CoreData)
    case storage(StorageErrorReason)

    /// Input validation error (e.g., invalid email format in a sign-up form)
    /// The associated value is a message ready for direct display to the user
    case validation(String)

    /// User is not logged in, or the token has expired/been revoked
    case unauthorized

    /// Resource not found (e.g., a series has been deleted)
    case notFound

    /// Data (JSON) decoding failure - usually due to a backend contract change not yet reflected in the app
    case decodingFailed

    /// Unknown or unclassified error. The associated value is the original description,
    /// intended for debug logging; do NOT display it directly to the user
    case unknown(String)
}

/// Details of the network error
public enum NetworkErrorReason: Equatable {
    case noInternetConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case other(String)
}

/// Details regarding the local storage error
public enum StorageErrorReason: Equatable {
    case notFound
    case saveFailed
    case deleteFailed
    case other(String)
}

// MARK: - LocalizedError (Message displayed to the user)

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let reason):
            return reason.localizedMessage
        case .storage(let reason):
            return reason.localizedMessage
        case .validation(let message):
            return message
        case .unauthorized:
            return "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
        case .notFound:
            return "Không tìm thấy nội dung bạn yêu cầu."
        case .decodingFailed:
            return "Có lỗi xảy ra khi xử lý dữ liệu. Vui lòng thử lại sau."
        case .unknown:
            return "Đã có lỗi không xác định xảy ra. Vui lòng thử lại."
        }
    }
}

extension NetworkErrorReason {
    var localizedMessage: String {
        switch self {
        case .noInternetConnection:
            return "Không có kết nối mạng. Vui lòng kiểm tra lại Wi-Fi/4G."
        case .timeout:
            return "Kết nối quá thời gian chờ. Vui lòng thử lại."
        case .serverError(let statusCode):
            return "Máy chủ gặp sự cố (mã lỗi \(statusCode)). Vui lòng thử lại sau."
        case .invalidResponse:
            return "Phản hồi từ máy chủ không hợp lệ."
        case .other(let message):
            return message
        }
    }
}

extension StorageErrorReason {
    var localizedMessage: String {
        switch self {
        case .notFound:
            return "Không tìm thấy dữ liệu đã lưu."
        case .saveFailed:
            return "Không thể lưu dữ liệu. Vui lòng thử lại."
        case .deleteFailed:
            return "Không thể xoá dữ liệu. Vui lòng thử lại."
        case .other(let message):
            return message
        }
    }
}
