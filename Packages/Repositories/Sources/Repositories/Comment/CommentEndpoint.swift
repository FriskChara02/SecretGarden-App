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
    case postSeriesComment(seriesId: String, content: String)
    case postChapterComment(chapterId: String, content: String)
    case toggleLike(commentId: String, isLiked: Bool)
    case postReply(parentCommentId: String, content: String)

    var path: String {
        switch self {
        case .seriesComments(let seriesId, _):
            return "/series/\(seriesId)/comments"
        case .chapterComments(let chapterId, _):
            return "/chapters/\(chapterId)/comments"
        case .postSeriesComment(let seriesId, _):
            return "/series/\(seriesId)/comments"
        case .postChapterComment(let chapterId, _):
            return "/chapters/\(chapterId)/comments"
        case .toggleLike(let commentId, _):
            return "/comments/\(commentId)/like"
        case .postReply(let parentCommentId, _):
            return "/comments/\(parentCommentId)/reply"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .seriesComments, .chapterComments:
            return .get
        case .postSeriesComment, .postChapterComment, .postReply:
            return .post
        case .toggleLike(_, let isLiked):
            return isLiked ? .post : .delete
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .seriesComments(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .chapterComments(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .postSeriesComment(_, let content), .postChapterComment(_, let content), .postReply(_, let content):
            return try? JSONEncoder().encode(["content": content])
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .seriesComments, .chapterComments:
            // View comments without logging in (Guest mode) — login is only required to post, like or reply.
            return false
        default:
            return true
        }
    }
}
