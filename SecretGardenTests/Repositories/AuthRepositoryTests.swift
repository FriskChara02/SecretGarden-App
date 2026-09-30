//
//  AuthRepositoryTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreModels
import CoreStorage
import CoreNetworking
import Repositories
import XCTest

final class AuthRepositoryTests: XCTestCase {

    private var keychain: KeychainManager!

    override func setUp() async throws {
        try await super.setUp()
        keychain = KeychainManager()
        try? await keychain.clearTokens()
    }

    override func tearDown() async throws {
        try? await keychain.clearTokens()
        keychain = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeResponse() -> AuthResponse {
        AuthResponse(
            accessToken: "srv-access",
            refreshToken: "srv-refresh",
            user: User(
                id: "u1",
                username: "frisk",
                displayName: "Frisk",
                email: "frisk@example.com",
                authProvider: .email,
                joinedAt: Date()
            )
        )
    }

    private func makeSUT(_ client: FakeAPIClient) -> AuthRepository {
        AuthRepository(apiClient: client, keychainManager: keychain)
    }

    private func assertTokensSaved(file: StaticString = #filePath, line: UInt = #line) async {
        let access = await keychain.readAccessToken()
        let refresh = await keychain.readRefreshToken()
        XCTAssertEqual(access, "srv-access", file: file, line: line)
        XCTAssertEqual(refresh, "srv-refresh", file: file, line: line)
    }

    // MARK: - Login

    func test_login_success_savesTokensAndTargetsPublicLoginEndpoint() async throws {
        let client = FakeAPIClient(response: makeResponse())
        let sut = makeSUT(client)

        let result = try await sut.login(LoginRequest(email: "frisk@example.com", password: "secret", rememberMe: true))

        XCTAssertEqual(result.accessToken, "srv-access")
        await assertTokensSaved()
        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/auth/login")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertFalse(endpoint.requiresAuth)
    }

    func test_login_encodesRequestWithSnakeCaseKeys() async throws {
        let client = FakeAPIClient(response: makeResponse())
        let sut = makeSUT(client)

        _ = try await sut.login(LoginRequest(email: "frisk@example.com", password: "secret", rememberMe: true))

        let endpoints = await client.endpoints
        let json = try jsonBody(of: try XCTUnwrap(endpoints.first))
        XCTAssertEqual(json["email"] as? String, "frisk@example.com")
        XCTAssertEqual(json["remember_me"] as? Bool, true)
    }

    func test_login_failure_doesNotSaveTokensAndRethrowsSameError() async {
        let expected = AppError.network(.other("Sai mật khẩu"))
        let sut = makeSUT(FakeAPIClient(failure: expected))

        await assertThrowsAppError(expected) {
            _ = try await sut.login(LoginRequest(email: "a@b.c", password: "x", rememberMe: false))
        }

        let access = await keychain.readAccessToken()
        let refresh = await keychain.readRefreshToken()
        XCTAssertNil(access)
        XCTAssertNil(refresh)
    }

    // MARK: - Register / Google

    func test_register_success_savesTokens() async throws {
        let client = FakeAPIClient(response: makeResponse())
        let sut = makeSUT(client)

        _ = try await sut.register(
            RegisterRequest(username: "frisk", email: "frisk@example.com", password: "secret", confirmPassword: "secret")
        )

        await assertTokensSaved()
        let endpoints = await client.endpoints
        XCTAssertEqual(endpoints.first?.path, "/auth/register")
    }

    func test_loginWithGoogle_success_savesTokens() async throws {
        let client = FakeAPIClient(response: makeResponse())
        let sut = makeSUT(client)

        _ = try await sut.loginWithGoogle(GoogleLoginRequest(idToken: "google-id-token"))

        await assertTokensSaved()
        let endpoints = await client.endpoints
        XCTAssertEqual(endpoints.first?.path, "/auth/login/google")
    }

    // MARK: - Logout

    func test_logout_success_clearsTokensAndUsesAuthenticatedEndpoint() async throws {
        try await keychain.saveAccessToken("a")
        try await keychain.saveRefreshToken("r")
        let client = FakeAPIClient()
        let sut = makeSUT(client)

        try await sut.logout()

        let access = await keychain.readAccessToken()
        XCTAssertNil(access)
        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/auth/logout")
        XCTAssertTrue(endpoint.requiresAuth)
    }

    /// Intentional Repository exception: when the user clicks Log Out, the local session MUST terminate,
    /// even if a server error occurs (network loss, token expiration, etc.).
    func test_logout_whenServerFails_stillClearsTokensAndDoesNotThrow() async throws {
        try await keychain.saveAccessToken("a")
        try await keychain.saveRefreshToken("r")
        let sut = makeSUT(FakeAPIClient(failure: AppError.network(.noInternetConnection)))

        try await sut.logout() // must not throw an error

        let access = await keychain.readAccessToken()
        let refresh = await keychain.readRefreshToken()
        XCTAssertNil(access)
        XCTAssertNil(refresh)
    }

    // MARK: - Forgot password

    func test_forgotPassword_targetsPublicEndpointAndPropagatesError() async throws {
        let client = FakeAPIClient()
        try await makeSUT(client).forgotPassword(ForgotPasswordRequest(email: "frisk@example.com"))

        let endpoints = await client.endpoints
        let endpoint = try XCTUnwrap(endpoints.first)
        XCTAssertEqual(endpoint.path, "/auth/forgot-password")
        XCTAssertFalse(endpoint.requiresAuth)

        let failing = makeSUT(FakeAPIClient(failure: AppError.notFound))
        await assertThrowsAppError(.notFound) {
            try await failing.forgotPassword(ForgotPasswordRequest(email: "nobody@example.com"))
        }
    }
}
