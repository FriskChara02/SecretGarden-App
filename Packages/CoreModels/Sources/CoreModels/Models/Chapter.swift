//
//  Chapter.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for CHAPTERS, CHAPTER_PAGES

import Foundation

public struct Chapter: Codable, Identifiable, Equatable {
    public let id: String
    public var seriesId: String
    public var chapterNumber: Double
    public var title: String?
    public var releasedAt: Date
    public var viewCount: Int
    public var isRead: Bool
    public var pageCount: Int

    public init(
        id: String,
        seriesId: String,
        chapterNumber: Double,
        title: String? = nil,
        releasedAt: Date,
        viewCount: Int = 0,
        isRead: Bool = false,
        pageCount: Int = 0
    ) {
        self.id = id
        self.seriesId = seriesId
        self.chapterNumber = chapterNumber
        self.title = title
        self.releasedAt = releasedAt
        self.viewCount = viewCount
        self.isRead = isRead
        self.pageCount = pageCount
    }
}

public struct ChapterPage: Codable, Identifiable, Equatable {
    public let id: String
    public var pageNumber: Int
    public var imageURL: URL

    public init(id: String, pageNumber: Int, imageURL: URL) {
        self.id = id
        self.pageNumber = pageNumber
        self.imageURL = imageURL
    }
}
