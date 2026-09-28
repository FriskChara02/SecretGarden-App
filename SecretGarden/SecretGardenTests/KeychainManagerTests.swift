//
//  KeychainManagerTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import XCTest
import CoreStorage

final class KeychainManagerTests: XCTestCase {

    private var sut: KeychainManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = KeychainManager()
        // Clean up before each test
        // (XCTest does NOT guarantee that tests run sequentially based on file order).
        try? await sut.clearTokens()
    }

    override func tearDown() async throws {
        try? await sut.clearTokens()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Save / Read

    func test_saveAndReadAccessToken_returnsSameValue() async throws {
        try await sut.saveAccessToken("access-abc-123")

        let result = await sut.readAccessToken()

        XCTAssertEqual(result, "access-abc-123")
    }

    func test_saveAndReadRefreshToken_returnsSameValue() async throws {
        try await sut.saveRefreshToken("refresh-xyz-456")

        let result = await sut.readRefreshToken()

        XCTAssertEqual(result, "refresh-xyz-456")
    }

    func test_readAccessToken_whenNeverSaved_returnsNil() async {
        let result = await sut.readAccessToken()

        XCTAssertNil(result)
    }

    // MARK: - Overwrite

    func test_saveAccessToken_whenCalledTwice_overwritesOldValue() async throws {
        try await sut.saveAccessToken("first-token")
        try await sut.saveAccessToken("second-token")

        let result = await sut.readAccessToken()

        XCTAssertEqual(result, "second-token")
    }

    // MARK: - Clear

    func test_clearTokens_removesBothAccessAndRefreshToken() async throws {
        try await sut.saveAccessToken("access")
        try await sut.saveRefreshToken("refresh")

        try await sut.clearTokens()

        let access = await sut.readAccessToken()
        let refresh = await sut.readRefreshToken()
        XCTAssertNil(access)
        XCTAssertNil(refresh)
    }

    func test_clearTokens_whenNothingWasSaved_doesNotThrow() async throws {
        // Confirm that errSecItemNotFound is treated as success (based on the delete() logic in KeychainManager)
        try await sut.clearTokens()
    }

    // MARK: - Concurrency (lý do quan trọng nhất để KeychainManager là actor)

    func test_concurrentWrites_doNotCrashAndActorSerializesAccess() async {
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<20 {
                group.addTask {
                    try? await self.sut.saveAccessToken("token-\(index)")
                }
            }
        }

        // Do not assert that any specific value "wins" (undefined behavior) — simply verify
        // that the actor serializes correctly: no crashes, and no nil result after 20 concurrent writes.
        let result = await sut.readAccessToken()
        XCTAssertNotNil(result)
    }
}
