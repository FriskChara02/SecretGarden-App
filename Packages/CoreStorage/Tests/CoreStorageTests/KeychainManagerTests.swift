//
//  KeychainManagerTests.swift
//  CoreStorage
//
//  Created by Loi Nguyen on 15/8/26.
//

// Note: This test uses the actual Keychain on the Simulator (it cannot be mocked as it is a system API) --
// this is one of the rare cases where a unit test interacts with "real infrastructure".

import XCTest
@testable import CoreStorage

final class KeychainManagerTests: XCTestCase {

    private var sut: KeychainManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = KeychainManager()
        try? await sut.clearTokens() // Clean up before each test to prevent the previous test from affecting the next one.
    }

    override func tearDown() async throws {
        try? await sut.clearTokens()
        try await super.tearDown()
    }

    func test_saveAndReadAccessToken_returnsCorrectValue() async throws {
        try await sut.saveAccessToken("abc123")
        let result = await sut.readAccessToken()
        XCTAssertEqual(result, "abc123")
    }

    func test_saveAndReadRefreshToken_returnsCorrectValue() async throws {
        try await sut.saveRefreshToken("refresh456")
        let result = await sut.readRefreshToken()
        XCTAssertEqual(result, "refresh456")
    }

    func test_readAccessToken_whenNotSaved_returnsNil() async {
        let result = await sut.readAccessToken()
        XCTAssertNil(result)
    }

    func test_saveAccessToken_overwritesPreviousValue() async throws {
        try await sut.saveAccessToken("first")
        try await sut.saveAccessToken("second")
        let result = await sut.readAccessToken()
        XCTAssertEqual(result, "second")
    }

    func test_clearTokens_removesBothTokens() async throws {
        try await sut.saveAccessToken("abc")
        try await sut.saveRefreshToken("def")
        try await sut.clearTokens()

        let access = await sut.readAccessToken()
        let refresh = await sut.readRefreshToken()
        XCTAssertNil(access)
        XCTAssertNil(refresh)
    }
}
