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
    var embedsOwnNavigationStack: Bool = true

    var body: some View {
        Group {
            if embedsOwnNavigationStack {
                NavigationStack(path: pathBinding) {
                    loginContent
                        .navigationDestination(for: AuthRoute.self, destination: destinationView)
                }
            } else {
                loginContent
                    .navigationDestination(for: AuthRoute.self, destination: destinationView)
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

    @ViewBuilder
    private func destinationView(for route: AuthRoute) -> some View {
        switch route {
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

    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { authCoordinator.coordinator.path },
            set: { authCoordinator.coordinator.path = $0 }
        )
    }

    private func makeGoogleAuthService() -> GoogleAuthService {
        GoogleAuthService(
            clientID: AppConfig.googleClientID,
            redirectURIScheme: AppConfig.googleRedirectURIScheme
        )
    }
}
