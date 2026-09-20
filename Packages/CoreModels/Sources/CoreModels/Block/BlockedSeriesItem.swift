//
//  BlockedSeriesItem.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import Foundation

public struct BlockedSeriesItem: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public var series: Series
    public var blockedAt: Date

    public init(id: String, series: Series, blockedAt: Date) {
        self.id = id
        self.series = series
        self.blockedAt = blockedAt
    }
}
