//
//  TagPairing.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for TAGS, PAIRINGS, SERIES_TAGS, SERIES_PAIRINGS — used for Advanced Filter

import Foundation

public struct Tag: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var category: String?

    public init(id: String, name: String, category: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
    }
}

public struct Pairing: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/// Request body for `POST /search/advanced` — supports two-way Include/Exclude filtering (emphasizing that this is a multi-faceted filter, not a simple AND operation).
public struct AdvancedFilterRequest: Codable, Equatable {
    public var includeTags: [String]
    public var excludeTags: [String]
    public var includeAuthors: [String]
    public var excludeAuthors: [String]
    public var includeArtists: [String]
    public var excludeArtists: [String]
    public var includePairings: [String]
    public var excludePairings: [String]
    public var includeGroups: [String]
    public var excludeGroups: [String]
    /// "latest_update" / "newest" / "oldest" / "views" / "follows"
    public var sort: String

    public init(
        includeTags: [String] = [],
        excludeTags: [String] = [],
        includeAuthors: [String] = [],
        excludeAuthors: [String] = [],
        includeArtists: [String] = [],
        excludeArtists: [String] = [],
        includePairings: [String] = [],
        excludePairings: [String] = [],
        includeGroups: [String] = [],
        excludeGroups: [String] = [],
        sort: String = "latest_update"
    ) {
        self.includeTags = includeTags
        self.excludeTags = excludeTags
        self.includeAuthors = includeAuthors
        self.excludeAuthors = excludeAuthors
        self.includeArtists = includeArtists
        self.excludeArtists = excludeArtists
        self.includePairings = includePairings
        self.excludePairings = excludePairings
        self.includeGroups = includeGroups
        self.excludeGroups = excludeGroups
        self.sort = sort
    }
}
