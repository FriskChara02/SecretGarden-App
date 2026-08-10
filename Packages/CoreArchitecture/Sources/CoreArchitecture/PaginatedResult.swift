//
//  PaginatedResult.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// A shared pagination type for all Repository
// Lists such as comments, rankings, search results, and notifications
// require cursor- or page-based pagination. Instead of each Repository
// defining its own pagination format, use this shared generic type
// to standardize how ViewModels handle "load more" operations.

import Foundation

public struct PaginatedResult<T: Codable & Equatable>: Codable, Equatable {
    public let items: [T]
    public let currentPage: Int
    public let totalPages: Int
    public let totalItems: Int

    public init(items: [T], currentPage: Int, totalPages: Int, totalItems: Int) {
        self.items = items
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
    }

    /// ViewModel utility: whether there is a next page to load
    public var hasNextPage: Bool {
        currentPage < totalPages
    }
}
