//
//  AppRootView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 18/8/26.
//

import CoreStorage
import DesignSystem
import FactoryKit
import Repositories
import SwiftUI

struct AppRootView: View {
    @StateObject private var viewModel: AppRootViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AppRootViewModel(keychainManager: Container.shared.keychainManager()))
    }

    var body: some View {
        Group {
            switch viewModel.sessionState {
            case .checking:
                DSLoadingView(style: .spinner)
            case .unauthenticated:
                AuthFlowView(onAuthenticated: viewModel.markAuthenticated)
            case .authenticated:
                MainPlaceholderView(onLogout: viewModel.markUnauthenticated)
            }
        }
        .onAppear {
            viewModel.checkSession()
        }
    }
}

/// TEMPORARY placeholder until the actual HomeView is built.
/// Includes a Logout button so you can manually test the full loop: login -> Home -> logout -> return to Login.
private struct MainPlaceholderView: View {
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Text("🎉 Đã đăng nhập")
                .dsFont(.largeTitle)
                .foregroundStyle(DSColor.textPrimary)
            Text("Home thật sẽ được xây ở Phase 8.")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
            DSButton("Đăng xuất", variant: .outline) {
                Task {
                    try? await Container.shared.authRepository().logout()
                    onLogout()
                }
            }
        }
        .padding(DSSpacing.lg)
    }
}
