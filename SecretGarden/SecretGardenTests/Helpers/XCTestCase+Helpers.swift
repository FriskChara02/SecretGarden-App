//
//  XCTestCase+Helpers.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreNetworking
import XCTest

extension XCTestCase {

    /// Run `operation` and verify that it throws the expected `AppError`.
    func assertThrowsAppError(
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

    /// Read the endpoint body as a dictionary to check the JSON key names.
    func jsonBody(
        of endpoint: APIEndpoint,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [String: Any] {
        let body = try XCTUnwrap(endpoint.body, "Endpoint không có body", file: file, line: line)
        let object = try JSONSerialization.jsonObject(with: body)
        return try XCTUnwrap(object as? [String: Any], "Body không phải JSON object", file: file, line: line)
    }
}
