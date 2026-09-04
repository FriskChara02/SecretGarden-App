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
}
