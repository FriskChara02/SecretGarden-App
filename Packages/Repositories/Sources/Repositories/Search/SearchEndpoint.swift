//
//  SearchEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

// Endpoint for basic and advanced search

import CoreModels
import CoreNetworking
import Foundation

enum SearchEndpoint: APIEndpoint {
    case basicSearch(query: String, page: Int)
    case advancedSearch(filter: AdvancedFilterRequest, page: Int)

    // TODO(server): server-side search history endpoint,
    // placed here to follow the "local first, server code later" requirement—simply wire it up
    // to SearchRepository when needed, without redesigning from scratch.
    // case remoteHistory
    // case deleteRemoteHistory(id: String)

    var path: String {
        switch self {
        case .basicSearch: return "/search"
        case .advancedSearch: return "/search/advanced"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .basicSearch: return .get
        case .advancedSearch: return .post
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .basicSearch(let query, let page):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .advancedSearch(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        }
    }

    var body: Data? {
        switch self {
        case .basicSearch:
            return nil
        case .advancedSearch(let filter, _):
            return try? JSONEncoder().encode(filter)
        }
    }

    var requiresAuth: Bool { false }
}
