//
//  SeriesRepositoryProtocol.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Contract for all data operations related to Series
// This is a sample Repository
// Project pattern — other Repository (AuthRepository, CommentRepository,
// NotificationRepository...) will be defined following this exact template
// Mandatory rule: every implementation of this protocol MUST only throw AppError
// (mapped from original CoreNetworking/CoreStorage errors); URLError,
// DecodingError, etc., must not be exposed outside the Repository.

import CoreModels
import Foundation

public protocol SeriesRepositoryProtocol {
    /// Fetch details for a specific series — corresponds to `GET /series/{id}`.
    func fetchSeriesDetail(id: String) async throws -> Series

    /// Fetch the list of chapters for a series — corresponds to `GET /series/{id}/chapters`.
    func fetchChapters(seriesId: String) async throws -> [Chapter]

    /// Fetch related series recommendations — corresponds to `GET /series/{id}/related`.
    func fetchRelatedSeries(seriesId: String) async throws -> [Series]

    /// Toggle favorite status — corresponds to `POST /series/{id}/favorite` / `DELETE ...`.
    /// - Parameters:
    ///   - seriesId: The series ID.
    ///   - isFavorited: The desired state after the call (true = add to favorites,
    ///     false = remove from favorites) — The ViewModel determines the target state;
    ///     the Repository is only responsible for calling the appropriate API.
    func toggleFavorite(seriesId: String, isFavorited: Bool) async throws
}
