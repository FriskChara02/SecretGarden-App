//
//  RefreshTokenEndpoint.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// Dedicated endpoint for token refresh
// because AuthInterceptor needs to use it at a low level, before the AuthFeature package exists.

import CoreModels
import Foundation

struct RefreshTokenEndpoint: APIEndpoint {
    let path = "/auth/refresh-token"
    let method: HTTPMethod = .post
    let requiresAuth = false // because the Access Token has expired -- this endpoint only requires the Refresh Token in the body
    let body: Data?

    init(refreshToken: String) {
        self.body = try? JSONEncoder().encode(["refreshToken": refreshToken])
    }
}

/// The minimal response required to obtain a new token,
/// but a separate struct is defined here so that AuthInterceptor does not have a reverse dependency on any feature package.
struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
