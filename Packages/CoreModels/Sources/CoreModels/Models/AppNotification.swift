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

public struct NotificationSettings: Codable, Equatable {
    public var pushEnabled: Bool
    public var followedSeriesNewChapter: Bool
    public var followedGroupNewChapter: Bool
    public var commentReply: Bool
    public var commentLike: Bool
    public var mention: Bool

    public init(
        pushEnabled: Bool = true,
        followedSeriesNewChapter: Bool = true,
        followedGroupNewChapter: Bool = true,
        commentReply: Bool = true,
        commentLike: Bool = true,
        mention: Bool = true
    ) {
        self.pushEnabled = pushEnabled
        self.followedSeriesNewChapter = followedSeriesNewChapter
        self.followedGroupNewChapter = followedGroupNewChapter
        self.commentReply = commentReply
        self.commentLike = commentLike
        self.mention = mention
    }
}
