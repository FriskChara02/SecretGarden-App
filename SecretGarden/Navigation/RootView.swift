//
//  RootView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/8/26.
//

// This is the ONLY "glue" allowed to know about both
// AppRootViewModel (session/Keychain) and RootCoordinator (UI routing) —
// RootCoordinator itself knows nothing about Auth/Keychain.

import AuthFeature
import CoreArchitecture
import FactoryKit
import Repositories
import SwiftUI

struct RootView: View {
    @State private var rootCoordinator = RootCoordinator()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var appRootViewModel = AppRootViewModel(
        keychainManager: Container.shared.keychainManager(),
        userRepository: Container.shared.userRepository()
    )

    var body: some View {
        Group {
            switch rootCoordinator.currentRoute {
            case .checking:
                // Very brief pause while reading the Keychain
                Color.clear
            case .auth:
                AuthFlowView(onAuthenticated: { appRootViewModel.markAuthenticated() })
            case .main:
                MainTabView(
                    currentUser: appRootViewModel.currentUser,
                    onAuthenticated: {
                        appRootViewModel.markAuthenticated()
                    },
                    onProfileUpdated: { updatedUser in
                        appRootViewModel.updateCachedUser(updatedUser)
                    },
                    onLogout: {
                        Task {
                            try? await Container.shared.authRepository().logout()
                            appRootViewModel.markUnauthenticated()
                        }
                    }
                )
            }
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .task { appRootViewModel.checkSession() }
        .onChange(of: appRootViewModel.sessionState) { _, newState in
            switch newState {
            case .checking:
                break
            case .authenticated, .unauthenticated:
                rootCoordinator.switchToMain()
            }
        }
    }
}
