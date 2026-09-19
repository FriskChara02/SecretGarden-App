//
//  BlockListEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreNetworking
import Foundation

enum BlockListEndpoint: APIEndpoint {
    case fetchBlockedSeries
    case fetchBlockedTags
    case blockSeries(seriesId: String)
    case unblockSeries(seriesId: String)
    case blockTag(tagId: String)
    case unblockTag(tagId: String)

    var path: String {
        switch self {
        case .fetchBlockedSeries, .blockSeries:
            return "/users/me/blocked-series"
        case .unblockSeries(let seriesId):
            return "/users/me/blocked-series/\(seriesId)"
        case .fetchBlockedTags, .blockTag:
            return "/users/me/blocked-tags"
        case .unblockTag(let tagId):
            return "/users/me/blocked-tags/\(tagId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchBlockedSeries, .fetchBlockedTags:
            return .get
        case .blockSeries, .blockTag:
            return .post
        case .unblockSeries, .unblockTag:
            return .delete
        }
    }

    var body: Data? {
        switch self {
        case .blockSeries(let seriesId):
            return Self.encode(["seriesId": seriesId])
        case .blockTag(let tagId):
            return Self.encode(["tagId": tagId])
        case .fetchBlockedSeries, .fetchBlockedTags, .unblockSeries, .unblockTag:
            return nil
        }
    }

    var requiresAuth: Bool { true }

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
