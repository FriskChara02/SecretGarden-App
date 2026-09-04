//
//  CommentRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 4/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

public final class CommentRepository: CommentRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchSeriesComments(seriesId: String, page: Int) async throws -> [Comment] {
        try await apiClient.request(CommentEndpoint.seriesComments(seriesId: seriesId, page: page))
    }

    public func fetchChapterComments(chapterId: String, page: Int) async throws -> [Comment] {
        try await apiClient.request(CommentEndpoint.chapterComments(chapterId: chapterId, page: page))
    }
}
