//
//  AuthorRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

// Production-grade mock for Debug/Staging
// Implemented as an actor because follow/notify operations require maintaining state across calls during the runtime session.


import CoreModels
import CoreArchitecture
import Foundation

public actor AuthorRepositoryMock: AuthorRepositoryProtocol {

    private var authors: [String: AuthorGroupCommon]
    private let seriesByAuthorId: [String: [Series]]

    public init() {
        var seedAuthors: [String: AuthorGroupCommon] = [:]

        seedAuthors["author-1"] = AuthorGroupCommon(
            id: "author-1",
            name: "Radish",
            avatarURL: URL(string: "https://picsum.photos/seed/author-1/200/200"),
            socialLink: "https://x.com/radish_sample",
            bio: nil, // No description yet - empty state
            isFollowedByMe: false,
            isNotifyEnabled: false
        )

        seedAuthors["artist-1"] = AuthorGroupCommon(
            id: "artist-1",
            name: "Radish",
            avatarURL: URL(string: "https://picsum.photos/seed/artist-1/200/200"),
            socialLink: nil,
            bio: "Hoạ sĩ tự do, yêu thích vẽ các nhân vật fantasy.",
            isFollowedByMe: true,
            isNotifyEnabled: true
        )

        self.authors = seedAuthors

        self.seriesByAuthorId = [
            "author-1": [],
            "artist-1": []
        ] // TODO: Add a real mock Series when implementing AuthorProfileView to avoid duplicating work.
    }

    public func fetchAuthorDetail(id: String) async throws -> AuthorGroupCommon {
        guard let author = authors[id] else {
            throw AppError.notFound
        }
        return author
    }

    public func fetchAuthorSeries(authorId: String, page: Int) async throws -> [Series] {
        seriesByAuthorId[authorId] ?? []
    }

    public func toggleFollow(authorId: String, isFollowing: Bool) async throws {
        authors[authorId]?.isFollowedByMe = isFollowing
        if !isFollowing {
            authors[authorId]?.isNotifyEnabled = false // Unfollowing automatically disables notifications — business logic.
        }
    }

    public func toggleNotify(authorId: String, enabled: Bool) async throws {
        authors[authorId]?.isNotifyEnabled = enabled
    }
}
