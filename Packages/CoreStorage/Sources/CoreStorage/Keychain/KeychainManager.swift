//
//  KeychainManager.swift
//  CoreStorage
//
//  Created by Loi Nguyen on 15/8/26.
//

// Wraps the synchronous, C-style Keychain Services API into an actor for safe use with Swift Concurrency.
// This is the ONLY place in the entire app permitted to call SecItemAdd/SecItemCopyMatching/... directly.

import Foundation

public actor KeychainManager {

    public static let shared = KeychainManager()

    private let service = "com.tranvana.secretgarden"

    public init() {}

    // MARK: - Public API

    public func saveAccessToken(_ token: String) throws {
        try save(token, forKey: Key.accessToken)
    }

    public func saveRefreshToken(_ token: String) throws {
        try save(token, forKey: Key.refreshToken)
    }

    public func readAccessToken() -> String? {
        try? read(forKey: Key.accessToken)
    }

    public func readRefreshToken() -> String? {
        try? read(forKey: Key.refreshToken)
    }

    /// Delete both tokens — use upon logout or when a refresh fails completely.
    public func clearTokens() throws {
        try? delete(forKey: Key.accessToken)
        try? delete(forKey: Key.refreshToken)
    }

    // MARK: - Private — generic wrapper around Keychain Services

    private enum Key: String {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }

    private func save(_ value: String, forKey key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.unexpectedData
        }

        // Delete the existing item first (if present) to avoid the errSecDuplicateItem error when overwriting.
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            // .afterFirstUnlock: The token remains readable when the app runs in the background or restarts before the user unlocks the device for the first time after a reboot—suitable for story-reading apps (which do not require banking-grade security).
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    private func read(forKey key: Key) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.readFailed(status: status)
        }

        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }

        return value
    }

    private func delete(forKey key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}
