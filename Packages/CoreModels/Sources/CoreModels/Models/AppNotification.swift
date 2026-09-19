//
//  AppNotification.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for NOTIFICATIONS, NOTIFICATION_SETTINGS
// Named "AppNotification" instead of "Notification" to avoid a naming conflict
// with `Foundation.Notification` (NotificationCenter) - preventing confusion upon import

import Foundation

public struct AppNotification: Codable, Identifiable, Equatable {
    public let id: String
    public var type: NotificationType
    public var title: String
    public var body: String
    public var referenceId: String?
    public var isRead: Bool
    public var createdAt: Date

    public init(
        id: String,
        type: NotificationType,
        title: String,
        body: String,
        referenceId: String? = nil,
        isRead: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.referenceId = referenceId
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

public enum NotificationType: String, Codable {
    case newChapter, commentReply, commentLike, mention
}
