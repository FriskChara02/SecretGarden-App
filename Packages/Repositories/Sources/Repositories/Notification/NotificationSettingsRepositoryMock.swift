//
//  NotificationSettingsRepositoryMock.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels

public actor NotificationSettingsRepositoryMock: NotificationSettingsRepositoryProtocol {

    private var settings = NotificationSettings()

    public init() {}

    public func fetchSettings() async throws -> NotificationSettings {
        settings
    }

    public func updateSettings(_ settings: NotificationSettings) async throws -> NotificationSettings {
        self.settings = settings
        return settings
    }
}
