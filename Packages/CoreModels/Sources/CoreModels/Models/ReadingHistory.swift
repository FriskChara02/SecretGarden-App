//
//  ReadingHistory.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for READING_HISTORY

import Foundation

public struct ReadingHistoryItem: Codable, Identifiable, Equatable {
    public let id: String
    public var series: Series
    public var chapter: Chapter
    public var lastReadAt: Date
    public var lastPageRead: Int

    public init(id: String, series: Series, chapter: Chapter, lastReadAt: Date, lastPageRead: Int) {
        self.id = id
        self.series = series
        self.chapter = chapter
        self.lastReadAt = lastReadAt
        self.lastPageRead = lastPageRead
    }
}
