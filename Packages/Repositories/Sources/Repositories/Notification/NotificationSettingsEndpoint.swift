//
//  NotificationSettingsEndpoint.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

enum NotificationSettingsEndpoint: APIEndpoint {
    case fetch
    case update(NotificationSettings)

    var path: String { "/users/me/notification-settings" }

    var method: HTTPMethod {
        switch self {
        case .fetch: return .get
        case .update: return .put
        }
    }

    var body: Data? {
        switch self {
        case .fetch:
            return nil
        case .update(let settings):
            return Self.encode(settings)
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
