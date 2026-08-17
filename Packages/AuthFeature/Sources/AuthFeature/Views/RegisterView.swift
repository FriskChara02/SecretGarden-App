//
//  RegisterView.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 17/8/26.
//

import CoreArchitecture
import DesignSystem
import Repositories
import SwiftUI

public struct RegisterView: View {
    @StateObject private var viewModel: AuthViewModel

    private let onRegisterSuccess: () -> Void
    private let onNavigateToLogin: () -> Void

    public init(
        repository: AuthRepositoryProtocol,
        googleAuthService: GoogleAuthServicing,
        onRegisterSuccess: @escaping () -> Void,
        onNavigateToLogin: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: AuthViewModel(
                repository: repository,
                googleAuthService: googleAuthService
            )
        )
        self.onRegisterSuccess = onRegisterSuccess
        self.onNavigateToLogin = onNavigateToLogin
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Text("Đăng ký")
                    .dsFont(.largeTitle)
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: DSSpacing.md) {
                    DSTextField(
                        label: "Tên đăng nhập",
                        placeholder: "username",
                        text: $viewModel.registerUsername,
                        errorMessage: viewModel.registerUsernameError
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    DSTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $viewModel.registerEmail,
                        errorMessage: viewModel.registerEmailError
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    DSTextField(
                        label: "Mật khẩu",
                        placeholder: "••••••••",
                        text: $viewModel.registerPassword,
                        isSecure: true,
                        errorMessage: viewModel.registerPasswordError
                    )

                    DSTextField(
                        label: "Xác nhận mật khẩu",
                        placeholder: "••••••••",
                        text: $viewModel.registerConfirmPassword,
                        isSecure: true,
                        errorMessage: viewModel.registerConfirmPasswordError
                    )
                }
                .disabled(viewModel.registerState.isSubmitting)

                if let error = viewModel.registerState.error {
                    Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                        .dsFont(.footnote)
                        .foregroundStyle(DSColor.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                DSButton(
                    "Đăng ký",
                    variant: .primary,
                    isLoading: viewModel.registerState.isSubmitting
                ) {
                    viewModel.register()
                }

                HStack(spacing: DSSpacing.xxs) {
                    Text("Đã có tài khoản?")
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textSecondary)
                    Button("Đăng nhập") {
                        onNavigateToLogin()
                    }
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.brandPrimary)
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .onChange(of: viewModel.registerState) { _, newState in
            if newState == .succeeded {
                onRegisterSuccess()
            }
        }
    }
}

#Preview("RegisterView") {
    RegisterView(
        repository: AuthRepositoryMock(),
        googleAuthService: GoogleAuthServiceMock(),
        onRegisterSuccess: {},
        onNavigateToLogin: {}
    )
}
