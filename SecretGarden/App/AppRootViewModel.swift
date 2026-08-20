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
import CoreStorage
import Foundation

enum SessionState: Equatable {
    case checking
    case unauthenticated
    case authenticated
}

@MainActor
final class AppRootViewModel: ObservableObject {
    @Published private(set) var sessionState: SessionState = .checking

    private let keychainManager: KeychainManager

    init(keychainManager: KeychainManager) {
        self.keychainManager = keychainManager
    }

    func checkSession() {
        Task {
            let token = await keychainManager.readAccessToken()
            sessionState = (token != nil) ? .authenticated : .unauthenticated
        }
    }

    /// Called when AuthFlowView signals a successful login or registration.
    func markAuthenticated() {
        sessionState = .authenticated
    }

    /// Called when the user clicks Log Out.
    func markUnauthenticated() {
        sessionState = .unauthenticated
    }
}
