//
//  ContinueReading.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for the "Continue Reading" section on the Home screen — data sourced from READING_HISTORY,
// but includes totalPages to calculate the progress percentage displayed on the Home card.

import Foundation

public struct ContinueReadingItem: Codable, Identifiable, Equatable {
    public let id: String
    public var series: Series
    public var chapter: Chapter
    public var lastPageRead: Int
    public var totalPages: Int

    public init(id: String, series: Series, chapter: Chapter, lastPageRead: Int, totalPages: Int) {
        self.id = id
        self.series = series
        self.chapter = chapter
        self.lastPageRead = lastPageRead
        self.totalPages = totalPages
    }
}
