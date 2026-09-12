//
//  GroupHighlightMapper.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreModels
import DesignSystem
import Foundation

enum GroupHighlightMapper {
    static func map(_ series: Series) -> RankingItemData {
        RankingItemData(
            id: series.id,
            title: series.title,
            coverURL: series.coverURL,
            authorName: series.author?.name,
            chapterLabel: series.latestChapterLabel,
            viewCount: series.viewCount,
            favoriteCount: series.favoriteCount
        )
    }

    static func map(_ sortBy: RankingSortBy) -> DSRankingSortBy {
        sortBy == .views ? .views : .favorites
    }

    static func map(_ dsSortBy: DSRankingSortBy) -> RankingSortBy {
        dsSortBy == .views ? .views : .favorites
    }

    static func map(_ range: RankingRange) -> DSRankingRange {
        switch range {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .all: return .all
        }
    }

    static func map(_ dsRange: DSRankingRange) -> RankingRange {
        switch dsRange {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .all: return .all
        }
    }
}
