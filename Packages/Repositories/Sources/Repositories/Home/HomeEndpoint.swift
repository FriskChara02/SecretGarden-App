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
    case ranking(range: RankingRange, page: Int)
    case randomComments

    var path: String {
        switch self {
        case .continueReading:
            return "/users/me/continue-reading"
        case .latestUpdates:
            return "/home/latest-updates"
        case .ranking:
            return "/home/ranking"
        case .randomComments:
            return "/home/random-comments"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .continueReading, .randomComments:
            return nil
        case .latestUpdates(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .ranking(let range, let page):
            return [
                URLQueryItem(name: "range", value: range.rawValue),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .continueReading:
            // "GET /users/me/continue-reading" — chỉ có nghĩa khi đã đăng nhập.
            return true
        case .latestUpdates, .ranking, .randomComments:
            // Guest mode: xem Home công khai không cần đăng nhập (System Design mục 10, điểm 7).
            return false
        }
    }
}
