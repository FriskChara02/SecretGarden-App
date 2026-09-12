//
//  GroupSeriesCardMapper.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 12/9/26.
//

// Map Series (Core Models) to SeriesCardData (Design System) — reserved for Social Feature.

import CoreModels
import DesignSystem
import Foundation

enum GroupSeriesCardMapper {

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .short
        return formatter
    }()

    static func map(_ series: Series) -> SeriesCardData {
        SeriesCardData(
            id: series.id,
            coverURL: series.coverURL,
            title: series.title,
            authorName: series.author?.name,
            groupName: series.group?.name,
            genres: series.genres.map { $0.name },
            metaInfo: "Cập nhật \(relativeFormatter.localizedString(for: series.updatedAt, relativeTo: Date()))",
            chapterLabel: series.latestChapterLabel,
            isCompleted: series.status == .completed
        )
    }
}
