//
//  StubEndpoint.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreNetworking
import Foundation

/// Shared mock endpoint for networking tests.
struct StubEndpoint: APIEndpoint {
    var path = "/items"
    var method: HTTPMethod = .get
    var requiresAuth = true
    var queryItems: [URLQueryItem]?
    var body: Data?
    var headers: [String: String]?
}
