//
//  AppErrorConvertible.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 9/8/26.
//

// Error Translation Layer — any error type specific to a low-level layer
// (e.g., CoreNetworking will eventually have `NetworkClientError`, CoreStorage will have
// `KeychainError`, etc.) MUST conform to this protocol to be "translated" into `AppError`

import Foundation

/// Any low-level error type (Network, Storage, etc.) that needs to 'surface'
/// as an AppError must implement this protocol
public protocol AppErrorConvertible: Error {
    /// Convert specific low-level errors into a unified AppError
    func asAppError() -> AppError
}
