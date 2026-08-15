//
//  MockAPIClient.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 15/8/26.
//

// Used to unit test the repository without making actual network calls.

import CoreArchitecture
import Foundation
@testable import CoreNetworking

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var stubbedResult: Result<Any, AppError> = .failure(.unknown("Chưa stub kết quả"))
    private(set) var requestedEndpoints: [APIEndpoint] = []

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stubbedResult {
        case .success(let value):
            guard let typed = value as? T else {
                fatalError("MockAPIClient: kiểu stub (\(type(of: value))) không khớp kiểu mong đợi (\(T.self))")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }

    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        requestedEndpoints.append(endpoint)
        if case .failure(let error) = stubbedResult {
            throw error
        }
    }
}
