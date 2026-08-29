//
//  SearchSeriesCardMapper.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 29/8/26.
//

// Map Series (CoreModels) to SeriesCardData (DesignSystem) — reserved for SearchFeature.

import CoreModels
import DesignSystem
import Foundation

enum SearchSeriesCardMapper {

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
