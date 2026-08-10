//
//  ReadingStatus.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model cho READING_STATUS

import Foundation

public enum ReadingStatus: String, Codable, CaseIterable {
    /// Plan to read
    case planToRead
    /// Currently reading
    case reading
    /// Completed
    case completed
    /// Dropped
    case dropped
}

public struct ReadingStatusItem: Codable, Identifiable, Equatable {
    public let id: String
    public var series: Series
    public var status: ReadingStatus
    public var notifyNewChapter: Bool
    public var updatedAt: Date

    public init(id: String, series: Series, status: ReadingStatus, notifyNewChapter: Bool = false, updatedAt: Date) {
        self.id = id
        self.series = series
        self.status = status
        self.notifyNewChapter = notifyNewChapter
        self.updatedAt = updatedAt
    }
}
