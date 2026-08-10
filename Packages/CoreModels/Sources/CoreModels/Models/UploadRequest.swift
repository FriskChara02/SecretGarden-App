//
//  UploadRequest.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Domain model for UPLOAD_REQUESTS

import Foundation

public struct UploadRequest: Codable, Identifiable, Equatable {
    public let id: String
    public var groupNameWanted: String
    public var message: String
    /// "pending" / "approved" / "rejected"
    public var status: String

    public init(id: String, groupNameWanted: String, message: String, status: String = "pending") {
        self.id = id
        self.groupNameWanted = groupNameWanted
        self.message = message
        self.status = status
    }
}
