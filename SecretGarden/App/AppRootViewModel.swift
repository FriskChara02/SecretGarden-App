//
//  AppRootViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 18/8/26.
//

// Check login status on app startup — based solely on the presence of the access token
// in the Keychain (without calling the actual authentication API, as there is no backend yet).
// Token validity will be determined when the actual API is called (AuthInterceptor handles 401s).

import Combine
import CoreModels
import CoreStorage
import Foundation
import Repositories

enum SessionState: Equatable {
    case checking
    case unauthenticated
    case authenticated
}

@MainActor
final class AppRootViewModel: ObservableObject {
    @Published private(set) var sessionState: SessionState = .checking
    @Published private(set) var currentUser: User?

    private let keychainManager: KeychainManager
    private let userRepository: UserRepositoryProtocol

    init(keychainManager: KeychainManager, userRepository: UserRepositoryProtocol) {
        self.keychainManager = keychainManager
        self.userRepository = userRepository
    }

    func checkSession() {
        Task {
            let token = await keychainManager.readAccessToken()
            if token != nil {
                sessionState = .authenticated
                await loadCurrentUser()
            } else {
                sessionState = .unauthenticated
            }
        }
    }

    /// Called when AuthFlowView reports a successful login/registration.
    func markAuthenticated() {
        sessionState = .authenticated
        Task { await loadCurrentUser() }
    }

    /// Called when the user taps Log Out.
    func markUnauthenticated() {
        sessionState = .unauthenticated
        currentUser = nil
    }

    /// Called by ProfileFeature  right after a successful profile/account edit,
    /// so the cached copy here stays in sync WITHOUT forcing every screen to re-fetch.
    func updateCachedUser(_ user: User) {
        currentUser = user
    }

    // MARK: - Private

    private func loadCurrentUser() async {
        do {
            currentUser = try await userRepository.fetchCurrentUser()
        } catch {
            // Non-fatal: The "Personal" tab will temporarily display the guest icon without blocking the app's main flow.
            currentUser = nil
        }
    }
}
