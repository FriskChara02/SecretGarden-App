//
//  AuthorEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreNetworking
import Foundation

enum AuthorEndpoint {
    case detail(id: String)
    case series(authorId: String)
    case follow(authorId: String)
    case unfollow(authorId: String)
    case notify(authorId: String, enabled: Bool)
}

extension AuthorEndpoint: APIEndpoint {
    var path: String {
        switch self {
        case .detail(let id): return "/authors/\(id)"
        case .series(let authorId): return "/authors/\(authorId)/series"
        case .follow(let authorId): return "/authors/\(authorId)/follow"
        case .unfollow(let authorId): return "/authors/\(authorId)/follow"
        case .notify(let authorId, _): return "/authors/\(authorId)/notify"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .detail, .series: return .get
        case .follow: return .post
        case .unfollow: return .delete
        case .notify: return .put
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
