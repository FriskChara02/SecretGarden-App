//
//  APIEndpointBuilderTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreNetworking
import XCTest

final class APIEndpointBuilderTests: XCTestCase {

    private let baseURL = URL(string: "https://test.example.com")! // swiftlint:disable:this force_unwrapping

    func test_build_combinesBaseURLPathAndQueryItems() throws {
        var endpoint = StubEndpoint()
        endpoint.queryItems = [URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "q", value: "abc")]

        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://test.example.com/items?page=2&q=abc")
    }

    func test_build_usesEndpointMethod() throws {
        var endpoint = StubEndpoint()
        endpoint.method = .post

        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
    }

    func test_build_alwaysSetsAcceptJSON() throws {
        let request = try APIEndpointBuilder.buildRequest(for: StubEndpoint(), baseURL: baseURL)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func test_build_withBody_setsBodyAndJSONContentType() throws {
        var endpoint = StubEndpoint()
        endpoint.body = Data("{}".utf8)

        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.httpBody, Data("{}".utf8))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func test_build_withoutBody_doesNotSetContentType() throws {
        let request = try APIEndpointBuilder.buildRequest(for: StubEndpoint(), baseURL: baseURL)

        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
    }

    func test_build_endpointHeadersOverrideDefaults() throws {
        var endpoint = StubEndpoint()
        endpoint.body = Data([0x01])
        endpoint.headers = ["Content-Type": "multipart/form-data; boundary=abc"]

        let request = try APIEndpointBuilder.buildRequest(for: endpoint, baseURL: baseURL)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "multipart/form-data; boundary=abc")
    }
}
