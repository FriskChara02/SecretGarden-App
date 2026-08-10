//
//  Favorite.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for FAVORITES

import Foundation

public struct FavoriteItem: Codable, Identifiable, Equatable {
    public let id: String
    public var series: Series
    public var createdAt: Date

    public init(id: String, series: Series, createdAt: Date) {
        self.id = id
        self.series = series
        self.createdAt = createdAt
    }
}
