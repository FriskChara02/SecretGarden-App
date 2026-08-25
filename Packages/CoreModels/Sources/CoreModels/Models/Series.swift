//
//  Series.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for SERIES, GENRES, SERIES_GENRES

import Foundation

public struct Series: Codable, Identifiable, Equatable {
    public let id: String
    public var title: String
    public var originalTitle: String?
    public var type: SeriesType
    public var coverURL: URL
    public var description: String
    public var status: SeriesStatus
    public var author: AuthorGroupCommon?
    public var group: TranslationGroup?
    public var genres: [Genre]
    public var viewCount: Int
    public var favoriteCount: Int
    public var updatedAt: Date
    public var chapters: [Chapter]?
    public var latestChapterLabel: String?

    public init(
        id: String,
        title: String,
        originalTitle: String? = nil,
        type: SeriesType,
        coverURL: URL,
        description: String,
        status: SeriesStatus,
        author: AuthorGroupCommon? = nil,
        group: TranslationGroup? = nil,
        genres: [Genre] = [],
        viewCount: Int = 0,
        favoriteCount: Int = 0,
        updatedAt: Date,
        chapters: [Chapter]? = nil,
        latestChapterLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.type = type
        self.coverURL = coverURL
        self.description = description
        self.status = status
        self.author = author
        self.group = group
        self.genres = genres
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
        self.updatedAt = updatedAt
        self.chapters = chapters
        self.latestChapterLabel = latestChapterLabel
    }
}

public enum SeriesType: String, Codable {
    case manga, novel, doujinshi
}

public enum SeriesStatus: String, Codable {
    case ongoing, completed
}

public struct Genre: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
