//
//  HomeRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 21/8/26.
//

// Contract for all data operations of the Home tab.
// 4 independent methods (instead of a single "fetchHomeBundle" method) because each section has
// its own loading lifecycle (changing the Ranking filter shouldn't re-fetch "Continue Reading").

import CoreModels
import Foundation

public protocol HomeRepositoryProtocol {
    /// `GET /users/me/continue-reading` - "Continue reading" section.
    func fetchContinueReading() async throws -> [ContinueReadingItem]

    /// `GET /home/latest-updates?page=` - "Recently updated" section.
    func fetchLatestUpdates(page: Int) async throws -> [Series]

    /// `GET /home/ranking?range=&page=` - "Rankings" section.
    func fetchRanking(range: RankingRange, page: Int) async throws -> [Series]

    /// `GET /home/random-comments` -"Random Comments" section.
    func fetchRandomComments() async throws -> [Comment]
}
