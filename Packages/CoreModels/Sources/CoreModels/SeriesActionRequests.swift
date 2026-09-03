//
//  SeriesActionRequests.swift
//  CoreModels
//
//  Created by Loi Nguyen on 3/9/26.
//

// Request body models for Series Detail/Reader actions — in the correct position
// LoginRequest/RegisterRequest (Auth) and ReportRequest

import Foundation

public struct RecordReadingProgressRequest: Codable, Equatable {
    public var page: Int

    public init(page: Int) {
        self.page = page
    }
}

public struct UpdateReadingStatusRequest: Codable, Equatable {
    public var status: ReadingStatus
    public var notifyNewChapter: Bool

    public init(status: ReadingStatus, notifyNewChapter: Bool) {
        self.status = status
        self.notifyNewChapter = notifyNewChapter
    }
}

public struct ToggleNotifyRequest: Codable, Equatable {
    public var enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }
}
