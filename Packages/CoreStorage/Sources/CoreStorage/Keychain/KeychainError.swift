//
//  KeychainError.swift
//  CoreStorage
//
//  Created by Loi Nguyen on 15/8/26.
//

// CoreStorage INTERNAL error — conform to AppErrorConvertible like NetworkError,
// ensuring CoreStorage also adheres to the Error Translation Layer, just like CoreNetworking.

import CoreArchitecture
import Foundation

public enum KeychainError: Error, Sendable {
    case itemNotFound
    case saveFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case unexpectedData
}

extension KeychainError: AppErrorConvertible {
    public func asAppError() -> AppError {
        switch self {
        case .itemNotFound:
            return .storage(.notFound)
        case .saveFailed:
            return .storage(.saveFailed)
        case .deleteFailed:
            return .storage(.deleteFailed)
        case .readFailed, .unexpectedData:
            return .storage(.other("Không đọc được dữ liệu đã lưu."))
        }
    }
}
