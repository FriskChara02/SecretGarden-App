//
//  LoginView.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 17/8/26.
//

import CoreArchitecture
import DesignSystem
import Repositories
import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel

    /// Navigation is determined externally (by the Coordinator) —
    /// LoginView merely "notifies"; it does not know how to navigate between screens itself.
    private let onLoginSuccess: () -> Void
    private let onNavigateToRegister: () -> Void
    private let onNavigateToForgotPassword: () -> Void

    public init(
        repository: AuthRepositoryProtocol,
        googleAuthService: GoogleAuthServicing,
        onLoginSuccess: @escaping () -> Void,
        onNavigateToRegister: @escaping () -> Void,
        onNavigateToForgotPassword: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(repository: repository, googleAuthService: googleAuthService))
        self.onLoginSuccess = onLoginSuccess
        self.onNavigateToRegister = onNavigateToRegister
        self.onNavigateToForgotPassword = onNavigateToForgotPassword
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Text("Đăng nhập")
                    .dsFont(.largeTitle)
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: DSSpacing.md) {
                    DSTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $viewModel.loginEmail,
                        errorMessage: viewModel.loginEmailError
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    DSTextField(
                        label: "Mật khẩu",
                        placeholder: "••••••••",
                        text: $viewModel.loginPassword,
                        isSecure: true,
                        errorMessage: viewModel.loginPasswordError
                    )
                }
                .disabled(viewModel.loginState.isSubmitting)

                HStack {
                    AuthCheckboxToggle(title: "Ghi nhớ mật khẩu", isOn: $viewModel.rememberMe)
                    Spacer()
                }

                if let error = viewModel.loginState.error {
                    Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                        .dsFont(.footnote)
                        .foregroundStyle(DSColor.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                DSButton(
                    "Đăng nhập",
                    variant: .primary,
                    isLoading: viewModel.loginState.isSubmitting
                ) {
                    //viewModel.login()
                    onLoginSuccess()
                }

                DSButton("Khôi phục mật khẩu?", variant: .text, size: .medium) {
                    onNavigateToForgotPassword()
                }

                Divider()

                DSButton("Đăng nhập bằng Google", variant: .outline) {
                    viewModel.loginWithGoogle()
                }
                .disabled(viewModel.loginState.isSubmitting)

                HStack(spacing: DSSpacing.xxs) {
                    Text("Bạn chưa có tài khoản?")
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textSecondary)
                    Button("Đăng ký tại đây") {
                        onNavigateToRegister()
                    }
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.brandPrimary)
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .onChange(of: viewModel.loginState) { _, newState in
            if newState == .succeeded {
                onLoginSuccess()
            }
        }
    }
}

#Preview("LoginView") {
    LoginView(
        repository: AuthRepositoryMock(),
        googleAuthService: GoogleAuthServiceMock(),
        onLoginSuccess: {},
        onNavigateToRegister: {},
        onNavigateToForgotPassword: {}
    )
}
