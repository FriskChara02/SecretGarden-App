//
//  SearchHistoryItem.swift
//  CoreModels
//
//  Created by Loi Nguyen on 29/8/26.
//

// A pure domain model for a single search history item.
// It has NO knowledge of SwiftData or @Model — this is a mandatory rule for CoreModels
// (at the base of the dependency graph, independent of any specific persistence framework).

import Foundation

public struct SearchHistoryItem: Codable, Identifiable, Equatable {
    public let id: String
    public var query: String
    public var searchedAt: Date

    public init(id: String = UUID().uuidString, query: String, searchedAt: Date = Date()) {
        self.id = id
        self.query = query
        self.searchedAt = searchedAt
    }
}
