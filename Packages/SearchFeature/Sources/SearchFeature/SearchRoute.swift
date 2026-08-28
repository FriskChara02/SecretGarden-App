//
//  SearchRoute.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 28/8/26.
//

import Foundation

/// Navigation routes for the entire Search tab.
/// Used by the app target (Composition Root) to initialize `Coordinator<SearchRoute>`,
/// so the enum and all its cases must be `public`.
public enum SearchRoute: Hashable {
    case searchResults(query: String)
    case seriesDetail(id: String)
}
