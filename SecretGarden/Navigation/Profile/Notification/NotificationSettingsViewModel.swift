//
//  NotificationSettingsViewModel.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import CoreModels
import Combine
import Foundation
import Repositories

@MainActor
final class NotificationSettingsViewModel: BaseViewModel {

    private let repository: NotificationSettingsRepositoryProtocol

    @Published private(set) var state: LoadableState<NotificationSettings> = .idle
    @Published var actionErrorMessage: String?

    init(repository: NotificationSettingsRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    func onAppear() {
        guard case .idle = state else { return }
        load()
    }

    func load() {
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            do {
                let settings = try await self.repository.fetchSettings()
                self.state = .loaded(settings)
            } catch {
                self.state = .failed(self.mapToAppError(error))
            }
        }
    }

    func toggle(_ keyPath: WritableKeyPath<NotificationSettings, Bool>) {
        guard case .loaded(var settings) = state else { return }
        let previous = settings
        settings[keyPath: keyPath].toggle()
        state = .loaded(settings)

        Task { [weak self] in
            guard let self else { return }
            do {
                let confirmed = try await self.repository.updateSettings(settings)
                self.state = .loaded(confirmed)
            } catch {
                self.state = .loaded(previous)   // rollback
                self.actionErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }

    func dismissActionError() {
        actionErrorMessage = nil
    }
}
