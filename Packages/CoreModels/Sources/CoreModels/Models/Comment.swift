//
//  Comment.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for COMMENTS – supports nested replies (self-referencing via `parent_comment_id` in the database, represented in Swift as `replies: [Comment]?`)
// Swift allows a struct to contain an array of itself because arrays store elements in a
// separately allocated heap buffer—unlike `indirect` enum cases, the `indirect` keyword is not required here

import Foundation

public struct Comment: Codable, Identifiable, Equatable {
    public let id: String
    public var user: User
    public var content: String
    public var imageURL: URL?
    public var likeCount: Int
    public var isLikedByMe: Bool
    public var createdAt: Date
    public var replies: [Comment]?
    public var seriesId: String?
    public var seriesTitle: String?

    public init(
        id: String,
        user: User,
        content: String,
        imageURL: URL? = nil,
        likeCount: Int = 0,
        isLikedByMe: Bool = false,
        createdAt: Date,
        replies: [Comment]? = nil,
        seriesId: String? = nil,
        seriesTitle: String? = nil
    ) {
        self.id = id
        self.user = user
        self.content = content
        self.imageURL = imageURL
        self.likeCount = likeCount
        self.isLikedByMe = isLikedByMe
        self.createdAt = createdAt
        self.replies = replies
        self.seriesId = seriesId
        self.seriesTitle = seriesTitle
    }
}
