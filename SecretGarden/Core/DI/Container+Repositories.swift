//
//  Container+Repositories.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 11/8/26.
//

// COMPOSITION ROOT for the Repository layer — the ONLY place in the entire app that decides
// "which specific instance to provide when SeriesRepositoryProtocol is needed" (the actual
// SeriesRepository, or a Mock for Previews/Tests later on).
//
// Mandatory rule: from now on, NO ViewModel is allowed to instantiate SeriesRepository()
// directly — always declare @Injected(\.seriesRepository) and retrieve it via the Container.

import CoreArchitecture
import FactoryKit
import Repositories

extension Container {
    @MainActor
    var seriesRepository: Factory<SeriesRepositoryProtocol> {
        self { SeriesRepository(apiClient: self.apiClient()) }
            .singleton
        // .singleton: shares a single instance throughout the app's lifecycle — appropriate because
        // the Repository here does not maintain state specific to individual callers.
    }
    @MainActor
    var authRepository: Factory<AuthRepositoryProtocol> {
        self {
            AuthRepository(
                apiClient: self.apiClient(),
                keychainManager: self.keychainManager()
            )
        }
        .singleton
    }
}
