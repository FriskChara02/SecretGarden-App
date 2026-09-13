//
//  CommentRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 4/9/26.
//

// The repository for the Comment domain.

import CoreModels
import Foundation

public protocol CommentRepositoryProtocol {
    /// Comments for the entire series (Detail) - corresponds to `GET /series/{id}/comments?page=`.
    func fetchSeriesComments(seriesId: String, page: Int) async throws -> [Comment]

    /// Chapter-specific comments (Reader overlay) - Completely separate from the
    /// story-wide comments above, even though they share the same `Comment` struct.
    func fetchChapterComments(chapterId: String, page: Int) async throws -> [Comment]

    /// Post a new comment for the entire series — `POST /series/{id}/comments`.
    /// The server returns the full comment (including user).
    func postSeriesComment(seriesId: String, content: String) async throws -> Comment

    /// Post a comment for a specific chapter - `POST /chapters/{id}/comments`.
    func postChapterComment(chapterId: String, content: String) async throws -> Comment

    func toggleLike(commentId: String, isLiked: Bool) async throws

    /// Reply to a top-level comment - `POST /comments/{id}/reply`.
    func postReply(parentCommentId: String, content: String) async throws -> Comment
}
