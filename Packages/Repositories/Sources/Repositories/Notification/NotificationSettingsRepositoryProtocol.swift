//
//  NotificationSettingsRepositoryProtocol.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels

public protocol NotificationSettingsRepositoryProtocol: Sendable {
    /// GET /users/me/notification-settings
    func fetchSettings() async throws -> NotificationSettings

    /// PUT /users/me/notification-settings
    func updateSettings(_ settings: NotificationSettings) async throws -> NotificationSettings
}
