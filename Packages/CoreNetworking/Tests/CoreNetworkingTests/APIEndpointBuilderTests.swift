//
//  APIEndpointBuilderTests.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

import XCTest
@testable import CoreNetworking

final class APIEndpointBuilderTests: XCTestCase {

    private struct MockEndpoint: APIEndpoint {
        var path: String = "/test"
        var method: HTTPMethod = .get
        var queryItems: [URLQueryItem]? = nil
        var body: Data? = nil
        var headers: [String: String]? = nil
        var requiresAuth: Bool = false
    }

    private let baseURL = URL(string: "https://api.secretgarden.example.com")!

    func test_buildRequest_getMethod_hasCorrectURL() throws {
        let endpoint = MockEndpoint(path: "/series/123", method: .get)
        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://api.secretgarden.example.com/series/123")
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_buildRequest_withQueryItems_appendsCorrectly() throws {
        let endpoint = MockEndpoint(
            path: "/search",
            queryItems: [URLQueryItem(name: "q", value: "yuri"), URLQueryItem(name: "page", value: "1")]
        )
        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://api.secretgarden.example.com/search?q=yuri&page=1")
    }

    func test_buildRequest_withBody_setsContentTypeHeader() throws {
        let bodyData = try JSONEncoder().encode(["email": "a@b.com"])
        let endpoint = MockEndpoint(path: "/auth/login", method: .post, body: bodyData)
        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.httpBody, bodyData)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func test_buildRequest_withoutBody_doesNotSetContentType() throws {
        let endpoint = MockEndpoint(path: "/home/latest-updates", method: .get)
        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func test_buildRequest_customHeader_overridesDefault() throws {
        let endpoint = MockEndpoint(path: "/upload", headers: ["Content-Type": "multipart/form-data"])
        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "multipart/form-data")
    }
}
