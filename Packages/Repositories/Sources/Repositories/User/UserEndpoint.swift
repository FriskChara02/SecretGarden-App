//
//  UserEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 18/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

enum UserEndpoint: APIEndpoint {
    case fetchCurrentUser
    case updateProfile(UpdateProfileRequest)
    case updateAccount(UpdateAccountRequest)

    var path: String {
        switch self {
        case .fetchCurrentUser, .updateProfile:
            return "/users/me"
        case .updateAccount:
            return "/users/me/account"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchCurrentUser: return .get
        case .updateProfile, .updateAccount: return .put
        }
    }

    var body: Data? {
        switch self {
        case .fetchCurrentUser:
            return nil
        case .updateProfile(let request):
            return Self.encode(request)
        case .updateAccount(let request):
            return Self.encode(request)
        }
    }

    var requiresAuth: Bool {
        true
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
