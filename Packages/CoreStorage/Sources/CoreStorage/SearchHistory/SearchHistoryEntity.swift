//
//  SearchHistoryEntity.swift
//  CoreStorage
//
//  Created by Loi Nguyen on 29/8/26.
//

// SwiftData persistent model — for internal use within CoreStorage only.
// Do NOT public this package: the upper layer (Repositories) must not
// directly handle a SwiftData object; instead, it receives only SearchHistoryItem via SearchHistoryLocalStore.

import Foundation
import SwiftData

@Model
final class SearchHistoryEntity {
    @Attribute(.unique) var id: String
    var query: String
    var searchedAt: Date

    init(id: String, query: String, searchedAt: Date) {
        self.id = id
        self.query = query
        self.searchedAt = searchedAt
    }
}
