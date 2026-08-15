//
//  APIClientTests.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// Test APIClient using StubURLProtocol (without making actual network calls)

import XCTest
import CoreArchitecture
@testable import CoreNetworking

// MARK: - Mocking Responses and Recording Requests for Assertions Using URLProtocol

final class StubURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubStatusCode: Int = 200
    static var stubError: Error?
    static var lastRequest: URLRequest?
    static var callCount = 0

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Self.callCount += 1
        Self.lastRequest = request

        if let error = Self.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.stubStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = Self.stubResponseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - APIClient Unit Tests

final class APIClientTests: XCTestCase {

    private struct MockEndpoint: APIEndpoint {
        var path: String = "/test"
        var method: HTTPMethod = .get
        var requiresAuth: Bool = false
    }

    private struct MockModel: Decodable, Equatable {
        let name: String
        let viewCount: Int // test always convertFromSnakeCase (view_count -> viewCount)
    }

    private var sut: APIClient!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: config)

        sut = APIClient(
            baseURL: URL(string: "https://api.test.com")!,
            session: session
        )
    }

    override func tearDown() {
        StubURLProtocol.stubResponseData = nil
        StubURLProtocol.stubStatusCode = 200
        StubURLProtocol.stubError = nil
        StubURLProtocol.lastRequest = nil
        sut = nil
        session = nil
        super.tearDown()
    }

    func test_request_success_decodesModelCorrectly() async throws {
        let json = #"{"name": "Test Series", "view_count": 100}"#
        StubURLProtocol.stubResponseData = json.data(using: .utf8)
        StubURLProtocol.stubStatusCode = 200

        let result: MockModel = try await sut.request(MockEndpoint())

        XCTAssertEqual(result, MockModel(name: "Test Series", viewCount: 100))
    }

    func test_request_serverError404_throwsAppError() async {
        StubURLProtocol.stubStatusCode = 404
        StubURLProtocol.stubResponseData = #"{"message": "Không tìm thấy truyện", "code": "NOT_FOUND"}"#.data(using: .utf8)

        do {
            let _: MockModel = try await sut.request(MockEndpoint())
            XCTFail("Phải throw lỗi")
        } catch let error as AppError {
            XCTAssertEqual(error, .network(.other("Không tìm thấy truyện")))
        } catch {
            XCTFail("Phải throw AppError, không phải \(type(of: error))")
        }
    }

    func test_request_serverError401_throwsUnauthorized() async {
        StubURLProtocol.stubStatusCode = 401
        StubURLProtocol.stubResponseData = Data()

        do {
            let _: MockModel = try await sut.request(MockEndpoint())
            XCTFail("Phải throw lỗi")
        } catch let error as AppError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Phải throw AppError, không phải \(type(of: error))")
        }
    }

    func test_request_invalidJSON_throwsDecodingFailed() async {
        StubURLProtocol.stubStatusCode = 200
        StubURLProtocol.stubResponseData = #"{"unexpected": "field"}"#.data(using: .utf8)

        do {
            let _: MockModel = try await sut.request(MockEndpoint())
            XCTFail("Phải throw lỗi")
        } catch let error as AppError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Phải throw AppError, không phải \(type(of: error))")
        }
    }

    func test_request_attachesAuthHeader_whenRequiresAuth() async throws {
        struct AuthEndpoint: APIEndpoint {
            var path: String = "/me"
            var method: HTTPMethod = .get
            var requiresAuth: Bool = true
        }

        StubURLProtocol.stubResponseData = #"{"name": "Secret", "view_count": 1}"#.data(using: .utf8)

        let authedClient = APIClient(
            baseURL: URL(string: "https://api.test.com")!,
            session: session,
            accessTokenProvider: { "secret-token-123" }
        )

        let _: MockModel = try await authedClient.request(AuthEndpoint())

        let authHeader = StubURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authHeader, "Bearer secret-token-123")
    }
}
