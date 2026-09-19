//
//  BlockedTagItem.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import Foundation

public struct BlockedTagItem: Codable, Identifiable, Sendable {
    public let id: String
    public var tag: Tag
    public var blockedAt: Date

    public init(id: String, tag: Tag, blockedAt: Date) {
        self.id = id
        self.tag = tag
        self.blockedAt = blockedAt
    }
}
