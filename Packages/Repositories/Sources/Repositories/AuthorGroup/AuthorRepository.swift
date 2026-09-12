//
//  AuthorRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

public final class AuthorRepository: AuthorRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchAuthorDetail(id: String) async throws -> AuthorGroupCommon {
        try await apiClient.request(AuthorEndpoint.detail(id: id))
    }

    public func fetchAuthorSeries(authorId: String) async throws -> [Series] {
        try await apiClient.request(AuthorEndpoint.series(authorId: authorId))
    }

    public func toggleFollow(authorId: String, isFollowing: Bool) async throws {
        let endpoint: AuthorEndpoint = isFollowing ? .follow(authorId: authorId) : .unfollow(authorId: authorId)
        try await apiClient.requestWithoutResponse(endpoint)
    }

    public func toggleNotify(authorId: String, enabled: Bool) async throws {
        try await apiClient.requestWithoutResponse(AuthorEndpoint.notify(authorId: authorId, enabled: enabled))
    }
}
