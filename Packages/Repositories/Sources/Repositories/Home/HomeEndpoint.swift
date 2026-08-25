//
//  HomeEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 21/8/26.
//

// Dedicated endpoint for HomeRepository

import CoreModels
import CoreNetworking
import Foundation

enum HomeEndpoint: APIEndpoint {
    case continueReading
    case latestUpdates(page: Int)
    case ranking(range: RankingRange, sortBy: RankingSortBy, page: Int)
    case randomComments
    case randomYuri(type: SeriesType)

    var path: String {
        switch self {
        case .continueReading: return "/users/me/continue-reading"
        case .latestUpdates: return "/home/latest-updates"
        case .ranking: return "/home/ranking"
        case .randomComments: return "/home/random-comments"
        case .randomYuri: return "/home/random"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .continueReading, .randomComments:
            return nil
        case .latestUpdates(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .ranking(let range, let sortBy, let page):
            return [
                URLQueryItem(name: "range", value: range.rawValue),
                URLQueryItem(name: "sortBy", value: sortBy.rawValue),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .randomYuri(let type):
            return [URLQueryItem(name: "type", value: type.rawValue)]
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .continueReading: return true
        case .latestUpdates, .ranking, .randomComments, .randomYuri: return false
        }
    }
}
