//
//  Report.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Request model for REPORTS — Report a violation for this series/chapter.

import Foundation

public struct ReportRequest: Codable, Equatable {
    public var seriesId: String
    public var chapterId: String?
    public var reason: String
    public var note: String?

    public init(seriesId: String, chapterId: String? = nil, reason: String, note: String? = nil) {
        self.seriesId = seriesId
        self.chapterId = chapterId
        self.reason = reason
        self.note = note
    }
}
