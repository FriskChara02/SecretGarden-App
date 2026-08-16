    //
    //  AuthViewModelTests.swift
    //  AuthFeature
    //
    //  Created by Loi Nguyen on 16/8/26.
    //

    import XCTest
    import FactoryKit
    @testable import AuthFeature
    @testable import Repositories
    import CoreModels
    import CoreArchitecture

    // MARK: - Mock Repository for Unit Testing
    final class AuthRepositoryMock: AuthRepositoryProtocol, @unchecked Sendable {
        var loginCallCount = 0
        var lastLoginRequest: LoginRequest?
        var loginResult: Result<AuthResponse, AppError> = .failure(.unknown(NSError(domain: "", code: -1).localizedDescription))
        
        func login(_ request: LoginRequest) async throws -> AuthResponse {
            loginCallCount += 1
            lastLoginRequest = request
            switch loginResult {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }

        func register(_ request: RegisterRequest) async throws -> AuthResponse {
            fatalError("Not implemented")
        }

        func loginWithGoogle(_ request: GoogleLoginRequest) async throws -> AuthResponse {
            fatalError("Not implemented")
        }

        func forgotPassword(_ request: ForgotPasswordRequest) async throws {
            fatalError("Not implemented")
        }

        func resetPassword(_ request: ResetPasswordRequest) async throws {
            fatalError("Not implemented")
        }

        func changePassword(_ request: ChangePasswordRequest) async throws {
            fatalError("Not implemented")
        }

        func logout() async throws {
            fatalError("Not implemented")
        }
    }

    // MARK: - Tests
    @MainActor
    final class AuthViewModelTests: XCTestCase {

        override func setUp() {
            super.setUp()
            // Push a new Push-Scope or reset the Container before each test
            Container.shared.manager.push()
        }

        override func tearDown() {
            // Pop the scope to clean up mocks and restore the Container to its original state
            Container.shared.manager.pop()
            super.tearDown()
        }

        func test_login_invalidEmail_doesNotCallRepository() {
            // 1. Create mock
            let mock = AuthRepositoryMock()
            // 2. Register the mock with the Factory first
            Container.shared.authRepository.register { mock }

            // 3. Initialize SUT (AuthViewModel will inject the mock defined above)
            let sut = AuthViewModel()

            sut.loginEmail = "not-an-email"
            sut.loginPassword = "12345678"
            sut.login()

            XCTAssertEqual(mock.loginCallCount, 0)
            XCTAssertNotNil(sut.loginEmailError)
        }

        func test_login_validInput_success_updatesStateToSucceeded() async {
            // 1. Create mocks & set up data
            let mock = AuthRepositoryMock()
            let fakeResponse = AuthResponse(
                accessToken: "token",
                refreshToken: "refresh",
                user: User(id: "1", username: "test", email: "test@example.com", joinedAt: Date())
            )
            mock.loginResult = .success(fakeResponse)
            
            // 2. Register mock
            Container.shared.authRepository.register { mock }

            // 3. Initialize SUT
            let sut = AuthViewModel()

            sut.loginEmail = "test@example.com"
            sut.loginPassword = "12345678"
            sut.login()

            // Wait for the async Task in the ViewModel to complete
            try? await Task.sleep(for: .milliseconds(100))

            XCTAssertEqual(mock.loginCallCount, 1)
            XCTAssertEqual(mock.lastLoginRequest?.email, "test@example.com")
            XCTAssertEqual(sut.loginState, .succeeded)
        }

        func test_login_repositoryThrows_updatesStateToFailed() async {
            // 1. Create mock & setup error
            let mock = AuthRepositoryMock()
            mock.loginResult = .failure(AppError.unauthorized)
            
            // 2. Register mock
            Container.shared.authRepository.register { mock }

            // 3. Initialize SUT
            let sut = AuthViewModel()

            sut.loginEmail = "test@example.com"
            sut.loginPassword = "12345678"
            sut.login()

            try? await Task.sleep(for: .milliseconds(100))

            XCTAssertEqual(mock.loginCallCount, 1)
            XCTAssertEqual(sut.loginState, .failed(.unauthorized))
        }
    }
