//
//  GroupEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

enum GroupEndpoint {
    case detail(id: String)
    case series(groupId: String, page: Int)
    case members(groupId: String)
    case highlights(groupId: String, sortBy: RankingSortBy, range: RankingRange)
    case follow(groupId: String)
    case unfollow(groupId: String)
    case notify(groupId: String, enabled: Bool)
    case discover(query: String, sort: GroupDiscoverSort, page: Int)
    case followedGroups
}

extension GroupEndpoint: APIEndpoint {
    var path: String {
        switch self {
        case .detail(let id): return "/groups/\(id)"
        case .series(let groupId, _): return "/groups/\(groupId)/series"
        case .members(let groupId): return "/groups/\(groupId)/members"
        case .highlights(let groupId, _, _): return "/groups/\(groupId)/highlights"
        case .follow(let groupId): return "/groups/\(groupId)/follow"
        case .unfollow(let groupId): return "/groups/\(groupId)/follow"
        case .notify(let groupId, _): return "/groups/\(groupId)/notify"
        case .discover: return "/groups/discover"
        case .followedGroups: return "/users/me/followed-groups"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .detail, .series, .members, .highlights, .discover, .followedGroups: return .get
        case .follow: return .post
        case .unfollow: return .delete
        case .notify: return .put
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .series(_, let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .highlights(_, let sortBy, let range):
            return [
                URLQueryItem(name: "sort", value: sortBy.rawValue),
                URLQueryItem(name: "range", value: range.rawValue)
            ]
        case .discover(let query, let sort, let page):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sort.rawValue),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .notify(_, let enabled):
            return try? JSONEncoder().encode(["enabled": enabled])
        default:
            return nil
        }
    }
}
