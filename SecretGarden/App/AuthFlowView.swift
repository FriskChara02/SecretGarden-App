//
//  AuthFlowView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 18/8/26.
//

// Coordinates the Login, Register, and ForgotPassword screens using a simple state enum.
// TEMPORARY — will be replaced by a proper Coordinator/NavigationStack.
// This is NOT the project's official navigation architecture.

import AuthFeature
import FactoryKit
import Repositories
import SwiftUI

private enum AuthScreen {
    case login
    case register
    case forgotPassword
}

struct AuthFlowView: View {
    @State private var screen: AuthScreen = .login
    let onAuthenticated: () -> Void

    var body: some View {
        switch screen {
        case .login:
            LoginView(
                repository: Container.shared.authRepository(),
                googleAuthService: makeGoogleAuthService(),
                onLoginSuccess: onAuthenticated,
                onNavigateToRegister: { screen = .register },
                onNavigateToForgotPassword: { screen = .forgotPassword }
            )
        case .register:
            RegisterView(
                repository: Container.shared.authRepository(),
                googleAuthService: makeGoogleAuthService(),
                onRegisterSuccess: onAuthenticated,
                onNavigateToLogin: { screen = .login }
            )
        case .forgotPassword:
            ForgotPasswordView(
                repository: Container.shared.authRepository(),
                googleAuthService: makeGoogleAuthService(),
                onLoginSuccess: onAuthenticated,
                onNavigateBackToLogin: { screen = .login }
            )
        }
    }

    /// Create a new instance whenever needed - ASWebAuthenticationSession is designed for single use per login session,
    /// so there is no need to retain or reuse the instance (unlike AuthRepository/APIClient, which are app-wide singletons).
    private func makeGoogleAuthService() -> GoogleAuthService {
        GoogleAuthService(
            clientID: AppConfig.googleClientID,
            redirectURIScheme: AppConfig.googleRedirectURIScheme
        )
    }
}
