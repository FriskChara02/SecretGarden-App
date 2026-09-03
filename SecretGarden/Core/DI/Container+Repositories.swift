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
import CoreStorage
import FactoryKit
import Repositories
import Foundation

extension Container {
    /// Series Detail/Reader uses SeriesRepositoryMock in Debug/Staging (to avoid network errors when
    /// the backend does not yet exist) and the real SeriesRepository in Production - following the same pattern
    /// applied to homeRepository and searchRemoteDataSource.
    @MainActor
    var seriesRepository: Factory<SeriesRepositoryProtocol> {
        self {
            if AppConfig.isDebugEnvironment {
                return SeriesRepositoryMock()
            } else {
                return SeriesRepository(apiClient: self.apiClient())
            }
        }
        .singleton
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

    /// Home uses HomeRepositoryMock in Debug/Staging (to avoid "-1003 DNS" errors when the backend
    /// does not yet exist) and the real HomeRepository in Production.
    @MainActor
    var homeRepository: Factory<HomeRepositoryProtocol> {
        self {
            if AppConfig.isDebugEnvironment {
                return HomeRepositoryMock()
            } else {
                return HomeRepository(apiClient: self.apiClient())
            }
        }
        .singleton
    }

    /// SwiftData ModelContainer for search history — if setup fails, this is a developer/configuration
    /// error (e.g. corrupted schema), so it should fail loudly at launch rather than force-try silently.
    /// Same fail-fast philosophy, but avoids SwiftLint's force_try rule.
    @MainActor
    var searchHistoryLocalStore: Factory<SearchHistoryLocalStore> {
        self {
            do {
                return try SearchHistoryLocalStore()
            } catch {
                fatalError("Failed to initialize SearchHistoryLocalStore: \(error.localizedDescription)")
            }
        }
        .singleton
    }

    /// This is the ONLY place that decides between Mock and Real for the search function -
    /// but it applies at a more granular level
    /// (only for remote search, it does NOT apply to history - history is always real).
    @MainActor
    var searchRemoteDataSource: Factory<SearchRemoteDataSource> {
        self {
            if AppConfig.isDebugEnvironment {
                return SearchRemoteMockDataSource()
            } else {
                return SearchRemoteAPIDataSource(apiClient: self.apiClient())
            }
        }
        .singleton
    }

    /// SearchRepository is always the real implementation - there are no longer any Mock/Real if/else branches at this level,
    /// because the history (localHistoryStore) always requires the real version, while the search strategy
    /// has already been determined by the searchRemoteDataSource upstream.
    @MainActor
    var searchRepository: Factory<SearchRepositoryProtocol> {
        self {
            SearchRepository(
                remoteDataSource: self.searchRemoteDataSource(),
                localHistoryStore: self.searchHistoryLocalStore()
            )
        }
        .singleton
    }
}
