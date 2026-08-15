//
//  SeriesEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 15/8/26.
//

// Dedicated endpoint for SeriesRepository
// Placed in the Repositories package (not CoreNetworking) because it is a business-specific
// detail of Series; CoreNetworking should only know "what an APIEndpoint is," not
// "how many business domains the app has."

import CoreNetworking
import Foundation

enum SeriesEndpoint: APIEndpoint {
    case seriesDetail(id: String)
    case chapters(seriesId: String)
    case relatedSeries(seriesId: String)
    case favorite(seriesId: String, isFavorited: Bool)

    var path: String {
        switch self {
        case .seriesDetail(let id):
            return "/series/\(id)"
        case .chapters(let seriesId):
            return "/series/\(seriesId)/chapters"
        case .relatedSeries(let seriesId):
            return "/series/\(seriesId)/related"
        case .favorite(let seriesId, _):
            return "/series/\(seriesId)/favorite"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .seriesDetail, .chapters, .relatedSeries:
            return .get
        case .favorite(_, let isFavorited):
            // isFavorited = true  -> want to ADD to favorites    -> POST
            // isFavorited = false -> want to REMOVE from favorites -> DELETE
            // (per API design: "POST /series/{id}/favorite / DELETE ...")
            return isFavorited ? .post : .delete
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .seriesDetail, .chapters, .relatedSeries:
            // Guest mode allows reading stories publicly without logging in
            return false
        case .favorite:
            // Favorites requires logged in
            return true
        }
    }
}
