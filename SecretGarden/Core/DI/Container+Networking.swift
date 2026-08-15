//
//  Container+Networking.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 15/8/26.
//

// COMPOSITION ROOT for the Networking layer — the ONLY place in the entire app
// that determines how to assemble the real KeychainManager, AuthInterceptor, and APIClient.
// Container+Repositories.swift will call this, rather than assembling them itself.

import CoreNetworking
import CoreStorage
import FactoryKit
import Foundation

extension Container {

    var keychainManager: Factory<KeychainManager> {
        self { KeychainManager.shared }
            .singleton
    }

    @MainActor
    var authInterceptor: Factory<AuthInterceptor> {
        self {
            AuthInterceptor(
                keychain: self.keychainManager(),
                baseURL: AppConfig.apiBaseURL
            )
        }
        .singleton
        // .singleton is required here: AuthInterceptor maintains an internal refreshTask state,
        // if a new instance were created upon each resolution, the "only one refresh at a time" mechanism would fail.
    }

    @MainActor
    var apiClient: Factory<APIClientProtocol> {
        self {
            let interceptor = self.authInterceptor()
            return APIClient(
                baseURL: AppConfig.apiBaseURL,
                accessTokenProvider: { await interceptor.currentAccessToken() },
                authInterceptor: interceptor
            )
        }
        .singleton
    }
}
