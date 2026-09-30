//
//  APIClientTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreNetworking
import CoreStorage
import XCTest

final class APIClientTests: XCTestCase {

    private struct Item: Decodable, Equatable {
        let id: Int
        let createdAt: Date
        let displayName: String
    }

    private var keychain: KeychainManager!
    private var baseURL: URL!

    private let itemJSON = Data(#"{"id":1,"created_at":"2026-09-28T10:00:00Z","display_name":"Frisk"}"#.utf8)
    private let refreshJSON = Data(#"{"access_token":"new-access","refresh_token":"new-refresh"}"#.utf8)

    override func setUp() async throws {
        try await super.setUp()
        keychain = KeychainManager()
        try? await keychain.clearTokens()
        URLProtocolStub.reset()
        baseURL = try XCTUnwrap(URL(string: "https://test.example.com"))
    }

    override func tearDown() async throws {
        try? await keychain.clearTokens()
        URLProtocolStub.reset()
        keychain = nil
        baseURL = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeClient(withInterceptor: Bool = false) -> APIClient {
        let session = URLProtocolStub.makeSession()
        let keychain = self.keychain!
        let interceptor = withInterceptor
            ? AuthInterceptor(keychain: keychain, baseURL: baseURL, session: session)
            : nil
        return APIClient(
            baseURL: baseURL,
            session: session,
            accessTokenProvider: { await keychain.readAccessToken() },
            authInterceptor: interceptor
        )
    }

    private func assertThrows(
        _ expected: AppError,
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected) but no error was thrown", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? AppError, expected, file: file, line: line)
        }
    }

    // MARK: - Decode

    func test_request_success_decodesSnakeCaseKeysAndISO8601Dates() async throws {
        let json = itemJSON
        URLProtocolStub.setHandler { _ in .init(statusCode: 200, data: json) }

        let item: Item = try await makeClient().request(StubEndpoint(requiresAuth: false))

        let expectedDate = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-09-28T10:00:00Z"))
        XCTAssertEqual(item, Item(id: 1, createdAt: expectedDate, displayName: "Frisk"))
    }

    func test_requestWithoutResponse_successWithEmptyBody_doesNotThrow() async throws {
        URLProtocolStub.setHandler { _ in .init(statusCode: 204) }

        try await makeClient().requestWithoutResponse(StubEndpoint(requiresAuth: false))
    }

    func test_request_malformedJSONOn200_throwsDecodingFailed() async {
        URLProtocolStub.setHandler { _ in .init(statusCode: 200, data: Data("not json".utf8)) }
        let client = makeClient()

        await assertThrows(.decodingFailed) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
    }

    // MARK: - Authorization header

    func test_request_whenRequiresAuth_attachesBearerToken() async throws {
        try await keychain.saveAccessToken("abc")
        let json = itemJSON
        URLProtocolStub.setHandler { request in
            request.value(forHTTPHeaderField: "Authorization") == "Bearer abc"
                ? .init(statusCode: 200, data: json)
                : .init(statusCode: 401)
        }

        let item: Item = try await makeClient().request(StubEndpoint())

        XCTAssertEqual(item.id, 1)
    }

    func test_request_whenNotRequiresAuth_doesNotAttachAuthorization() async throws {
        try await keychain.saveAccessToken("abc")
        let json = itemJSON
        URLProtocolStub.setHandler { request in
            request.value(forHTTPHeaderField: "Authorization") == nil
                ? .init(statusCode: 200, data: json)
                : .init(statusCode: 400)
        }

        let item: Item = try await makeClient().request(StubEndpoint(requiresAuth: false))

        XCTAssertEqual(item.id, 1)
    }

    // MARK: - Error mapping

    func test_request_serverErrorWithMessage_throwsNetworkOtherWithServerMessage() async {
        let body = Data(#"{"message":"Email already exists","code":"EMAIL_TAKEN"}"#.utf8)
        URLProtocolStub.setHandler { _ in .init(statusCode: 409, data: body) }
        let client = makeClient()

        await assertThrows(.network(.other("Email already exists"))) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
    }

    func test_request_serverErrorWithoutBody_throwsServerErrorWithStatusCode() async {
        URLProtocolStub.setHandler { _ in .init(statusCode: 500) }
        let client = makeClient()

        await assertThrows(.network(.serverError(statusCode: 500))) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
    }

    func test_request_noInternet_throwsNoInternetConnection() async {
        URLProtocolStub.setHandler { _ in .init(error: URLError(.notConnectedToInternet)) }
        let client = makeClient()

        await assertThrows(.network(.noInternetConnection)) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
    }

    func test_request_timeout_throwsTimeout() async {
        URLProtocolStub.setHandler { _ in .init(error: URLError(.timedOut)) }
        let client = makeClient()

        await assertThrows(.network(.timeout)) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
    }

    func test_request_401WithoutInterceptor_throwsUnauthorized() async {
        URLProtocolStub.setHandler { _ in .init(statusCode: 401) }
        let client = makeClient(withInterceptor: false)

        await assertThrows(.unauthorized) {
            let _: Item = try await client.request(StubEndpoint())
        }
        XCTAssertEqual(URLProtocolStub.requestCount, 1)
    }

    // MARK: - 401 -> refresh -> retry

    func test_request_on401_refreshesAndRetriesOnceWithNewToken() async throws {
        try await keychain.saveAccessToken("old-access")
        try await keychain.saveRefreshToken("old-refresh")
        let item = itemJSON
        let refresh = refreshJSON
        URLProtocolStub.setHandler { request in
            switch request.url?.path {
            case "/auth/refresh-token":
                return .init(statusCode: 200, data: refresh)
            case "/items":
                // Only NEW tokens are accepted -> prove that the retry used a new token.
                return request.value(forHTTPHeaderField: "Authorization") == "Bearer new-access"
                    ? .init(statusCode: 200, data: item)
                    : .init(statusCode: 401)
            default:
                return .init(statusCode: 404)
            }
        }

        let result: Item = try await makeClient(withInterceptor: true).request(StubEndpoint())

        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(URLProtocolStub.requestCount, 3) // items(401) + refresh + items(200)
    }

    func test_request_on401_whenRefreshFails_throwsUnauthorizedWithoutLooping() async {
        URLProtocolStub.setHandler { _ in .init(statusCode: 401) }
        try? await keychain.saveAccessToken("old-access")
        try? await keychain.saveRefreshToken("old-refresh")
        let client = makeClient(withInterceptor: true)

        await assertThrows(.unauthorized) {
            let _: Item = try await client.request(StubEndpoint())
        }
        XCTAssertEqual(URLProtocolStub.requestCount, 2) // items(401) + refresh(401), stop immediately
    }

    func test_request_on401_whenRetryAlsoReturns401_stopsAfterOneRetry() async throws {
        try await keychain.saveAccessToken("old-access")
        try await keychain.saveRefreshToken("old-refresh")
        let refresh = refreshJSON
        URLProtocolStub.setHandler { request in
            request.url?.path == "/auth/refresh-token"
                ? .init(statusCode: 200, data: refresh)
                : .init(statusCode: 401)
        }
        let client = makeClient(withInterceptor: true)

        await assertThrows(.unauthorized) {
            let _: Item = try await client.request(StubEndpoint())
        }
        XCTAssertEqual(URLProtocolStub.requestCount, 3) // items(401) + refresh + items(401), NO second retry
    }

    func test_request_on401_whenEndpointDoesNotRequireAuth_doesNotRefresh() async {
        URLProtocolStub.setHandler { _ in .init(statusCode: 401) }
        let client = makeClient(withInterceptor: true)

        await assertThrows(.unauthorized) {
            let _: Item = try await client.request(StubEndpoint(requiresAuth: false))
        }
        XCTAssertEqual(URLProtocolStub.requestCount, 1)
    }
}
