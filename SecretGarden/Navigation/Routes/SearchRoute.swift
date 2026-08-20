//
//  SearchRoute.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import Foundation

enum SearchRoute: Hashable {
    case searchResults(query: String)
    case seriesDetail(id: String)
}
