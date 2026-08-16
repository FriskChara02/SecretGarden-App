//
//  AuthViewModelTests.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 16/8/26.
//

import XCTest
@testable import AuthFeature
import Repositories
import CoreModels
import CoreArchitecture

@MainActor
final class AuthViewModelTests: XCTestCase {

    func test_login_invalidEmail_doesNotCallRepository() {
        let mock = AuthRepositoryMock()
        let sut = AuthViewModel(repository: mock)

        sut.loginEmail = "not-an-email"
        sut.loginPassword = "12345678"
        sut.login()

        XCTAssertEqual(mock.loginCallCount, 0)
        XCTAssertNotNil(sut.loginEmailError)
    }

    func test_login_validInput_success_updatesStateToSucceeded() async {
        let mock = AuthRepositoryMock()
        let fakeResponse = AuthResponse(
            accessToken: "token",
            refreshToken: "refresh",
            user: User(id: "1", username: "test", email: "test@example.com", joinedAt: Date())
        )
        mock.loginResult = .success(fakeResponse)
        let sut = AuthViewModel(repository: mock)

        sut.loginEmail = "test@example.com"
        sut.loginPassword = "12345678"
        sut.login()

        try? await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(sut.loginState, .succeeded)
        XCTAssertEqual(mock.loginCallCount, 1)
        XCTAssertEqual(mock.lastLoginRequest?.email, "test@example.com")
    }

    func test_login_repositoryThrows_updatesStateToFailed() async {
        let mock = AuthRepositoryMock()
        mock.loginResult = .failure(AppError.unauthorized)
        let sut = AuthViewModel(repository: mock)

        sut.loginEmail = "test@example.com"
        sut.loginPassword = "12345678"
        sut.login()

        try? await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(sut.loginState, .failed(.unauthorized))
    }
}
