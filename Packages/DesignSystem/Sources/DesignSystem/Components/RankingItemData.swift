//
//  RankingItemData.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 12/9/26.
//

// Pure ViewData for DSRankingSection/DSRankingRow

import Foundation

public struct RankingItemData: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let coverURL: URL?
    public let authorName: String?
    public let chapterLabel: String?
    public let viewCount: Int
    public let favoriteCount: Int

    public init(
        id: String,
        title: String,
        coverURL: URL?,
        authorName: String? = nil,
        chapterLabel: String? = nil,
        viewCount: Int,
        favoriteCount: Int
    ) {
        self.id = id
        self.title = title
        self.coverURL = coverURL
        self.authorName = authorName
        self.chapterLabel = chapterLabel
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
    }
}

public enum DSRankingSortBy: Equatable {
    case views
    case favorites
}

public enum DSRankingRange: Equatable {
    case day, week, month, all
}
