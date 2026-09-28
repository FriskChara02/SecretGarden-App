//
//  AuthInterceptorTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreNetworking
import CoreStorage
import XCTest

final class AuthInterceptorTests: XCTestCase {

    private var keychain: KeychainManager!
    private var sut: AuthInterceptor!

    private let refreshJSON = Data(#"{"access_token":"new-access","refresh_token":"new-refresh"}"#.utf8)

    override func setUp() async throws {
        try await super.setUp()
        keychain = KeychainManager()
        try? await keychain.clearTokens()
        URLProtocolStub.reset()
        let baseURL = try XCTUnwrap(URL(string: "https://test.example.com"))
        sut = AuthInterceptor(keychain: keychain, baseURL: baseURL, session: URLProtocolStub.makeSession())
    }

    override func tearDown() async throws {
        try? await keychain.clearTokens()
        URLProtocolStub.reset()
        sut = nil
        keychain = nil
        try await super.tearDown()
    }

    private func seedTokens(access: String = "old-access", refresh: String = "old-refresh") async throws {
        try await keychain.saveAccessToken(access)
        try await keychain.saveRefreshToken(refresh)
    }

    // MARK: - currentAccessToken

    func test_currentAccessToken_returnsValueFromKeychain() async throws {
        try await seedTokens(access: "abc")

        let token = await sut.currentAccessToken()

        XCTAssertEqual(token, "abc")
    }

    // MARK: - Refresh: happy path

    func test_refresh_success_returnsNewAccessTokenAndPersistsBothTokens() async throws {
        try await seedTokens()
        let json = refreshJSON
        URLProtocolStub.setHandler { _ in .init(statusCode: 200, data: json) }

        let token = try await sut.refreshAccessToken()

        XCTAssertEqual(token, "new-access")
        let savedAccess = await keychain.readAccessToken()
        let savedRefresh = await keychain.readRefreshToken()
        XCTAssertEqual(savedAccess, "new-access")
        XCTAssertEqual(savedRefresh, "new-refresh")
        XCTAssertEqual(URLProtocolStub.requestCount, 1)
    }

    // MARK: - Refresh: failure paths

    func test_refresh_withoutRefreshToken_throwsUnauthorizedAndMakesNoRequest() async {
        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Expected AppError.unauthorized")
        } catch {
            XCTAssertEqual(error as? AppError, .unauthorized)
        }
        XCTAssertEqual(URLProtocolStub.requestCount, 0)
    }

    func test_refresh_whenServerRejects_throwsUnauthorizedAndClearsTokens() async throws {
        try await seedTokens()
        URLProtocolStub.setHandler { _ in .init(statusCode: 401) }

        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Expected AppError.unauthorized")
        } catch {
            XCTAssertEqual(error as? AppError, .unauthorized)
        }

        let access = await keychain.readAccessToken()
        let refresh = await keychain.readRefreshToken()
        XCTAssertNil(access)
        XCTAssertNil(refresh)
    }

    func test_refresh_whenResponseIsMalformed_throwsUnauthorizedAndClearsTokens() async throws {
        try await seedTokens()
        URLProtocolStub.setHandler { _ in .init(statusCode: 200, data: Data("not json".utf8)) }

        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Expected AppError.unauthorized")
        } catch {
            XCTAssertEqual(error as? AppError, .unauthorized)
        }

        let refresh = await keychain.readRefreshToken()
        XCTAssertNil(refresh)
    }

    func test_refresh_whenNetworkFails_throwsNetworkErrorAndKeepsTokens() async throws {
        try await seedTokens()
        URLProtocolStub.setHandler { _ in .init(error: URLError(.notConnectedToInternet)) }

        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Expected a network AppError")
        } catch {
            guard let appError = error as? AppError, case .network = appError else {
                return XCTFail("Expected AppError.network, got \(error)")
            }
        }

        // Do not delete the token when offline — the user remains logged in, simply retry once the connection is restored.
        let refresh = await keychain.readRefreshToken()
        XCTAssertEqual(refresh, "old-refresh")
    }

    // MARK: - Concurrency (the reason for refreshTask's existence)

    func test_concurrentRefreshes_shareSingleNetworkRequest() async throws {
        try await seedTokens()
        let json = refreshJSON
        // Delay for 0.3s to allow all 10 calls to "squeeze in" while the first request is still in flight.
        URLProtocolStub.setHandler { _ in .init(statusCode: 200, data: json, delay: 0.3) }
        let interceptor = try XCTUnwrap(sut)

        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<10 {
                group.addTask { try await interceptor.refreshAccessToken() }
            }
            var collected: [String] = []
            for try await token in group { collected.append(token) }
            return collected
        }

        XCTAssertEqual(tokens.count, 10)
        XCTAssertTrue(tokens.allSatisfy { $0 == "new-access" })
        XCTAssertEqual(URLProtocolStub.requestCount, 1, "10 lời gọi đồng thời chỉ được phép sinh 1 request refresh")
    }

    func test_refresh_afterFailure_canRetryAndSucceeds() async throws {
        let json = refreshJSON
        URLProtocolStub.setHandler { _ in
            URLProtocolStub.requestCount == 1 ? .init(statusCode: 500) : .init(statusCode: 200, data: json)
        }

        try await seedTokens()
        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("First refresh should fail")
        } catch {
            XCTAssertEqual(error as? AppError, .unauthorized)
        }

        // The token was deleted after the first failure -> reloaded it, then verified that refreshTask was cleaned up (no stale task stuck).
        try await seedTokens()
        let token = try await sut.refreshAccessToken()

        XCTAssertEqual(token, "new-access")
        XCTAssertEqual(URLProtocolStub.requestCount, 2)
    }
}
