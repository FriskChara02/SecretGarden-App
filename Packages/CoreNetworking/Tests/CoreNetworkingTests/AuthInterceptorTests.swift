//
//  AuthInterceptorTests.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

import XCTest
import CoreArchitecture
import CoreStorage
@testable import CoreNetworking

final class AuthInterceptorTests: XCTestCase {

    private var keychain: KeychainManager!
    private var sut: AuthInterceptor!

    override func setUp() async throws {
        try await super.setUp()
        keychain = KeychainManager()
        try? await keychain.clearTokens()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: config)

        sut = AuthInterceptor(keychain: keychain, baseURL: URL(string: "https://api.test.com")!, session: session)
    }

    override func tearDown() async throws {
        try? await keychain.clearTokens()
        try await super.tearDown()
    }

    func test_refreshAccessToken_noRefreshTokenSaved_throwsUnauthorized() async {
        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Phải throw lỗi vì chưa có refresh token")
        } catch let error as AppError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Sai kiểu lỗi: \(error)")
        }
    }

    func test_refreshAccessToken_success_savesNewTokensAndReturnsAccessToken() async throws {
        try await keychain.saveRefreshToken("old-refresh")
        StubURLProtocol.stubStatusCode = 200
        StubURLProtocol.stubResponseData = #"{"access_token": "new-access", "refresh_token": "new-refresh"}"#.data(using: .utf8)

        let result = try await sut.refreshAccessToken()

        XCTAssertEqual(result, "new-access")
        let savedAccess = await keychain.readAccessToken()
        let savedRefresh = await keychain.readRefreshToken()
        XCTAssertEqual(savedAccess, "new-access")
        XCTAssertEqual(savedRefresh, "new-refresh")
    }

    func test_refreshAccessToken_serverRejects_clearsTokensAndThrowsUnauthorized() async throws {
        try await keychain.saveRefreshToken("expired-refresh")
        StubURLProtocol.stubStatusCode = 401
        StubURLProtocol.stubResponseData = Data()

        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Phải throw lỗi")
        } catch let error as AppError {
            XCTAssertEqual(error, .unauthorized)
        }

        let savedAccess = await keychain.readAccessToken()
        XCTAssertNil(savedAccess, "Token phải bị xoá sau khi refresh thất bại")
    }

    /// Most important test: multiple simultaneous refresh requests trigger the API call only once.
    func test_refreshAccessToken_multipleConcurrentCalls_onlyCallsAPIOnce() async throws {
        try await keychain.saveRefreshToken("old-refresh")
        StubURLProtocol.stubStatusCode = 200
        StubURLProtocol.stubResponseData = #"{"access_token": "new-access", "refresh_token": "new-refresh"}"#.data(using: .utf8)
        StubURLProtocol.callCount = 0 // need to add static var callCount to StubURLProtocol

        async let first = sut.refreshAccessToken()
        async let second = sut.refreshAccessToken()
        async let third = sut.refreshAccessToken()

        let results = try await [first, second, third]

        XCTAssertEqual(results, ["new-access", "new-access", "new-access"])
        XCTAssertEqual(StubURLProtocol.callCount, 1, "Chỉ được gọi API refresh đúng 1 lần dù có 3 request đồng thời")
    }
}
