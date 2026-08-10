//
//  UserList.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for USER_LISTS, USER_LIST_ITEMS – custom playlists, DISTINCT from ReadingStatus

import Foundation

public struct UserList: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var isPublic: Bool
    public var items: [Series]?

    public init(id: String, name: String, isPublic: Bool = false, items: [Series]? = nil) {
        self.id = id
        self.name = name
        self.isPublic = isPublic
        self.items = items
    }
}
