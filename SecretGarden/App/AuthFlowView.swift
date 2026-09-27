//
//  AuthFlowView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 18/8/26.
//

import AuthFeature
import FactoryKit
import Repositories
import SwiftUI
import CoreArchitecture

struct AuthFlowView: View {
    @State private var authCoordinator = AuthCoordinator()
    let onAuthenticated: () -> Void

    var body: some View {
        Group {
            switch authCoordinator.currentRoute {
            case .none:
                loginContent
            case .register:
                RegisterView(
                    repository: Container.shared.authRepository(),
                    googleAuthService: makeGoogleAuthService(),
                    onRegisterSuccess: onAuthenticated,
                    onNavigateToLogin: { authCoordinator.showLogin() }
                )
            case .forgotPassword:
                ForgotPasswordView(
                    repository: Container.shared.authRepository(),
                    googleAuthService: makeGoogleAuthService(),
                    onLoginSuccess: onAuthenticated,
                    onNavigateBackToLogin: { authCoordinator.showLogin() }
                )
            }
        }
    }

    private var loginContent: some View {
        LoginView(
            repository: Container.shared.authRepository(),
            googleAuthService: makeGoogleAuthService(),
            onLoginSuccess: onAuthenticated,
            onNavigateToRegister: { authCoordinator.show(.register) },
            onNavigateToForgotPassword: { authCoordinator.show(.forgotPassword) }
        )
    }

    private func makeGoogleAuthService() -> GoogleAuthService {
        GoogleAuthService(
            clientID: AppConfig.googleClientID,
            redirectURIScheme: AppConfig.googleRedirectURIScheme
        )
    }
}
