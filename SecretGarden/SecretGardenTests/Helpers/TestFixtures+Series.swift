//
//  TestFixtures+Series.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreModels
import Foundation

extension TestFixtures {

    static func series(
        id: String = "s1",
        favoriteCount: Int = 10,
        isFavoritedByMe: Bool = false,
        isNotifyEnabled: Bool = false,
        readingStatus: ReadingStatus? = nil
    ) -> Series {
        Series(
            id: id,
            title: "Test Series",
            originalTitle: "Original Title",
            type: .manga,
            coverURL: URL(fileURLWithPath: "/cover.jpg"),
            description: "Description",
            status: .ongoing,
            author: AuthorGroupCommon(id: "a1", name: "Author"),
            group: TranslationGroup(id: "g1", name: "Group", followerCount: 1),
            genres: [Genre(id: "gn1", name: "Yuri")],
            viewCount: 100,
            favoriteCount: favoriteCount,
            updatedAt: Date(),
            chapters: [],
            latestChapterLabel: "Chương 1",
            isFavoritedByMe: isFavoritedByMe,
            isNotifyEnabled: isNotifyEnabled,
            readingStatus: readingStatus,
            artist: AuthorGroupCommon(id: "ar1", name: "Artist")
        )
    }

    /// Chapter 1...count, each chapter has an ID "c<number>".
    static func chapters(count: Int, seriesId: String = "s1") -> [Chapter] {
        (0..<count).map { index in
            Chapter(
                id: "c\(index + 1)",
                seriesId: seriesId,
                chapterNumber: Double(index + 1),
                releasedAt: Date()
            )
        }
    }
}
