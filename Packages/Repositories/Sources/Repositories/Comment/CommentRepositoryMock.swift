//
//  CommentRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 4/9/26.
//

import CoreModels
import Foundation

public actor CommentRepositoryMock: CommentRepositoryProtocol {

    private var seriesComments: [Comment]
    private var chapterComments: [Comment]

    /// Mock user for NEW comments/replies posted during the mock session
    private let mockCurrentUser = User(
        id: "mock-current-user", username: "Bạn", email: "you@example.com", joinedAt: Date()
    )

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

    public func postSeriesComment(seriesId: String, content: String) async throws -> Comment {
        let newComment = Comment(
            id: "mock-comment-\(UUID().uuidString.prefix(8))",
            user: mockCurrentUser,
            content: content,
            likeCount: 0,
            isLikedByMe: false,
            createdAt: Date(),
            seriesId: seriesId
        )
        seriesComments.insert(newComment, at: 0)
        return newComment
    }

    public func postChapterComment(chapterId: String, content: String) async throws -> Comment {
        let newComment = Comment(
            id: "mock-chapter-comment-\(UUID().uuidString.prefix(8))",
            user: mockCurrentUser,
            content: content,
            likeCount: 0,
            isLikedByMe: false,
            createdAt: Date()
        )
        chapterComments.insert(newComment, at: 0)
        return newComment
    }

    public func toggleLike(commentId: String, isLiked: Bool) async throws {
        updateCommentInPlace(commentId: commentId, in: &seriesComments) { comment in
            comment.isLikedByMe = isLiked
            comment.likeCount += isLiked ? 1 : -1
        }
        updateCommentInPlace(commentId: commentId, in: &chapterComments) { comment in
            comment.isLikedByMe = isLiked
            comment.likeCount += isLiked ? 1 : -1
        }
    }

    public func postReply(parentCommentId: String, content: String) async throws -> Comment {
        let newReply = Comment(
            id: "mock-reply-\(UUID().uuidString.prefix(8))",
            user: mockCurrentUser,
            content: content,
            likeCount: 0,
            isLikedByMe: false,
            createdAt: Date()
        )
        appendReply(newReply, toParent: parentCommentId, in: &seriesComments)
        appendReply(newReply, toParent: parentCommentId, in: &chapterComments)
        return newReply
    }

    // MARK: - Private helpers (Find and edit a comment nested within an array, supports only one level of replies - matching the current UI)

    private func updateCommentInPlace(commentId: String, in comments: inout [Comment], mutate: (inout Comment) -> Void) {
        for index in comments.indices {
            if comments[index].id == commentId {
                mutate(&comments[index])
                return
            }
            if var replies = comments[index].replies {
                for replyIndex in replies.indices where replies[replyIndex].id == commentId {
                    mutate(&replies[replyIndex])
                    comments[index].replies = replies
                    return
                }
            }
        }
    }

    private func appendReply(_ reply: Comment, toParent parentId: String, in comments: inout [Comment]) {
        for index in comments.indices where comments[index].id == parentId {
            var replies = comments[index].replies ?? []
            replies.append(reply)
            comments[index].replies = replies
            return
        }
    }
}
