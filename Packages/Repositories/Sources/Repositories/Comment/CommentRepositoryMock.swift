//
//  CommentRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 4/9/26.
//

import CoreModels
import Foundation

public actor CommentRepositoryMock: CommentRepositoryProtocol {

    private let seriesComments: [Comment]
    private let chapterComments: [Comment]

    public init() {
        let user1 = User(id: "u1", username: "Thác Lác Cá", email: "a@a.com", joinedAt: Date())
        let user2 = User(id: "u2", username: "TÔI YÊU YURI", email: "b@a.com", joinedAt: Date())
        let user3 = User(id: "u3", username: "Nugget undefined", email: "c@a.com", joinedAt: Date())
        let user4 = User(id: "u4", username: "Giophieuluu", email: "d@a.com", joinedAt: Date())

        self.seriesComments = [
            Comment(
                id: "c1", user: user1,
                content: "Có thể nói khóc hết 70% cơ thể khi thấy bộ này và Yurineko trở lại 😭",
                likeCount: 8, isLikedByMe: false,
                createdAt: Date().addingTimeInterval(-120 * 86_400),
                seriesId: "series-1"
            ),
            Comment(
                id: "c2", user: user2,
                content: "Yes yes yes huhu đợi bữa giờ",
                likeCount: 4, isLikedByMe: false,
                createdAt: Date().addingTimeInterval(-150 * 86_400),
                seriesId: "series-1"
            )
        ]

        self.chapterComments = [
            Comment(
                id: "cc1", user: user3,
                content: "Bà sếp ủ mưu húp phù thuỷ à=))",
                likeCount: 11, isLikedByMe: false,
                createdAt: Date().addingTimeInterval(-26 * 86_400),
                replies: [
                    Comment(
                        id: "cc1-r1", user: user4,
                        content: "@Nugget undefined Đúng đúng",
                        likeCount: 1, isLikedByMe: false,
                        createdAt: Date().addingTimeInterval(-22 * 86_400)
                    )
                ],
                seriesId: "series-1", seriesTitle: "Đồ Ăn Của Ta Trông Thật Đáng Yêu"
            )
        ]
    }

    public func fetchSeriesComments(seriesId: String, page: Int) async throws -> [Comment] {
        page == 1 ? seriesComments : []
    }

    public func fetchChapterComments(chapterId: String, page: Int) async throws -> [Comment] {
        page == 1 ? chapterComments : []
    }
}
