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

    // MARK: - Series Detail & Reader

    /// List of images in a chapter - corresponds to `GET /chapters/{id}/pages`.
    func fetchChapterPages(chapterId: String) async throws -> [ChapterPage]

    /// Record reading progress (current page) - `POST /chapters/{id}/read`.
    /// `seriesId` is passed even though the actual endpoint doesn't require it, because future features
    /// (such as "Continue Reading" on the Home screen) might need local caching based on series-chapter pairs.
    func recordReadingProgress(seriesId: String, chapterId: String, page: Int) async throws

    /// Update "Yuri list" status (Plan to Read/Reading/Completed/Dropped) - `PUT /users/me/reading-status/{seriesId}`.
    func updateReadingStatus(seriesId: String, status: ReadingStatus, notifyNewChapter: Bool) async throws

    /// Toggle "Receive notifications" for a specific series - `PUT /series/{id}/notify`.
    func toggleNotify(seriesId: String, enabled: Bool) async throws

    /// Submit a violation report for a story/chapter - `POST /reports`.
    func submitReport(_ request: ReportRequest) async throws

    /// Remove story from Yuri list (set status to "unfollow")
    func removeReadingStatus(seriesId: String) async throws
}
