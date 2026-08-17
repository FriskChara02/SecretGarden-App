//
//  ForgotPasswordView.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 17/8/26.
//

import CoreArchitecture
import DesignSystem
import Repositories
import SwiftUI

public struct ForgotPasswordView: View {
    @StateObject private var viewModel: AuthViewModel

    private let onLoginSuccess: () -> Void
    private let onNavigateBackToLogin: () -> Void

    public init(
        repository: AuthRepositoryProtocol,
        googleAuthService: GoogleAuthServicing,
        onLoginSuccess: @escaping () -> Void,
        onNavigateBackToLogin: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(repository: repository, googleAuthService: googleAuthService))
        self.onLoginSuccess = onLoginSuccess
        self.onNavigateBackToLogin = onNavigateBackToLogin
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Text("Khôi phục mật khẩu")
                    .dsFont(.largeTitle)
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.forgotPasswordState == .succeeded {
                    successView
                } else {
                    formView
                }

                Divider()

                DSButton("Đăng nhập bằng Google", variant: .outline) {
                    viewModel.loginWithGoogle()
                }
                .disabled(viewModel.forgotPasswordState.isSubmitting || viewModel.loginState.isSubmitting)

                Button("Quay lại Đăng nhập") {
                    onNavigateBackToLogin()
                }
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.brandPrimary)
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

    // MARK: - Form state (before submission)

    private var formView: some View {
        VStack(spacing: DSSpacing.md) {
            DSTextField(
                label: "Email khôi phục",
                placeholder: "you@example.com",
                text: $viewModel.forgotPasswordEmail,
                errorMessage: viewModel.forgotPasswordEmailError
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .disabled(viewModel.forgotPasswordState.isSubmitting)

            if let error = viewModel.forgotPasswordState.error {
                Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.statusError)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            DSButton(
                "Khôi phục mật khẩu",
                variant: .primary,
                isLoading: viewModel.forgotPasswordState.isSubmitting
            ) {
                viewModel.forgotPassword()
            }
        }
    }

    // MARK: - Success state (after successful submission — do NOT automatically navigate away)

    private var successView: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 40))
                .foregroundStyle(DSColor.statusSuccess)

            Text("Kiểm tra email của bạn")
                .dsFont(.headline)
                .foregroundStyle(DSColor.textPrimary)

            Text("Chúng mình đã gửi liên kết khôi phục mật khẩu tới \(viewModel.forgotPasswordEmail).")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, DSSpacing.lg)
    }
}

#Preview("ForgotPasswordView") {
    ForgotPasswordView(
        repository: AuthRepositoryMock(),
        googleAuthService: GoogleAuthServiceMock(),
        onLoginSuccess: {},
        onNavigateBackToLogin: {}
    )
}
