//
//  NotificationSettings.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import Foundation

public struct NotificationSettings: Codable, Equatable, Sendable {
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
