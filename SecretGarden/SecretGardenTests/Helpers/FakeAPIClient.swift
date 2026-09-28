//
//  FakeAPIClient.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreNetworking
import Foundation

/// Mock APIClient: records every endpoint called and returns a predefined result (or throws a predefined error).
actor FakeAPIClient: APIClientProtocol {

    private(set) var endpoints: [APIEndpoint] = []
    private let response: Any?
    private let failure: Error?

    init(response: Any? = nil, failure: Error? = nil) {
        self.response = response
        self.failure = failure
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        endpoints.append(endpoint)
        if let failure { throw failure }
        guard let typed = response as? T else {
            throw AppError.unknown("FakeAPIClient: chưa stub response kiểu \(T.self)")
        }
        return typed
    }

    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        endpoints.append(endpoint)
        if let failure { throw failure }
    }
}
