//
//  ErrorResponse.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

// Error structure returned by the server when the status code is not 2xx.
// Example body: { "message": "Email already exists", "code": "EMAIL_TAKEN" }

import Foundation

public struct ErrorResponse: Codable, Sendable {
    public let message: String
    public let code: String?
}
