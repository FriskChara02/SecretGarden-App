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

import CoreModels
import CoreNetworking
import Foundation

enum SeriesEndpoint: APIEndpoint {
    case seriesDetail(id: String)
    case chapters(seriesId: String)
    case relatedSeries(seriesId: String)
    case favorite(seriesId: String, isFavorited: Bool)
    case chapterPages(chapterId: String)
    case recordReadingProgress(seriesId: String, chapterId: String, request: RecordReadingProgressRequest)
    case updateReadingStatus(seriesId: String, request: UpdateReadingStatusRequest)
    case toggleNotify(seriesId: String, request: ToggleNotifyRequest)
    case submitReport(ReportRequest)
    case removeReadingStatus(seriesId: String)

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
        case .chapterPages(let chapterId):
            return "/chapters/\(chapterId)/pages"
        case .recordReadingProgress(_, let chapterId, _):
            return "/chapters/\(chapterId)/read"
        case .updateReadingStatus(let seriesId, _):
            return "/users/me/reading-status/\(seriesId)"
        case .toggleNotify(let seriesId, _):
            return "/series/\(seriesId)/notify"
        case .submitReport:
            return "/reports"
        case .removeReadingStatus(let seriesId):
            return "/users/me/reading-status/\(seriesId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .seriesDetail, .chapters, .relatedSeries, .chapterPages:
            return .get
        case .favorite(_, let isFavorited):
            // isFavorited = true  -> want to ADD to favorites    -> POST
            // isFavorited = false -> want to REMOVE from favorites -> DELETE
            // (per API design: "POST /series/{id}/favorite / DELETE ...")
            return isFavorited ? .post : .delete
        case .recordReadingProgress, .submitReport:
            return .post
        case .updateReadingStatus, .toggleNotify:
            return .put
        case .removeReadingStatus:
            return .delete
        }
    }

    var body: Data? {
        switch self {
        case .seriesDetail, .chapters, .relatedSeries, .favorite, .chapterPages, .removeReadingStatus:
            return nil
        case .recordReadingProgress(_, _, let request):
            return Self.encode(request)
        case .updateReadingStatus(_, let request):
            return Self.encode(request)
        case .toggleNotify(_, let request):
            return Self.encode(request)
        case .submitReport(let request):
            return Self.encode(request)
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .seriesDetail, .chapters, .relatedSeries, .chapterPages:
            // Guest mode allows reading public stories/chapters without logging in.
            return false
        case .favorite, .recordReadingProgress, .updateReadingStatus, .toggleNotify, .submitReport, .removeReadingStatus:
            // All mutation actions require logging in.
            return true
        }
    }

    // MARK: - Private

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private static func encode<T: Encodable>(_ value: T) -> Data {
        try! encoder.encode(value)
    }
}
