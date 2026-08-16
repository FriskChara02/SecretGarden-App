//
//  AuthRepositoryTests.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

import XCTest
@testable import Repositories
import CoreModels
import CoreNetworking
import CoreStorage
import CoreArchitecture

final class AuthRepositoryTests: XCTestCase {

    func test_login_success_savesTokensToKeychain() async throws {
        // Given
        let fakeResponse = AuthResponse(
            accessToken: "fake_access",
            refreshToken: "fake_refresh",
            user: User(id: "u1", username: "test", email: "test@example.com", joinedAt: Date())
        )
        let apiClient = FakeAPIClient(resultToReturn: fakeResponse)
        let keychain = KeychainManager() // Same service name -> shares the actual Keychain of the test target
        let sut = AuthRepository(apiClient: apiClient, keychainManager: keychain)

        // When
        let response = try await sut.login(LoginRequest(email: "test@example.com", password: "123456"))

        // Then
        XCTAssertEqual(response.accessToken, "fake_access")
        let savedToken = await keychain.readAccessToken()
        XCTAssertEqual(savedToken, "fake_access")

        // Cleanup
        try await keychain.clearTokens()
    }

    func test_logout_clearsTokens_evenWhenServerCallFails() async throws {
        // Given
        let keychain = KeychainManager()
        try await keychain.saveAccessToken("existing_token")
        let apiClient = FakeAPIClient(shouldThrow: true)
        let sut = AuthRepository(apiClient: apiClient, keychainManager: keychain)

        // When
        try await sut.logout() // Must not throw, even if apiClient throws.

        // Then
        let token = await keychain.readAccessToken()
        XCTAssertNil(token)
    }
}

// MARK: - Fake APIClient (simpler than StubURLProtocol, since AuthRepository only needs to return or throw)

private final class FakeAPIClient: APIClientProtocol, @unchecked Sendable {
    var resultToReturn: Any?
    var shouldThrow = false

    init(resultToReturn: Any? = nil, shouldThrow: Bool = false) {
        self.resultToReturn = resultToReturn
        self.shouldThrow = shouldThrow
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldThrow { throw AppError.unknown("fake error") }
        guard let result = resultToReturn as? T else {
            fatalError("FakeAPIClient chưa được cấu hình đúng kiểu trả về")
        }
        return result
    }

    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        if shouldThrow { throw AppError.unknown("fake error") }
    }
}
