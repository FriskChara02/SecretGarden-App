//
//  NotificationSettingsRepository.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import CoreNetworking

public final class NotificationSettingsRepository: NotificationSettingsRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchSettings() async throws -> NotificationSettings {
        try await apiClient.request(NotificationSettingsEndpoint.fetch)
    }

    public func updateSettings(_ settings: NotificationSettings) async throws -> NotificationSettings {
        try await apiClient.request(NotificationSettingsEndpoint.update(settings))
    }
}
