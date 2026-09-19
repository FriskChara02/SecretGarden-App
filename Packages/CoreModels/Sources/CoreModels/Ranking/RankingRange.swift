//
//  RankingRange.swift
//  CoreModels
//
//  Created by Loi Nguyen on 21/8/26.
//

import Foundation

/// Ranking filter period on Home — matches the `range` query parameter of
/// `GET /home/ranking?range=day|week|month|all`.
public enum RankingRange: String, Codable, CaseIterable, Sendable {
    case day
    case week
    case month
    case all
}
