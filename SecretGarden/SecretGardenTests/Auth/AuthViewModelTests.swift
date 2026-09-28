//
//  AuthViewModelTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import AuthFeature
import CoreModels
import CoreArchitecture
import XCTest

@MainActor
final class AuthViewModelTests: XCTestCase {

    private func makeSUT(
        repository: FakeAuthRepository = FakeAuthRepository(),
        google: FakeGoogleAuthService = FakeGoogleAuthService()
    ) -> (sut: AuthViewModel, repository: FakeAuthRepository, google: FakeGoogleAuthService) {
        (AuthViewModel(repository: repository, googleAuthService: google), repository, google)
    }

    // MARK: - Login

    func test_login_withInvalidEmail_setsErrorAndDoesNotCallRepository() async {
        let (sut, repository, _) = makeSUT()
        sut.loginEmail = "not-an-email"
        sut.loginPassword = "password123"

        sut.login()

        XCTAssertEqual(sut.loginEmailError, "Email không đúng định dạng.")
        XCTAssertNil(sut.loginPasswordError)
        XCTAssertEqual(sut.loginState, .idle)
        let requests = await repository.loginRequests
        XCTAssertTrue(requests.isEmpty)
    }

    func test_login_withShortPassword_setsPasswordErrorAndDoesNotCallRepository() async {
        let (sut, repository, _) = makeSUT()
        sut.loginEmail = "frisk@example.com"
        sut.loginPassword = "123"

        sut.login()

        XCTAssertNil(sut.loginEmailError)
        XCTAssertEqual(sut.loginPasswordError, "Mật khẩu phải có ít nhất 8 ký tự.")
        XCTAssertEqual(sut.loginState, .idle)
        let requests = await repository.loginRequests
        XCTAssertTrue(requests.isEmpty)
    }

    func test_login_withValidInput_submitsThenSucceedsAndForwardsRequest() async {
        let (sut, repository, _) = makeSUT()
        sut.loginEmail = "frisk@example.com"
        sut.loginPassword = "password123"
        sut.rememberMe = true

        sut.login()

        XCTAssertEqual(sut.loginState, .submitting)
        await waitUntil { sut.loginState == .succeeded }
        let requests = await repository.loginRequests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.email, "frisk@example.com")
        XCTAssertEqual(requests.first?.password, "password123")
        XCTAssertEqual(requests.first?.rememberMe, true)
    }

    func test_login_whenRepositoryFails_setsFailedStateWithSameError() async {
        let expected = AppError.network(.other("Sai mật khẩu"))
        let (sut, _, _) = makeSUT(repository: FakeAuthRepository(failure: expected))
        sut.loginEmail = "frisk@example.com"
        sut.loginPassword = "password123"

        sut.login()

        await waitUntil { sut.loginState == .failed(expected) }
    }

    func test_login_afterFixingInput_clearsPreviousFieldErrors() async {
        let (sut, _, _) = makeSUT()
        sut.loginEmail = "bad"
        sut.loginPassword = "password123"
        sut.login()
        XCTAssertNotNil(sut.loginEmailError)

        sut.loginEmail = "frisk@example.com"
        sut.login()

        XCTAssertNil(sut.loginEmailError)
        await waitUntil { sut.loginState == .succeeded }
    }

    // MARK: - Google

    func test_loginWithGoogle_success_forwardsIdTokenToRepository() async {
        let (sut, repository, google) = makeSUT()
        google.result = .success("google-token-123")

        sut.loginWithGoogle()

        await waitUntil { sut.loginState == .succeeded }
        let requests = await repository.googleRequests
        XCTAssertEqual(requests.first?.idToken, "google-token-123")
    }

    func test_loginWithGoogle_whenUserCancels_failsWithoutCallingRepository() async {
        let cancelled = AppError.validation("Bạn đã huỷ đăng nhập Google.")
        let (sut, repository, google) = makeSUT()
        google.result = .failure(cancelled)

        sut.loginWithGoogle()

        await waitUntil { sut.loginState == .failed(cancelled) }
        let requests = await repository.googleRequests
        XCTAssertTrue(requests.isEmpty)
    }

    // MARK: - Register

    func test_register_withInvalidInput_setsAllFieldErrorsAndDoesNotCallRepository() async {
        let (sut, repository, _) = makeSUT()
        sut.registerUsername = "ab"
        sut.registerEmail = "x"
        sut.registerPassword = "123"
        sut.registerConfirmPassword = "456"

        sut.register()

        XCTAssertEqual(sut.registerUsernameError, "Tên đăng nhập phải có ít nhất 3 ký tự.")
        XCTAssertEqual(sut.registerEmailError, "Email không đúng định dạng.")
        XCTAssertEqual(sut.registerPasswordError, "Mật khẩu phải có ít nhất 8 ký tự.")
        XCTAssertEqual(sut.registerConfirmPasswordError, "Mật khẩu xác nhận không khớp.")
        XCTAssertEqual(sut.registerState, .idle)
        let requests = await repository.registerRequests
        XCTAssertTrue(requests.isEmpty)
    }

    func test_register_withValidInput_succeedsAndForwardsRequest() async {
        let (sut, repository, _) = makeSUT()
        sut.registerUsername = "frisk"
        sut.registerEmail = "frisk@example.com"
        sut.registerPassword = "password123"
        sut.registerConfirmPassword = "password123"

        sut.register()

        await waitUntil { sut.registerState == .succeeded }
        let requests = await repository.registerRequests
        XCTAssertEqual(requests.first?.username, "frisk")
        XCTAssertEqual(requests.first?.email, "frisk@example.com")
    }

    // MARK: - Forgot password

    func test_forgotPassword_withInvalidEmail_setsErrorAndDoesNotCallRepository() async {
        let (sut, repository, _) = makeSUT()
        sut.forgotPasswordEmail = "nope"

        sut.forgotPassword()

        XCTAssertEqual(sut.forgotPasswordEmailError, "Email không đúng định dạng.")
        XCTAssertEqual(sut.forgotPasswordState, .idle)
        let requests = await repository.forgotPasswordRequests
        XCTAssertTrue(requests.isEmpty)
    }

    func test_forgotPassword_withValidEmail_succeedsAndForwardsRequest() async {
        let (sut, repository, _) = makeSUT()
        sut.forgotPasswordEmail = "frisk@example.com"

        sut.forgotPassword()

        await waitUntil { sut.forgotPasswordState == .succeeded }
        let requests = await repository.forgotPasswordRequests
        XCTAssertEqual(requests.first?.email, "frisk@example.com")
    }

    // MARK: - Independence between forms (the reason why each action has its own state)

    func test_failedLogin_doesNotAffectRegisterOrForgotPasswordState() async {
        let (sut, _, _) = makeSUT(repository: FakeAuthRepository(failure: AppError.notFound))
        sut.loginEmail = "frisk@example.com"
        sut.loginPassword = "password123"

        sut.login()
        await waitUntil { sut.loginState == .failed(.notFound) }

        XCTAssertEqual(sut.registerState, .idle)
        XCTAssertEqual(sut.forgotPasswordState, .idle)
    }
}
