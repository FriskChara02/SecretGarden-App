//
//  HTTPMethod.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

// Represents standard REST HTTP methods — uses an enum instead of a raw String
// so the compiler catches typos (e.g., "GTE" instead of "GET") at build time.

import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
