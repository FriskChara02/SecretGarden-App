//
//  CommentEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 4/9/26.
//

import CoreNetworking
import Foundation

enum CommentEndpoint: APIEndpoint {
    case seriesComments(seriesId: String, page: Int)
    case chapterComments(chapterId: String, page: Int)

    var path: String {
        switch self {
        case .seriesComments(let seriesId, _):
            return "/series/\(seriesId)/comments"
        case .chapterComments(let chapterId, _):
            return "/chapters/\(chapterId)/comments"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .seriesComments(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .chapterComments(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        }
    }

    var requiresAuth: Bool {
        // View comments without logging in (Guest mode) - login is only required to post or like.
        false
    }
}
