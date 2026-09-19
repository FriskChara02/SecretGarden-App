//
//  AdvancedFilterOptions.swift
//  CoreModels
//
//  Created by Loi Nguyen on 30/8/26.
//

// Collect the complete list of sources for the multi-select dropdowns in AdvancedFilterView.
// Authors and Artists share the AuthorGroupCommon type.

import Foundation

public struct AdvancedFilterOptions: Codable, Equatable {
    public var tags: [Tag]
    public var authors: [AuthorGroupCommon]
    public var artists: [AuthorGroupCommon]
    public var pairings: [Pairing]
    public var groups: [TranslationGroup]

    public init(
        tags: [Tag] = [],
        authors: [AuthorGroupCommon] = [],
        artists: [AuthorGroupCommon] = [],
        pairings: [Pairing] = [],
        groups: [TranslationGroup] = []
    ) {
        self.tags = tags
        self.authors = authors
        self.artists = artists
        self.pairings = pairings
        self.groups = groups
    }
}
