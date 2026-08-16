//
//  AuthViewModel.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 16/8/26.
//

// A shared ViewModel for LoginView, RegisterView, and ForgotPasswordView.
// Each action (login, register, forgotPassword) has its own @Published state (FormSubmissionState).
// Since the three views are independent, they shouldn't share a single state (a failed login
// shouldn't trigger an error display in the RegisterView).
//
// We use @Injected (rather than initializer injection) because AuthViewModel is instantiated
// directly by LoginView/RegisterView using @StateObject (bypassing Container resolution, unlike
// Repositories). This follows the standard Factory pattern for ViewModels: Repositories are
// resolved via the Container, whereas the View owns the ViewModel's lifecycle (managed by
// SwiftUI), only dependencies *inside* the ViewModel require @Injected.

import CoreArchitecture
import CoreModels
import FactoryKit
import Foundation
import Repositories

@MainActor
public final class AuthViewModel: BaseViewModel {

    @Injected(\.authRepository) private var repository

    // MARK: - Login form

    @Published public var loginEmail = ""
    @Published public var loginPassword = ""
    @Published public var rememberMe = false
    @Published public private(set) var loginState: FormSubmissionState = .idle
    @Published public private(set) var loginEmailError: String?
    @Published public private(set) var loginPasswordError: String?

    // MARK: - Register form

    @Published public var registerUsername = ""
    @Published public var registerEmail = ""
    @Published public var registerPassword = ""
    @Published public var registerConfirmPassword = ""
    @Published public private(set) var registerState: FormSubmissionState = .idle
    @Published public private(set) var registerUsernameError: String?
    @Published public private(set) var registerEmailError: String?
    @Published public private(set) var registerPasswordError: String?
    @Published public private(set) var registerConfirmPasswordError: String?

    // MARK: - Forgot password form

    @Published public var forgotPasswordEmail = ""
    @Published public private(set) var forgotPasswordState: FormSubmissionState = .idle
    @Published public private(set) var forgotPasswordEmailError: String?

    override public init() {
        super.init()
    }

    // MARK: - Login

    public func login() {
        loginEmailError = AuthValidator.validateEmail(loginEmail)
        loginPasswordError = AuthValidator.validatePassword(loginPassword)
        guard loginEmailError == nil, loginPasswordError == nil else { return }

        loginState = .submitting
        let request = LoginRequest(email: loginEmail, password: loginPassword, rememberMe: rememberMe)
        runTask(
            { [weak self] in
                guard let self else { return }
                _ = try await self.repository.login(request)
                self.loginState = .succeeded
            },
            onError: { [weak self] appError in
                self?.loginState = .failed(appError)
            }
        )
    }

    // MARK: - Register

    public func register() {
        registerUsernameError = AuthValidator.validateUsername(registerUsername)
        registerEmailError = AuthValidator.validateEmail(registerEmail)
        registerPasswordError = AuthValidator.validatePassword(registerPassword)
        registerConfirmPasswordError = AuthValidator.validateConfirmPassword(registerPassword, registerConfirmPassword)
        guard registerUsernameError == nil,
              registerEmailError == nil,
              registerPasswordError == nil,
              registerConfirmPasswordError == nil else { return }

        registerState = .submitting
        let request = RegisterRequest(
            username: registerUsername,
            email: registerEmail,
            password: registerPassword,
            confirmPassword: registerConfirmPassword
        )
        runTask(
            { [weak self] in
                guard let self else { return }
                _ = try await self.repository.register(request)
                self.registerState = .succeeded
            },
            onError: { [weak self] appError in
                self?.registerState = .failed(appError)
            }
        )
    }

    // MARK: - Forgot Password

    public func forgotPassword() {
        forgotPasswordEmailError = AuthValidator.validateEmail(forgotPasswordEmail)
        guard forgotPasswordEmailError == nil else { return }

        forgotPasswordState = .submitting
        let request = ForgotPasswordRequest(email: forgotPasswordEmail)
        runTask(
            { [weak self] in
                guard let self else { return }
                try await self.repository.forgotPassword(request)
                self.forgotPasswordState = .succeeded
            },
            onError: { [weak self] appError in
                self?.forgotPasswordState = .failed(appError)
            }
        )
    }
}
