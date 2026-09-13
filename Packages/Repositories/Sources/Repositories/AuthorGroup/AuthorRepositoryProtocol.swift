//
//  AuthorRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

// Repository for ALL human roles associated with a series (Author, Artist, Translator, Editor...).
// Roles are attributes of the Series (Series.author, Series.artist...),
// NOT attributes of the Repository — a single protocol applies
// to every ID, regardless of the role assigned to that ID on the calling screen.


import CoreModels
import Foundation

public protocol AuthorRepositoryProtocol {
    /// Details for one person (Author/Artist) - `GET /authors/{id}`.
    func fetchAuthorDetail(id: String) async throws -> AuthorGroupCommon

    /// This user's list of stories - `GET /authors/{id}/series`.
    func fetchAuthorSeries(authorId: String, page: Int) async throws -> [Series]

    /// Follow/Unfollow - `POST /authors/{id}/follow` / `DELETE`.
    func toggleFollow(authorId: String, isFollowing: Bool) async throws

    /// Toggle individual notifications - ONLY called when already following (business logic constraint;
    /// enforced at the ViewModel layer, not the Repository).
    /// `PUT /authors/{id}/notify`.
    func toggleNotify(authorId: String, enabled: Bool) async throws
}
