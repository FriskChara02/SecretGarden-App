//
//  RankingSortBy.swift
//  CoreModels
//
//  Created by Loi Nguyen on 24/8/26.
//

// RankingSortBy supports "Views" / "Favorites".

import Foundation

public enum RankingSortBy: String, Codable, CaseIterable, Sendable {
    case views
    case favorites
}
